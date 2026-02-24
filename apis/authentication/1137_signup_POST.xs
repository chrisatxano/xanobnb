// Register a new user account
query signup verb=POST {
  api_group = "Authentication"

  input {
    text name filters=trim
    email email filters=trim|lower
    password password
    bool is_host?
  }

  stack {
    // Check if email already exists
    db.has user {
      field_name = "email"
      field_value = $input.email
    } as $exists
  
    precondition ($exists == false) {
      error_type = "inputerror"
      error = "An account with this email already exists"
    }
  
    // Create the user
    db.add user {
      data = {
        name      : $input.name
        email     : $input.email
        password  : $input.password
        is_host   : $input.is_host
        created_at: now
      }
    } as $user
  
    // Generate auth token
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 3600
      id = $user.id
    } as $token
  }

  response = {authToken: $token, user: $user}
}