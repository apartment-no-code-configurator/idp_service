class AuthenticationController < ApplicationController

  before_action :check_session_and_token_access, except: [:login, :username_checking]

  attr_accessor :session_id

  def username_checking #if user has no password, redirect to change password page
  end

  def login #only on registered users with password
  end

  # LATER ->
  # def sso_login #create user in mongodb and in tenant db based on link
  # end

  def logout
  end

  private

  def check_session_and_token_access

    authorization_token = request.headers["Authorization"] #check against internal APIs
    session_id = request.headers["session_id"] #check against UI requests

    raise "401, unauthorized" if !(authorization_token.present? || session_id.present?) #check if none are present

    raise "401, session invalid, redirect to login" if check_session_access(session_id)

    raise "401, token invalid" if check_token_access(authorization_token)

  end

end
