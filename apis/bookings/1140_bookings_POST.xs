// Create a new booking (guests only)
query bookings verb=POST {
  api_group = "Bookings"
  auth = "user"

  input {
    int listing_id {
      table = "listing"
    }
  
    date check_in
    date check_out
    int guests?=1 filters=min:1
  }

  stack {
    // Validate dates
    precondition ($input.check_in < $input.check_out) {
      error_type = "inputerror"
      error = "Check-out must be after check-in"
    }
  
    // Get the listing
    db.get listing {
      field_name = "id"
      field_value = $input.listing_id
    } as $listing
  
    precondition ($listing != null) {
      error_type = "notfound"
      error = "Listing not found"
    }
  
    precondition ($listing.is_active) {
      error_type = "inputerror"
      error = "This listing is not currently available"
    }
  
    // Cannot book your own listing
    precondition ($listing.host_id != $auth.id) {
      error_type = "inputerror"
      error = "You cannot book your own listing"
    }
  
    // Check guest count
    precondition ($input.guests <= $listing.max_guests) {
      error_type = "inputerror"
      error = "Guest count exceeds the listing maximum of " ~ $listing.max_guests
    }
  
    // Check availability - no overlapping confirmed/pending bookings
    db.query booking {
      where = $db.booking.listing_id == $input.listing_id && $db.booking.status != "cancelled" && $db.booking.check_in < $input.check_out && $db.booking.check_out > $input.check_in
      return = {type: "count"}
    } as $conflicts
  
    precondition ($conflicts == 0) {
      error_type = "inputerror"
      error = "This listing is not available for the selected dates"
    }
  
    // Calculate total price
    var $nights {
      value = (($input.check_out|to_ms) - ($input.check_in|to_ms)) / 86400000
    }
  
    var $total_price {
      value = ($nights * $listing.price_per_night)|round:2
    }
  
    db.add booking {
      data = {
        listing_id : $input.listing_id
        guest_id   : $auth.id
        host_id    : $listing.host_id
        check_in   : $input.check_in
        check_out  : $input.check_out
        guests     : $input.guests
        total_price: $total_price
        status     : "pending"
        created_at : now
      }
    } as $booking
  }

  response = $booking
}