class ProfileDecorator < ApplicationDecorator
  delegate_all

  def age
    object.age.present? ? t('.years_old', years: object.age) : nil
  end

  def gender
    t(".#{object.gender}")
  end

  def height
    object.height? ? t('.height', height: object.height) : nil
  end

  def weight
    object.weight? ? t('.weight', weight: object.weight) : nil
  end
end
