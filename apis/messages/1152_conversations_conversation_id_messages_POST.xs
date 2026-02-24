// Send a message in an existing conversation
query "conversations/{conversation_id}/messages" verb=POST {
  api_group = "Messages"
  auth = "user"

  input {
    int conversation_id {
      table = "conversation"
    }
  
    text body filters=trim
  }

  stack {
    // Verify participation
    db.get conversation {
      field_name = "id"
      field_value = $input.conversation_id
    } as $conversation
  
    precondition ($conversation != null) {
      error_type = "notfound"
      error = "Conversation not found"
    }
  
    precondition ($conversation.user_1_id == $auth.id || $conversation.user_2_id == $auth.id) {
      error_type = "accessdenied"
      error = "You do not have access to this conversation"
    }
  
    // Verify the booking is still valid (not cancelled)
    db.get booking {
      field_name = "id"
      field_value = $conversation.booking_id
    } as $booking
  
    precondition ($booking != null && $booking.status != "cancelled") {
      error_type = "accessdenied"
      error = "Cannot send messages for cancelled bookings"
    }
  
    // Add message
    db.add message {
      data = {
        conversation_id: $input.conversation_id
        sender_id      : $auth.id
        body           : $input.body
        is_read        : false
        created_at     : now
      }
    } as $message
  
    // Update conversation timestamp
    db.patch conversation {
      field_name = "id"
      field_value = $input.conversation_id
      data = {last_message_at: now}
    }
  }

  response = $message
}