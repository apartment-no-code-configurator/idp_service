class UsersController < AuthenticationController

  attr_accessor :user_obj
  def user_details
    @user_obj = UserLib.find(RedisAdapter.new.connection.find(session_id))
    render_details
  end

  #TO-DO, other than creating user, add user to respective tenant database -> Do this in one transaction
  def register_user
    @user_obj = UserLib.new(user_creation_params).create_user
    render_details(204)
  end

  def edit_user
    @user_obj = UserLib.find(user_edit_params[:id])
    user_obj.edit_user(user_edit_params)
    render_details(201)
  end

  def delete_user
  end

  def hard_delete_user
  end

  def change_password
  end

  #Send otp to registered email. On successful otp being entered, UI can move to change_password page. On failure, UI can move to login page
  def forgot_password
  end

  private

  def user_creation_params
  end

  def user_edit_params
  end

  def user_password_change_params
  end

  def render_details(status_code=200)
    if status_code != 204
      render json: user_obj.details_as_json, status: status_code
    else
      render json: {}, status:status_code
    end
  end

end
