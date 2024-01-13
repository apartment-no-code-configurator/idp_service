#TO-DO: Cache session_id based on society, user_id and a random string, it should be nested with society aoa_number, user_id
require "user_mgmt_crud/user_lib"

class UsersController < AuthenticationController

  include UserMgmtCrud
  before_action :check_session_and_token_access, except: [:change_password]
  before_action :set_user_for_login, only: [:change_password]

  attr_accessor :user_obj
  def user_record_details
    @user_obj = UserLib.find(Session.find_by(session_id: ).user_id)
    render_details
  end

  #TO-DO, other than creating user, add user to respective tenant database -> Do this in one transaction
  def create_user
    @user_obj = UserLib.new(user_creation_params, society).create_user
    render_details(204)
  end

  def edit_user
    user_params = user_edit_params
    @user_obj = UserLib.new(user_params, society)
    if user_params.keys.include?(:password)
      user_obj.change_password
    else
      user_obj.edit_user
    end
    render_details(201)
  end

  def delete_user
  end

  def hard_delete_user
  end

  def change_password
    if (check_if_user_can_access_society)
      UserLib.new({id: User.find_by(id: JsonWebTokenUtils.decode(user_edit_params[:id], true).first["id"]), password: user_edit_params[:password]}, society).change_password
    else
      raise_society_not_accessible_for_user
    end
  end

  #TO-DO: Implement this by sending otp to registered email. On successful otp being entered, UI can move to change_password page. On failure, UI can move to login page
  # def forgot_password
  # end

  private

  def params_email
    symbolized_params[:user][:email]
  end

  def user_creation_params
    symbolized_params(:user).permit(
      :telegram_username,
      :first_name,
      :last_name,
      :email,
      :phone,
      :is_active,
      :password
    )
  end

  def user_edit_params
    symbolized_params(:user).permit(
      :telegram_username,
      :first_name,
      :last_name,
      :email,
      :phone,
      :id,
      :is_active,
      :password
    )
  end

  def render_details(status_code=200)
    if status_code != 204
      render json: user_obj.details_as_json, status: status_code
    else
      render json: {}, status:status_code
    end
  end

end
