class App
  module Views
    class Layout < Mustache
      def flash_error
        @flash_error
      end

      def flash_success
        @flash_success
      end

      def signed_in?
        @uid.nil? == false
      end
    end
  end
end
