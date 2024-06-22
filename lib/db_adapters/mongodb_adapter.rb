require 'mongo'

module MongoDB
  class MongoDBAdapter

    def self.run_query(query_type, params, db_collection_details={})
      begin
        @database = db_collection_details.blank? ? "idp_users" : db_collection_details["database"]
        @collection = db_collection_details.blank? ? "users" : db_collection_details["collection"]
        value = send(query_type, params)
        close_connection
        value
      rescue => e
        raise e
      end
    end

    private

    def self.close_connection
      client.close
    end

    def self.setup_client
      #TO-DO: Get from environment variables
      uri = "mongodb+srv://admin:Kankroli_e11@cluster0.djdq0y8.mongodb.net/#{database}?retryWrites=true&w=majority"
      options = { server_api: {version: "1"} } #TO-DO: Get from environment variables
      @client = Mongo::Client.new(uri, options)
      @client.use('admin')
      @client
    end

    def self.client
      @client || setup_client
    end

    def self.collection
      @collection
    end

    def self.database
      @database
    end

    def self.query_runner
      client[collection]
    end

    #adapter methods
    def self.create_record(record_details)
      query_runner.insert_one(record_details)
    end

    def self.fetch_record(record_filter)
      results = []
      query_runner.find(record_filter).each { |record|
        results.push(record)
      }
      results
    end

    def self.put_edit_record(params) #like PUT request, all details for the record are to be given, even for application/society revoke
      record_filter = params[:record_filter]
      record_details = params[:record_details]
      if fetch_record(record_filter).blank?
        create_record(record_details)
      else
        patch_edit_record(params)
      end
    end

    def self.patch_edit_record(params) #like PATCH request, exact details are to be given, even for application/society revoke
      record_filter = params[:record_filter]
      record_details = fetch_record(record_filter).first.merge!(params[:record_details])
      query_runner.find_one_and_update(record_filter, record_details)
    end

    def self.delete_record(record_filter, type_of_delete="one")
      record_filter = params[:record_filter]
      type_of_delete = params[:type_of_delete].present? ? params[:type_of_delete] : "one"
      query_runner.send("delete_#{type_of_delete}", [record_filter])
    end



  end
end

# {"_id":"6592b0da7012032187985b42","telegram_username":"aybalago","first_name":"Ayyappadas","last_name":"Balagopal","email":"ayyapab@gmail.com","phone":["+91 9740931120","+91 8044269481"],"societies":[{"aoa_number":"f028h08f","profile_id":"Support"}]}
# {"_id":"6592b07b7012032187985b41","telegram_username":"roshan_basu_7","first_name":"Roshan","last_name":"Basu","email":"roshanbasu7@gmail.com","phone":["+91 7219612108","+91 9790086117"],"societies":[{"aoa_number":"f028h08f","profile_id":"Support"}],"password":"$2a$12$MCmR/ecuFjdU45n2SrOyRO5p.YBt2X52DMRU5QYURlWT6QN70bZ7q"}
