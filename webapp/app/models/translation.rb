class Translation < ActiveRecord::Base
  belongs_to :field_translation,
    :polymorphic => true,
    :foreign_key => :entity_id,
    :foreign_type => :entity_type
end
