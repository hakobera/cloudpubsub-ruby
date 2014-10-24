module CloudPubSub
  class Client
    module Errors
      def is_error?(response)
        !response["error"].nil?
      end

      def handle_error(response)
        error = response['error']
        case error['code']
        when 404
          fail CloudPubSub::Errors::NotFound, error['message']
        when 409
          fail CloudPubSub::Errors::AlreadyExists, error['message']
        else
          fail CloudPubSub::Errors::CloudPubSubError, error['message']
        end
      end
    end
  end
end
