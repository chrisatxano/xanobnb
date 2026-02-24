table review {
  auth = false

  schema {
    int id
  
    // The completed booking being reviewed
    int booking_id {
      table = "booking"
    }
  
    // The listing being reviewed
    int listing_id {
      table = "listing"
    }
  
    // The guest leaving the review
    int guest_id {
      table = "user"
    }
  
    int rating filters=min:1|max:5
    text comment? filters=trim
    timestamp created_at?=now
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree|unique", field: [{name: "booking_id"}]}
    {type: "btree", field: [{name: "listing_id"}]}
    {type: "btree", field: [{name: "guest_id"}]}
    {type: "btree", field: [{name: "rating"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}