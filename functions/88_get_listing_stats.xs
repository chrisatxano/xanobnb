// Get aggregate stats for a listing (avg rating, review count, booking count)
function "get-listing-stats" {
  input {
    // The listing to get stats for
    int listing_id
  }

  stack {
    // Review stats
    db.query review {
      where = $db.review.listing_id == $input.listing_id
      return = {type: "list"}
    } as $reviews
  
    var $avg_rating {
      value = null
    }
  
    var $review_count {
      value = $reviews.items|count
    }
  
    conditional {
      if ($review_count > 0) {
        var.update $avg_rating {
          value = `($reviews.items|map:"rating"|avg)|round:1`
        }
      }
    }
  
    // Booking counts
    db.query booking {
      where = $db.booking.listing_id == $input.listing_id && $db.booking.status == "completed"
      return = {type: "count"}
    } as $completed_bookings
  }

  response = {
    avg_rating        : $avg_rating
    review_count      : $review_count
    completed_bookings: $completed_bookings
  }
}