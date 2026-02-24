// Update a listing (owner only)
query "listings/{listing_id}" verb=PATCH {
  api_group = "Listings"
  auth = "user"

  input {
    int listing_id {
      table = "listing"
    }
  
    text title? filters=trim
    text description? filters=trim
    text address? filters=trim
    text city? filters=trim
    text state? filters=trim
    text country? filters=trim
    decimal latitude?
    decimal longitude?
    decimal price_per_night? filters=min:0
    int max_guests? filters=min:1
    int bedrooms? filters=min:0
    int beds? filters=min:1
    int bathrooms? filters=min:0
    json amenities?
    bool is_active?
  }

  stack {
    // Verify ownership
    db.get listing {
      field_name = "id"
      field_value = $input.listing_id
    } as $existing
  
    precondition ($existing != null) {
      error_type = "notfound"
      error = "Listing not found"
    }
  
    precondition ($existing.host_id == $auth.id) {
      error_type = "accessdenied"
      error = "You can only edit your own listings"
    }
  
    var $updates {
      value = {}
    }
  
    conditional {
      if ($input.title != null) {
        var.update $updates.title {
          value = $input.title
        }
      }
    }
  
    conditional {
      if ($input.description != null) {
        var.update $updates.description {
          value = $input.description
        }
      }
    }
  
    conditional {
      if ($input.address != null) {
        var.update $updates.address {
          value = $input.address
        }
      }
    }
  
    conditional {
      if ($input.city != null) {
        var.update $updates.city {
          value = $input.city
        }
      }
    }
  
    conditional {
      if ($input.state != null) {
        var.update $updates.state {
          value = $input.state
        }
      }
    }
  
    conditional {
      if ($input.country != null) {
        var.update $updates.country {
          value = $input.country
        }
      }
    }
  
    conditional {
      if ($input.latitude != null) {
        var.update $updates.latitude {
          value = $input.latitude
        }
      }
    }
  
    conditional {
      if ($input.longitude != null) {
        var.update $updates.longitude {
          value = $input.longitude
        }
      }
    }
  
    conditional {
      if ($input.price_per_night != null) {
        var.update $updates.price_per_night {
          value = $input.price_per_night
        }
      }
    }
  
    conditional {
      if ($input.max_guests != null) {
        var.update $updates.max_guests {
          value = $input.max_guests
        }
      }
    }
  
    conditional {
      if ($input.bedrooms != null) {
        var.update $updates.bedrooms {
          value = $input.bedrooms
        }
      }
    }
  
    conditional {
      if ($input.beds != null) {
        var.update $updates.beds {
          value = $input.beds
        }
      }
    }
  
    conditional {
      if ($input.bathrooms != null) {
        var.update $updates.bathrooms {
          value = $input.bathrooms
        }
      }
    }
  
    conditional {
      if ($input.amenities != null) {
        var.update $updates.amenities {
          value = $input.amenities
        }
      }
    }
  
    conditional {
      if ($input.is_active != null) {
        var.update $updates.is_active {
          value = $input.is_active
        }
      }
    }
  
    precondition (($updates|is_empty) == false) {
      error_type = "inputerror"
      error = "No updates provided"
    }
  
    var.update $updates.updated_at {
      value = now
    }
  
    db.patch listing {
      field_name = "id"
      field_value = $input.listing_id
      data = $updates
    } as $listing
  }

  response = $listing
}