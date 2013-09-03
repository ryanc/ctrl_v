class App
  module Views
    class Email < Mustache
      def user
        @user
      end

      def recipient
        @user.name || @user.username
      end

      def username
        @user.username
      end

      def ip_addr
        @ip_addr
      end

      def activation_token
        @user.activation_token
      end

      def base_url
        unless [443, 80].include? @request.port
          "#{@request.scheme}://#{@request.host}:#{@request.port}"
        else
          "#{@request.scheme}://#{@request.host}"
        end
      end
    end
  end
end
