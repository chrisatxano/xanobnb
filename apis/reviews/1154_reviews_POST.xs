// Leave a review for a completed booking (guests only)
query reviews verb=POST {
  api_group = "Reviews"
  auth = "user"

  input {
    int booking_id {
      table = "booking"
    }
  
    int rating filters=min:1|max:5
    text comment? filters=trim
  }

  stack {
    // Get the booking
    db.get booking {
      field_name = "id"
      field_value = $input.booking_id
    } as $booking
  
    precondition ($booking != null) {
      error_type = "notfound"
      error = "Booking not found"
    }
  
    // Must be the guest
    precondition ($booking.guest_id == $auth.id) {
      error_type = "accessdenied"
      error = "Only the guest can review a booking"
    }
  
    // Booking must be completed
    precondition ($booking.status == "completed") {
      error_type = "inputerror"
      error = "You can only review completed bookings"
    }
  
    // Check if already reviewed
    db.has review {
      field_name = "booking_id"
      field_value = $input.booking_id
    } as $already_reviewed
  
    precondition ($already_reviewed == false) {
      error_type = "inputerror"
      error = "You have already reviewed this booking"
    }
  
    db.add review {
      data = {
        booking_id: $input.booking_id
        listing_id: $booking.listing_id
        guest_id  : $auth.id
        rating    : $input.rating
        comment   : $input.comment
        created_at: now
      }
    } as $review
  }

  response = $review
}