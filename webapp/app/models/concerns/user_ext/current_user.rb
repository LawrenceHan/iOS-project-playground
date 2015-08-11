module UserExt
  module CurrentUser
    extend ActiveSupport::Concern

    module ClassMethods
      def current_user_id
        Thread.current[:current_user_id]
      end

      def current_user_id=(new_user_id)
        Thread.current[:current_user_id] = new_user_id
      end
    end
  end
end
