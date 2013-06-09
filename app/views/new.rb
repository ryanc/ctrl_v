class App
  module Views
    class New < Layout
      def flash_error
      end

      def flash_success
      end

      def paste
        @paste.content unless @paste.nil?
      end
    end
  end
end
