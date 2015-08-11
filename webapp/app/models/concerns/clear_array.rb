module ClearArray
  extend ActiveSupport::Concern

  module ClassMethods
    def can_clear_array(array_name)
      accessor = :"clear_#{array_name}"
      attr_accessor accessor

      before_validation do
        should_clear = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(send(accessor))

        if should_clear
          send(:"#{array_name}=", nil)
        end
      end
    end
  end
end
