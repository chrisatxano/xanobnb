table user {
  auth = true

  schema {
    int id
    text name filters=trim
    email email filters=trim|lower {
      sensitive = true
    }
  
    password password {
      sensitive = true
    }
  
    text bio?
    text profile_photo?
    text phone? {
      sensitive = true
    }
  
    bool is_host?
    timestamp created_at?=now
    timestamp updated_at?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree|unique", field: [{name: "email"}]}
    {type: "btree", field: [{name: "is_host"}]}
  ]
}