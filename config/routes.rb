#for login route, always process
#always check if session id is present in request -> request from UI -> check in cache if present. in absense, reject to login with 401, else check JWT token against the session id
#if no session id is present in request -> API request -> check for JWT token based on self secret and authenticate accordingly

Rails.application.routes.draw do

  get 'login', to: "authentication#login" #create session in cache if access is valid, send user_details also
  get 'logout', to: "authentication#logout" #delete session in cache

  get "user_details", to: "users#user_details"
  post "register_user", to: "users#register" #-> to be handled by UI template itself, on registering, shift to login page
  patch "edit_user",   to: "users#edit_user"
  delete "delete_user", to: "users#delete_user" #for specific society applications
  delete "hard_delete_user", to: "users#hard_delete_user" #from our db
  patch "change_password", to: "users#change_password"
  patch "forgot_password", to: "users#forgot_password"

end

#every api will authroize every request from cache else ask idp_service for user_details and figure it out
#every ui will query idp_service for user details if session_id is in cookies when useEffect runs for container for the most parent element
