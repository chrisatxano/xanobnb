// Create a new listing (hosts only)
query listings verb=POST {
  api_group = "Listings"
  auth = "user"

  input {
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
  }

  stack {
    // Verify user is a host
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user
  
    precondition ($user.is_host) {
      error_type = "accessdenied"
      error = "Only hosts can create listings. Update your profile to become a host."
    }
  
    db.add listing {
      data = {
        host_id        : $auth.id
        title          : $input.title
        description    : $input.description
        property_type  : $input.property_type
        address        : $input.address
        city           : $input.city
        state          : $input.state
        country        : $input.country
        latitude       : $input.latitude
        longitude      : $input.longitude
        price_per_night: $input.price_per_night
        max_guests     : $input.max_guests
        bedrooms       : $input.bedrooms
        beds           : $input.beds
        bathrooms      : $input.bathrooms
        amenities      : $input.amenities
        is_active      : true
        created_at     : now
      }
    } as $listing
  }

  response = $listing
}