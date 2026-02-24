table listing_image {
  auth = false

  schema {
    int id
  
    // The listing this image belongs to
    int listing_id {
      table = "listing"
    }
  
    image image
    text caption?
    int sort_order?
    timestamp created_at?=now
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "listing_id"}]}
    {type: "btree", field: [{name: "sort_order"}]}
  ]
}