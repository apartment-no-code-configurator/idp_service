require 'jwt'
#TO-DO: Add openssl methods to encrypt and decrypt strings using alogirthms like sha-256
module Token
  #TO-DO: Change to RS512 algorithm
  class JsonWebTokenUtils

    def self.decode(token, other_secret=false)
      to_use_secret = other_secret ? request_details_secret : secret
      JWT.decode token, secret, true, { algorithm: 'HS256' }
    end

    def self.encode(user_details, other_secret=false)
      to_use_secret = other_secret ? request_details_secret : secret
      JWT.encode user_details, secret, 'HS256'
    end

    private

    #TO-DO: Read from environment
    def self.secret
      "something"
    end

    def self.request_details_secret
      "something"
    end

  end
end
