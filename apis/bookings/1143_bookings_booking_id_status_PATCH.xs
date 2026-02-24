// Update booking status (host confirms/completes, guest or host cancels)
query "bookings/{booking_id}/status" verb=PATCH {
  api_group = "Bookings"
  auth = "user"

  input {
    int booking_id {
      table = "booking"
    }
  
    enum status {
      values = ["confirmed", "cancelled", "completed"]
    }
  
    text cancellation_reason?
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
  
    // Must be host or guest of this booking
    precondition ($booking.host_id == $auth.id || $booking.guest_id == $auth.id) {
      error_type = "accessdenied"
      error = "You do not have access to this booking"
    }
  
    // Only hosts can confirm or complete
    conditional {
      if ($input.status == "confirmed" || $input.status == "completed") {
        precondition ($booking.host_id == $auth.id) {
          error_type = "accessdenied"
          error = "Only the host can confirm or complete a booking"
        }
      }
    }
  
    // Validate status transitions
    conditional {
      if ($input.status == "confirmed") {
        precondition ($booking.status == "pending") {
          error_type = "inputerror"
          error = "Only pending bookings can be confirmed"
        }
      }
    }
  
    conditional {
      if ($input.status == "completed") {
        precondition ($booking.status == "confirmed") {
          error_type = "inputerror"
          error = "Only confirmed bookings can be completed"
        }
      }
    }
  
    conditional {
      if ($input.status == "cancelled") {
        precondition ($booking.status == "pending" || $booking.status == "confirmed") {
          error_type = "inputerror"
          error = "This booking cannot be cancelled"
        }
      }
    }
  
    var $data {
      value = {status: $input.status, updated_at: now}
    }
  
    conditional {
      if ($input.cancellation_reason != null) {
        var.update $data.cancellation_reason {
          value = $input.cancellation_reason
        }
      }
    }
  
    db.patch booking {
      field_name = "id"
      field_value = $input.booking_id
      data = $data
    } as $updated
  }

  response = $updated
}