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
    end
  end
end
