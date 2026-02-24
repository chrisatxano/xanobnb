// Update the authenticated user's profile
query me verb=PATCH {
  api_group = "Authentication"
  auth = "user"

  input {
    text name? filters=trim
    text bio?
    text profile_photo?
    text phone? filters=trim
    bool is_host?
  }

  stack {
    var $updates {
      value = {}
    }
  
    conditional {
      if ($input.name != null) {
        var.update $updates.name {
          value = $input.name
        }
      }
    }
  
    conditional {
      if ($input.bio != null) {
        var.update $updates.bio {
          value = $input.bio
        }
      }
    }
  
    conditional {
      if ($input.profile_photo != null) {
        var.update $updates.profile_photo {
          value = $input.profile_photo
        }
      }
    }
  
    conditional {
      if ($input.phone != null) {
        var.update $updates.phone {
          value = $input.phone
        }
      }
    }
  
    conditional {
      if ($input.is_host != null) {
        var.update $updates.is_host {
          value = $input.is_host
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
  
    db.patch user {
      field_name = "id"
      field_value = $auth.id
      data = $updates
    } as $user
  }

  response = $user
}