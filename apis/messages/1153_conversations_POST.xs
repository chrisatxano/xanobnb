// Start a new conversation or return existing one (requires a booking)
query conversations verb=POST {
  api_group = "Messages"
  auth = "user"

  input {
    int booking_id {
      table = "booking"
    }
  
    text message filters=trim
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
  
    // User must be either the guest or host of this booking
    precondition ($booking.guest_id == $auth.id || $booking.host_id == $auth.id) {
      error_type = "accessdenied"
      error = "You can only message for bookings you are part of"
    }
  
    // Determine the other participant
    var $recipient_id {
      value = $booking.guest_id == $auth.id ? $booking.host_id : $booking.guest_id
    }
  
    // Check for existing conversation for this booking
    db.query conversation {
      where = $db.conversation.booking_id == $input.booking_id
      return = {type: "single"}
    } as $existing
  
    var $conversation {
      value = $existing
    }
  
    conditional {
      if ($existing == null) {
        // Create new conversation
        db.add conversation {
          data = {
            user_1_id      : $auth.id
            user_2_id      : $recipient_id
            booking_id     : $input.booking_id
            last_message_at: now
            created_at     : now
          }
        } as $new_convo
      
        var.update $conversation {
          value = $new_convo
        }
      }
    }
  
    // Send the first message
    db.add message {
      data = {
        conversation_id: $conversation.id
        sender_id      : $auth.id
        body           : $input.message
        is_read        : false
        created_at     : now
      }
    } as $msg
  
    // Update last_message_at
    db.patch conversation {
      field_name = "id"
      field_value = $conversation.id
      data = `{last_message_at: now}`
    }
  }

  response = {conversation: $conversation, message: $msg}
}