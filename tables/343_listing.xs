table listing {
  auth = false

  schema {
    int id
  
    // The user who owns this listing
    int host_id {
      table = "user"
    }
  
    text title filters=trim
    text description filters=trim
    enum property_type {
      values = ["apartment", "house", "condo", "villa", "cabin", "studio", "other"]
    }
  
    text address filters=trim
    text city filters=trim
    text state? filters=trim
    text country filters=trim
    decimal latitude?
    decimal longitude?
    decimal price_per_night filters=min:0
    int max_guests?=1 filters=min:1
    int bedrooms?=1 filters=min:0
    int beds?=1 filters=min:1
    int bathrooms?=1 filters=min:0
    json amenities?
    bool is_active?=true
    timestamp created_at?=now
    timestamp updated_at?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "host_id"}]}
    {type: "btree", field: [{name: "city"}]}
    {type: "btree", field: [{name: "country"}]}
    {type: "btree", field: [{name: "price_per_night"}]}
    {type: "btree", field: [{name: "is_active"}]}
    {type: "btree", field: [{name: "max_guests"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}