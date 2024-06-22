#for login route, always process
#always check if session id is present in request -> request from UI -> check in cache if present. in absense, reject to login with 401, else check JWT token against the session id
#if no session id is present in request -> API request -> check for JWT token based on self secret and authenticate accordingly

Rails.application.routes.draw do

  #TO-DO: Caching support for whole service
  get 'email_checking', to: "authentication#email_checking"
  post 'login', to: "authentication#login" #create session in cache if access is valid, send user_details also
  get 'logout', to: "authentication#logout" #delete session in cache

  get "user_details", to: "users#user_record_details" #along with society access details
  post "register_user", to: "users#register" #-> to be handled by UI template itself, on registering, shift to login page
  post "register_new_tenant_with_support_users", to: "users#register_new_tenant_with_support_users" #-> on registering society, register support users and initial user in IDP and DB #TO-DO
  post "default_admin_user", to: "users#create_default_admin_user"
  patch "edit_user",   to: "users#edit_user"
  delete "delete_user", to: "users#delete_user" #from specific society db and update society access in idp db
  delete "hard_delete_user", to: "users#hard_delete_user" #from our idp db and society db
  patch "change_password", to: "users#change_password"
  # patch "forgot_password", to: "users#forgot_password" #TO-DO: Implement this

end

#every api will authroize every request from cache else ask idp_service for user_details and figure it out
#every ui will query idp_service for user details if session_id is in cookies when useEffect runs for container for the most parent element
