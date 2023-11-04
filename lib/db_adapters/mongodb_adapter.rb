require 'mongo'

module MongoDB
  class MongoDBAdapter

    def self.run_query(query_type, params)
      begin
        client.use('admin')
        send(query_type, params)
        client.close
      rescue => e
        raise e
      end
    end

    private

    def self.setup_client
      uri = "mongodb+srv://admin:<password>@doc-automater-dev.flpvo.mongodb.net/?retryWrites=true&w=majority" #TO-DO: Get from environment variables
      options = { server_api: {version: "1"} }#TO-DO: Get from environment variables
      @client = Mongo::Client.new(uri, options)
      @client
    end

    def client
      @client || setup_client
    end

    #adapter methods
    def self.create_record(record_details)
    end

    def self.fetch_record(record_id)
    end

    def self.put_edit_record(record_details) #like PUT request, all details for the record are to be given, even for application/society revoke
    end

    def self.patch_edit_record(record_details) #like PATCH request, exact details are to be given, even for application/society revoke
    end

    def self.delete_record(record_id)
    end



  end
end
