// Get all reviews for a listing
query "listings/{listing_id}/reviews" verb=GET {
  api_group = "Reviews"

  input {
    int listing_id {
      table = "listing"
    }
  
    int page?=1 filters=min:1
    int per_page?=20 filters=min:1|max:50
  }

  stack {
    db.query review {
      where = $db.review.listing_id == $input.listing_id
      sort = {created_at: "desc"}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: $input.per_page}
      }
    } as $reviews
  
    // Enrich with guest names
    foreach ($reviews.items) {
      each as $review {
        db.get user {
          field_name = "id"
          field_value = $review.guest_id
        } as $guest
      
        var.update $review.guest_name {
          value = $guest.name
        }
      
        var.update $review.guest_photo {
          value = $guest.profile_photo
        }
      }
    }
  }

  response = $reviews
}