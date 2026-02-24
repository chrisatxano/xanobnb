// Check if a listing is available for given dates
function "check-listing-availability" {
  input {
    // The listing to check
    int listing_id
  
    // Desired check-in date
    date check_in
  
    // Desired check-out date
    date check_out
  }

  stack {
    db.query booking {
      where = $db.booking.listing_id == $input.listing_id && $db.booking.status != "cancelled" && $db.booking.check_in < $input.check_out && $db.booking.check_out > $input.check_in
      return = {type: "count"}
    } as $conflicts
  
    var $available {
      value = ($conflicts == 0)
    }
  }

  response = $available
}