require "user_mgmt_crud/user_lib"

class AuthenticationController < ApplicationController

  include UserMgmtCrud
  before_action :check_session_and_token_access, except: [:login, :email_checking]
  before_action :set_user_for_login, only: [:login, :email_checking]

  attr_accessor :session_id

  def email_checking #if user has no password, redirect to register user page
    if (check_if_user_can_access_society)
      render json: {
        user_id: JsonWebTokenUtils.encode({id: User.find_by(idp_service_id: user_details["_id"]).id}, true),
        redirect_to_register_page: user_details["password"].blank?
      }, status: :ok
    else
      raise_society_not_accessible_for_user
    end
  end

  def login
    if (check_if_user_can_access_society)
      render json: {session_id: UserLib.new(user_details.merge!({id: User.find_by(idp_service_id: user_details["_id"].to_s).id}), society).create_session!}, status: :created
    else
      raise_society_not_accessible_for_user
    end
  end

  # LATER ->
  # def sso_login #create user in mongodb and in tenant db based on link
  # end

  def logout
    begin
      session = symbolized_params[:session]
      Session.delete_session(session)
      render json: {}
    rescue e
      raise e
    end


  end

  private

  def set_user_for_login
    @user_details = MongoDBAdapter.run_query(:fetch_record, {email: params_email, password: params_password}) rescue nil
    raise "401, User not found in IDP database" if user_details.blank?
    raise "500, Duplicate users, please check data for email - #{params_email}" if user_details.count > 1
    @user_details = user_details.first
  end

  def params_email
    symbolized_params[:user_login][:email]
  end

  def params_password
    #TO-DO: Add salt to password to check if it is valid
    symbolized_params[:user_login][:password]
  end

  def check_session_and_token_access
    authorization_token = request.headers["Authorization"] #check against internal APIs
    session_id = request.headers["session_id"] #check against UI requests

    raise "401, unauthorized" if !(authorization_token.present? || session_id.present?) #check if none are present

    raise "401, session invalid, redirect to login" if session_id && check_session_access(session_id) && set_society_singletons_and_tenant_model_connection_for_ui_requests

    raise "401, token invalid" if authorization_token && check_token_access_and_set_society_for_api_requests(authorization_token)

  end

  def check_session_access(session_id)
    Session.check_session_access(session_id, JsonWebTokenUtils.decode(session_id))
  end

  def check_token_access_and_set_society_for_api_requests(token)
    value = JsonWebTokenUtils.decode(token.split("Bearer ")[1]).first rescue nil
    if value.present?
      @society = Society.find_by(aoa_number: value["aoa_number"])
      if society
        tenant_establish_connnection
        false
      end
    else
      true
    end
  end

  def society_mismatch(token_json)
    Society.find_by(aoa_number: token_json[:aoa_number]) == @society
  end

  def raise_society_not_accessible_for_user
    raise "401, User not permitted to society application"
  end

end
