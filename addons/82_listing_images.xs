addon listing_images {
  input {
    int listing_id
  }

  stack {
    db.query listing_image {
      where = $db.listing_image.listing_id == $input.listing_id
      sort = {sort_order: "asc"}
      return = {type: "list"}
    }
  }
}