// Get a single booking by ID (host or guest only)
query "bookings/{booking_id}" verb=GET {
  api_group = "Bookings"
  auth = "user"

  input {
    int booking_id {
      table = "booking"
    }
  }

  stack {
    db.get booking {
      field_name = "id"
      field_value = $input.booking_id
    } as $booking
  
    precondition ($booking != null) {
      error_type = "notfound"
      error = "Booking not found"
    }
  
    precondition ($booking.host_id == $auth.id || $booking.guest_id == $auth.id) {
      error_type = "accessdenied"
      error = "You do not have access to this booking"
    }
  
    // Fetch listing details
    db.get listing {
      field_name = "id"
      field_value = $booking.listing_id
    } as $listing
  }

  response = {booking: $booking, listing: $listing}
}