// Query all listing records without parameters for the home page
query listings verb=GET {
  api_group = "Listings"

  input {
  }

  stack {
    db.query listing {
      return = {type: "list"}
    } as $model
  }

  response = $model
}