table message {
  auth = false

  schema {
    int id
  
    // The conversation this message belongs to
    int conversation_id {
      table = "conversation"
    }
  
    // The user who sent this message
    int sender_id {
      table = "user"
    }
  
    text body filters=trim
    bool is_read?
    timestamp created_at?=now
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "conversation_id"}]}
    {type: "btree", field: [{name: "sender_id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}