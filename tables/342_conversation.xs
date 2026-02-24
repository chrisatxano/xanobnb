table conversation {
  auth = false

  schema {
    int id
  
    // First participant
    int user_1_id {
      table = "user"
    }
  
    // Second participant
    int user_2_id {
      table = "user"
    }
  
    // Booking context - users can only message through bookings
    // Made optional for migration, but should be required in practice
    int booking_id? {
      table = "booking"
    }
  
    timestamp last_message_at?
    timestamp created_at?=now
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "user_1_id"}]}
    {type: "btree", field: [{name: "user_2_id"}]}
    {type: "btree", field: [{name: "booking_id"}]}
    {
      type : "btree"
      field: [{name: "last_message_at", op: "desc"}]
    }
  ]
}