// Get messages in a conversation
query "conversations/{conversation_id}/messages" verb=GET {
  api_group = "Messages"
  auth = "user"

  input {
    int conversation_id {
      table = "conversation"
    }
  
    int page?=1 filters=min:1
    int per_page?=50 filters=min:1|max:100
  }

  stack {
    // Verify user is a participant
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
  
    // Verify the booking exists (allow viewing for all booking statuses)
    db.get booking {
      field_name = "id"
      field_value = $conversation.booking_id
    } as $booking
  
    precondition ($booking != null) {
      error_type = "notfound"
      error = "Associated booking not found"
    }
  
    // Get messages
    db.query message {
      where = $db.message.conversation_id == $input.conversation_id
      sort = {created_at: "desc"}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: $input.per_page}
      }
    } as $messages
  
    // Mark unread messages from the other user as read
    foreach ($messages.items) {
      each as $msg {
        conditional {
          if ($msg.sender_id != $auth.id && $msg.is_read == false) {
            db.patch message {
              field_name = "id"
              field_value = $msg.id
              data = {is_read: true}
            }
          }
        }
      }
    }
  }

  response = $messages
}