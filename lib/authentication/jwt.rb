require 'jwt'

module Token
  #TO-DO: Change to RS512 algorithm
  class JsonWebTokenUtils

    def self.decode(token)
      JWT.decode token, secret, true, { algorithm: 'HS256' }
    end

    def self.encode(user_details)
      JWT.encode user_details, secret, 'HS256'
    end

    private

    #TO-DO: Read from environment
    def self.secret
      "something"
    end

  end
end
