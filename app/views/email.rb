class App
  module Views
    class Email < Mustache
      def user
        @user
      end

      def ip_addr
        @ip_addr
      end
    end
  end
end
