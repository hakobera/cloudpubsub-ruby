require 'cloudpubsub/client/errors'

module CloudPubSub
  class Client
    include CloudPubSub::Client::Errors

    def initialize(opts={})
      @opts = opts

      @pubsub = client.discovered_api('pubsub', 'v1beta1')
      @cached_client = nil
      @cached_client_expiration = nil
    end

    def create_topic(name)
      data = api(method: @pubsub.topics.create, body: { 'name' => topic(name) })
    end

    def delete_topic(name)
      api(method: @pubsub.topics.delete, parameters: { 'topic' => topic(name) }) == nil
    end

    def get_topic(name)
      api(method: @pubsub.topics.get, parameters: { 'topic' => topic(name) })
    end

    def list_topics(params={})
      params.merge!({'query' => query_for_project()})
      api(method: @pubsub.topics.list, parameters: params)
    end

    def publish(topic, data, labels=[])
      body = {
        'topic' => topic(topic),
        'message' => {
          'data' => data,
          'label' => labels
        }
      }
      api(method: @pubsub.topics.publish, body: body) == nil
    end

    def acknowledge(name, ackIds=[])
      body = {
        'name'  => subscription(name),
        'ackId' => ackIds
      }
      api(method: @pubsub.subscriptions.create, body: body) == nil
    end

    def create_subscription(name, topic, push_endpoint, ack_deadline_seconds=10)
      body = {
        'name'  => subscription(name),
        'topic' => topic(topic),
        'ackDeadlineSeconds' => ack_deadline_seconds,
        'pushConfig' => {
          'pushEndpoint' => push_endpoint
        }
      }
      api(method: @pubsub.subscriptions.create, body: body)
    end

    def delete_subscription(name)
      api(method: @pubsub.subscriptions.delete, parameters: { 'subscription' => subscription(name) }) == nil
    end

    def get_subscription(name)
      api(method: @pubsub.subscriptions.get, parameters: { 'subscription' => subscription(name) })
    end

    def list_subscriptions(topic, params={})
      if topic == :all
        query = query_for_project()
      else
        query = query_for_topic(topic)
      end
      params.merge!({'query' => query})
      api(method: @pubsub.subscriptions.list, parameters: params)
    end

    def modify_ack_deadline(name, ack_id, ack_deadline_seconds)
      body = {
        'name'  => subscription(name),
        'ackId' => ackId,
        'ackDeadlineSeconds' => ack_deadline_seconds
      }
      api(method: @pubsub.subscriptions.modify_ack_deadline, body: body) == nil
    end

    def modify_push_config(name, push_endpoint)
      body = {
        'name'  => subscription(name),
        'pushConfig' => {
          'pushEndpoint' => push_endpoint
        }      
      }
      api(method: @pubsub.subscriptions.modify_push_config, body: body) == nil
    end

    def pull(name, return_immediately=false)
      body = {
        'subscription' => subscription(name),
        'returnImmediately' => return_immediately
      }
      api(method: @pubsub.subscriptions.pull, body: body)
    end

    private

    def client
      return @cached_client if @cached_client && @cached_client_expiration > Time.now

      client = Google::APIClient.new(
        application_name: 'CloudPubSub RubyGems',
        application_version: CloudPubSub::VERSION
      )

      case @opts[:auth_method]
      when 'private_key'
        key = Google::APIClient::PKCS12.load_key(@opts[:private_key_path], @opts[:private_key_passphrase])
        asserter = Google::APIClient::JWTAsserter.new(
          @opts[:email],
          "https://www.googleapis.com/auth/pubsub",
          key
        )
        # refresh_auth
        client.authorization = asserter.authorize

      when 'compute_engine'
        auth = Google::APIClient::ComputeServiceAccount.new
        auth.fetch_access_token!
        client.authorization = auth

      else
        raise "Unknown auth method: #{@opts['auth_method']}"
      end

      @cached_client_expiration = Time.now + 1800
      @cached_client = client
    end

    def api(opts)
      res = client().execute(
        :api_method => opts[:method],
        :parameters => opts[:parameters],
        :body_object => opts[:body]
      )

      data = parse_body(res)
      handle_error(data) if data && is_error?(data)
      data
    end

    def parse_body(response)
      return nil unless response.body && !response.body.empty?
      JSON.parse(response.body)
    end

    def resource_name(collection, name)
      "/#{collection}/#{@opts[:project]}/#{name}"
    end

    def topic(name)
      resource_name('topics', name)
    end

    def subscription(name)
      resource_name('subscriptions', name)
    end

    def query_for_project
      "cloud.googleapis.com/project in (/projects/#{@opts[:project]})"
    end

    def query_for_topic(name)
      "pubsub.googleapis.com/topic in (#{topic(name)})"
    end
  end
end
