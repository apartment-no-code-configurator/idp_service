require 'lib/authentication/jwt.rb'
require 'lib/db_adapters/cache_adapter.rb'
require 'lib/db_adapters/mongodb_adapter.rb'

class ApplicationController < ActionController::API

  include Token
  include MongoDB
  include CacheAdapters

  before_action :set_society_singletons_and_tenant_model_connection #ideally should be in a middleware

  private

  def set_society_singletons_and_tenant_model_connection

    subdomain_segments = request.subdomain.split("-")
    @society = Society.find_by(link: subdomain_segments.first) rescue raise StandardError.new("Society not found")
    @app = App.find_by(name: subdomain_segments.second, society_id: @society.id) rescue raise StandardError.new("App not found")
    # $logger = #TO-DO: Setup up and use logger

    #TO-DO: Get values from environment variables like database.yml
    TenantModel.establish_connection({adapter: "mysql2",pool: 5, username: "root", password: "Kankroli@e11",socket: "/tmp/mysql.sock", database: "test_apartment_db"})
  end

end
