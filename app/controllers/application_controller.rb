require 'authentication/jwt.rb'
require 'db_adapters/cache_adapter.rb'
require 'db_adapters/mongodb_adapter.rb'

class ApplicationController < ActionController::API

  include Token
  include MongoDB
  include CacheAdapter

  attr_accessor :society, :user_details

  private

  def symbolized_params(require_key="")
    if require_key.blank?
      params
    else
      params.require(require_key)
    end
  end

  def set_society_singletons_and_tenant_model_connection_for_ui_requests
    begin
      subdomain_segments = request.subdomain.split("-")
      @society = Society.find_by(link: subdomain_segments.first.to_s)
      # $logger = #TO-DO: Setup up and use logger

      tenant_establish_connnection
    rescue
      raise "Society not found"
    end
  end

  def tenant_establish_connnection
    #TO-DO: Get values from environment variables like database.yml
    TenantModel.establish_connection({adapter: "mysql2",pool: 5, username: "root", password: "Kankroli@e11",socket: "/tmp/mysql.sock", database: "#{society.db_prefix}_db"})
  end

  def check_if_user_can_access_society
    @society = Society.find_by(aoa_number: params[:aoa_number])
    aoa_number = society.aoa_number
    tenant_establish_connnection
    user_details["societies"].pluck("aoa_number").include?(aoa_number) && User.find_by(idp_service_id: user_details["_id"].to_s).id rescue false
  end

end
