require_relative "./../db_adapters/mongodb_adapter.rb"
require_relative "./../authentication/jwt.rb"

module UserMgmtCrud

  class UserLib

    COMMON_COLUMNS = ["telegram_username"].freeze
    private_constant :COMMON_COLUMNS

    include MongoDB

    attr_accessor :user_record, :user_params, :society

    def initialize(user_params, society_record = nil)
      @society = society_record
      @user_record = user_params[:id].present? ? User.find_by(id: user_params[:id]) : User.new(user_params)
      @user_params = set_user_params(user_params)
    end

    def change_password
      #Instant TO-DO: encrypt password and send to idp
      MongoDBAdapter.run_query(:patch_edit_record, {record_filter: {"_id": user_record.idp_service_id}, record_details: {password: BCrypt::Password.create(user_params[:password])}})
    end

    def create_session!
      session_id = Token::JsonWebTokenUtils.encode({aoa_number: society.aoa_number, user_id: user_params["id"]})
      store_session_id(session_id, {aoa_number: society.aoa_number, user_id: user_params["id"]})
      session_id
    end

    private

    def set_user_params(params)
      idp_service_details = {}
      overall_params = {}
      params.each { |key, value|
        if COMMON_COLUMNS.include?(key)
          overall_params[key] = value
          idp_service_details[key] = value
        elsif User.column_names.include?(key)
          overall_params[key] = value
        else
          idp_service_details[key] = value
        end
      }
      overall_params.merge!({
        idp_service_details:
      })
      overall_params
    end

    def store_session_id(session_id, nesting_hash)
      aoa_number = nesting_hash[:aoa_number]
      user_id = nesting_hash[:user_id]
      Session.store_session_id(session_id, aoa_number, user_id)
    end

  end
end
