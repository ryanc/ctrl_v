class App
  module Views
    class Layout < Mustache
      def flash_error
        return false unless @flash[:error]
        { :message => @flash[:error] }
      end

      def flash_success
        return false unless @flash[:success]
        { :message => @flash[:success] }
      end

      def signed_in?
        @uid.nil? == false
      end
    end
  end
end
