// Get a single listing by ID with images and reviews
query "listings/{listing_id}" verb=GET {
  api_group = "Listings"

  input {
    int listing_id {
      table = "listing"
    }
  }

  stack {
    db.get listing {
      field_name = "id"
      field_value = $input.listing_id
    } as $listing
  
    precondition ($listing != null) {
      error_type = "notfound"
      error = "Listing not found"
    }
  
    // Fetch images
    db.query listing_image {
      where = $db.listing_image.listing_id == $listing.id
      sort = {sort_order: "asc"}
      return = {type: "list"}
    } as $images
  
    // Fetch reviews
    db.query review {
      where = $db.review.listing_id == $listing.id
      sort = {created_at: "desc"}
      return = {type: "list"}
    } as $reviews
  
    // Calculate average rating
    var $avg_rating {
      value = null
    }
  
    conditional {
      if (($reviews|get:"items":[]|count) > 0) {
        var.update $avg_rating {
          value = `($reviews.items|map:"rating"|avg)|round:1`
        }
      }
    }
  
    // Fetch host info
    db.get user {
      field_name = "id"
      field_value = $listing.host_id
    } as $host
  }

  response = {
    listing     : $listing
    images      : $images.items
    reviews     : $reviews.items
    avg_rating  : $avg_rating
    review_count: $reviews.items|count
    host        : ```
      {
        id: $host.id,
        name: $host.name,
        profile_photo: $host.profile_photo,
        created_at: $host.created_at
      }
      ```
  }
}