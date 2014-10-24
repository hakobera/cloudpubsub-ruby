module CloudPubSub
  module Errors
    class CloudPubSubError < StandardError; end
    class NotFound < CloudPubSubError; end
    class AlreadyExists < CloudPubSubError; end
  end
end
