// Get bookings for my listings (host view)
query "host-bookings" verb=GET {
  api_group = "Bookings"
  auth = "user"

  input {
    int listing_id?
    enum status? {
      values = ["pending", "confirmed", "cancelled", "completed"]
    }
  
    int page?=1 filters=min:1
    int per_page?=20 filters=min:1|max:50
  }

  stack {
    db.query booking {
      where = $db.booking.host_id == $auth.id && $db.booking.listing_id ==? $input.listing_id && $db.booking.status ==? $input.status
      sort = {created_at: "desc"}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: $input.per_page}
      }
    } as $bookings
  }

  response = $bookings
}