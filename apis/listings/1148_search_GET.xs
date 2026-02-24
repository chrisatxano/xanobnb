// Search and filter active listings
query search verb=GET {
  api_group = "Listings"

  input {
    text city? filters=trim|lower
    text country? filters=trim|lower
    decimal min_price?
    decimal max_price?
    int guests?
    date? check_in?
    date check_out?
    int page?=1 filters=min:1
    int per_page?=20 filters=min:1|max:50
  }

  stack {
    db.query listing {
      where = $db.listing.is_active == true && ($db.listing.city|to_lower) ==? $input.city && ($db.listing.country|to_lower) ==? $input.country && $db.listing.price_per_night >=? $input.min_price && $db.listing.price_per_night <=? $input.max_price && $db.listing.max_guests >=? $input.guests
      sort = {created_at: "desc"}
      return = {
        type  : "list"
        paging: {page: $input.page, per_page: $input.per_page}
      }
    } as $listings
  
    // If date range provided, filter out listings with conflicting bookings
    conditional {
      if (($input.check_in|is_empty) == false && ($input.check_out|is_empty) == false) {
        var $available_items {
          value = []
        }
      
        foreach ($listings.items) {
          each as $listing {
            db.query booking {
              where = $db.booking.listing_id == $listing.id && $db.booking.status != "cancelled" && $db.booking.check_in < $input.check_out && $db.booking.check_out > $input.check_in
              return = {type: "count"}
            } as $conflicts
          
            conditional {
              if ($conflicts == 0) {
                var.update $available_items {
                  value = $available_items|push:$listing
                }
              }
            }
          }
        }
      
        var.update $listings.items {
          value = $available_items
        }
      }
    }
  }

  response = $listings
}