// Log in with email and password
query login verb=POST {
  api_group = "Authentication"

  input {
    email email filters=trim|lower
    text password
  }

  stack {
    // Find user by email
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $user
  
    precondition ($user != null) {
      error_type = "inputerror"
      error = "Invalid email or password"
    }
  
    // Verify password
    security.check_password {
      text_password = $input.password
      hash_password = $user.password
    } as $valid
  
    precondition ($valid) {
      error_type = "inputerror"
      error = "Invalid email or password"
    }
  
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