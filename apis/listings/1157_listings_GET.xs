// Query all listing records without parameters for the home page
query listings verb=GET {
  api_group = "Listings"

  input {
  }

  stack {
    db.query listing {
      where = $db.listing.is_active == true
      return = {type: "list"}
      output = ["title", "description", "property_type", "price_per_night"]
    } as $model
  }

  response = $model
}