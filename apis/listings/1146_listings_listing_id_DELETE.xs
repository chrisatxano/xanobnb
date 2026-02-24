// Delete a listing (owner only)
query "listings/{listing_id}" verb=DELETE {
  api_group = "Listings"
  auth = "user"

  input {
    int listing_id {
      table = "listing"
    }
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
      error = "You can only delete your own listings"
    }
  
    // Check for active bookings
    db.query booking {
      where = $db.booking.listing_id == $input.listing_id && ($db.booking.status == "pending" || $db.booking.status == "confirmed")
      return = {type: "count"}
    } as $active_bookings
  
    precondition ($active_bookings == 0) {
      error_type = "inputerror"
      error = "Cannot delete a listing with active bookings. Cancel all bookings first."
    }
  
    db.del listing {
      field_name = "id"
      field_value = $input.listing_id
    }
  }

  response = {success: true}
}