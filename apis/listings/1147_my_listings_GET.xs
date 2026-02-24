// Get all listings owned by the authenticated host
query "my-listings" verb=GET {
  api_group = "Listings"
  auth = "user"

  input {
    int page?=1 filters=min:1
    int per_page?=20 filters=min:1|max:50
  }

  stack {
    db.query listing {
      where = $db.listing.host_id == $auth.id
      sort = {created_at: "desc"}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: $input.per_page}
      }
    } as $listings
  }

  response = $listings
}