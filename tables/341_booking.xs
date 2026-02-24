table booking {
  auth = false

  schema {
    int id
  
    // The listing being booked
    int listing_id {
      table = "listing"
    }
  
    // The guest making the booking
    int guest_id {
      table = "user"
    }
  
    // The host who owns the listing
    int host_id {
      table = "user"
    }
  
    date check_in
    date check_out
    int guests filters=min:1
    decimal total_price filters=min:0
    enum status?=pending {
      values = ["pending", "confirmed", "cancelled", "completed"]
    }
  
    text cancellation_reason?
    timestamp created_at?=now
    timestamp updated_at?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "listing_id"}]}
    {type: "btree", field: [{name: "guest_id"}]}
    {type: "btree", field: [{name: "host_id"}]}
    {type: "btree", field: [{name: "status"}]}
    {type: "btree", field: [{name: "check_in"}]}
    {type: "btree", field: [{name: "check_out"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}