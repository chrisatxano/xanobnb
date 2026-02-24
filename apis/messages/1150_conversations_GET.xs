// List all conversations for the authenticated user
query conversations verb=GET {
  api_group = "Messages"
  auth = "user"

  input {
    int page?=1 filters=min:1
    int per_page?=20 filters=min:1|max:50
  }

  stack {
    db.query conversation {
      where = $db.conversation.user_1_id == $auth.id || $db.conversation.user_2_id == $auth.id
      sort = {last_message_at: "desc"}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: $input.per_page}
      }
    } as $conversations
  
    // Enrich each conversation with the other user's name and unread count
    foreach ($conversations.items) {
      each as $convo {
        // Determine the other user
        var $other_id {
          value = $convo.user_1_id
        }
      
        conditional {
          if ($convo.user_1_id == $auth.id) {
            var.update $other_id {
              value = $convo.user_2_id
            }
          }
        }
      
        db.get user {
          field_name = "id"
          field_value = $other_id
        } as $other_user
      
        var.update $convo.other_user {
          value = {
            id           : $other_user.id
            name         : $other_user.name
            profile_photo: $other_user.profile_photo
          }
        }
      
        // Get booking info
        db.get booking {
          field_name = "id"
          field_value = $convo.booking_id
        } as $booking
      
        var.update $convo.booking_info {
          value = {
            id        : $booking.id
            listing_id: $booking.listing_id
            check_in  : $booking.check_in
            check_out : $booking.check_out
            status    : $booking.status
          }
        }
      
        // Count unread messages
        db.query message {
          where = $db.message.conversation_id == $convo.id && $db.message.sender_id != $auth.id && $db.message.is_read == false
          return = {type: "count"}
        } as $unread
      
        var.update $convo.unread_count {
          value = $unread
        }
      }
    }
  }

  response = $conversations
}