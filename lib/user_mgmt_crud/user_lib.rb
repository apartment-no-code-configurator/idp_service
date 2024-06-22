require_relative "./../db_adapters/mongodb_adapter.rb"
require_relative "./../authentication/jwt.rb"

module UserMgmtCrud

  class UserLib

    COMMON_COLUMNS = ["telegram_username"].freeze
    private_constant :COMMON_COLUMNS

    include MongoDB

    attr_accessor :user_record, :user_params, :society

    def self.find_user(idp_service_id)
      MongoDBAdapter.run_query(:fetch_record, {_id: idp_service_id}).first.except("password") rescue nil
    end

    def initialize(user_params, society_record = nil)
      @society = society_record
      @user_record = user_params[:id].present? ? User.find_by(id: user_params[:id]) : User.new(set_user_params(user_params))
      @user_params = set_user_params(user_params)
    end

    def create_user(profile_id="resident")
      ActiveRecord::Base.transaction do
        user_record.save!
        user_idp_record = update_user_record_idp_values(profile_id)
        if user_idp_record["_id"].present?
          MongoDBAdapter.run_query(
            :put_edit_record,
            {
              record_filter: {_id: user_idp_record["_id"]},
              record_details: user_idp_record
            }
          )
          user_record.update(idp_service_id: user_idp_record["_id"]) if user_record.idp_service_id.blank?
        else
          MongoDBAdapter.run_query(:create_record, user_idp_record)
          user_record.idp_service_id = MongoDBAdapter.run_query(:fetch_record, {email: user_idp_record["email"]}).first["_id"]
          user_record.save!
        end
      end
    end

    # def register_support_user(aoa_number)
    #   TenantModel.transaction do
    #     user_record.save!
    #     user_idp_record = update_user_record_idp_values(aoa_number)
    #     MongoDBAdapter.run_query(
    #       :put_edit_record,
    #       {
    #         record_filter: {_id: user_idp_record["_id"]},
    #         record_details: user_idp_record
    #       }
    #     )
    #   end
    # end

    def change_password
      MongoDBAdapter.run_query(:patch_edit_record, {record_filter: {"_id": user_record.idp_service_id}, record_details: {password: BCrypt::Password.create(user_params[:password])}})
    end

    def create_session!
      session_id = Token::JsonWebTokenUtils.encode({aoa_number: society.aoa_number, user_id: user_params["id"]})
      store_session_id(session_id, {aoa_number: society.aoa_number, user_id: user_params["id"]})
      session_id
    end

    private

    def update_user_record_idp_values(profile_id)
      #TO-DO: encode password with salt, use a util class for this
      existing_idp_record = MongoDBAdapter.run_query(:fetch_record, {email: user_params["email"] || user_params[:idp_service_details]["email"]}).first
      user_params_idp_details = user_params[:idp_service_details]
      if existing_idp_record.blank?
        {
          "telegram_username" => user_params_idp_details["telegram_username"],
          "first_name" => user_params_idp_details["first_name"],
          "last_name" => user_params_idp_details["last_name"],
          "email" => user_params_idp_details["email"],
          "phone" => user_params_idp_details["phone"],
          "password" => "test",
          "societies" => [
            {
              "aoa_number" => society.aoa_number,
              "profile_id" => profile_id
            }
          ]
        }
      else
        existing_idp_record["telegram_username"] = user_params_idp_details["telegram_username"]
        existing_idp_record["first_name"] = user_params_idp_details["first_name"]
        existing_idp_record["last_name"] = user_params_idp_details["last_name"]
        existing_idp_record["phone"] = existing_idp_record["phone"] || user_params_idp_details["phone"]
        new_society = {
          "aoa_number" => society.aoa_number,
          "profile_id" => profile_id
        }
        existing_idp_record["societies"].push(new_society)
        existing_idp_record
      end
    end

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
