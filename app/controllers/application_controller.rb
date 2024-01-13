require 'authentication/jwt.rb'
require 'db_adapters/cache_adapter.rb'
require 'db_adapters/mongodb_adapter.rb'

class ApplicationController < ActionController::API

  include Token
  include MongoDB
  include CacheAdapter

  attr_accessor :society, :user_details

  before_action :set_society_singletons_and_tenant_model_connection #ideally should be in a middleware

  private

  def symbolized_params(require_key="")
    if require_key.blank?
      params
    else
      params.require(require_key)
    end
  end

  def set_society_singletons_and_tenant_model_connection
    begin
      subdomain_segments = request.subdomain.split("-")
      @society = Society.find_by(link: subdomain_segments.first.to_s)
      # $logger = #TO-DO: Setup up and use logger

      #TO-DO: Get values from environment variables like database.yml
      TenantModel.establish_connection({adapter: "mysql2",pool: 5, username: "root", password: "Kankroli@e11",socket: "/tmp/mysql.sock", database: "#{society.db_prefix}_db"})
    rescue
      raise "Society not found"
    end
  end

  def check_if_user_can_access_society
    aoa_number = society.aoa_number
    user_details["societies"].pluck("aoa_number").include?(aoa_number) && User.find_by(idp_service_id: user_details["_id"]).id rescue false
  end

end
