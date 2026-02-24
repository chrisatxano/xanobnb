// Get bookings where I am the guest
query "my-bookings" verb=GET {
  api_group = "Bookings"
  auth = "user"

  input {
    enum status? {
      values = ["pending", "confirmed", "cancelled", "completed"]
    }
  
    int page?=1 filters=min:1
    int per_page?=20 filters=min:1|max:50
  }

  stack {
    db.query booking {
      where = $db.booking.guest_id == $auth.id && $db.booking.status ==? $input.status
      sort = {created_at: "desc"}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: $input.per_page}
      }
    } as $bookings
  }

  response = $bookings
}