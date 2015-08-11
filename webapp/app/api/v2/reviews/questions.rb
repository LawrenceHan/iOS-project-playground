module V2::Reviews
  module Questions
    class API < Grape::API
      resource :questions do
        desc 'Return questions matched by params[:category]'
        params do
          requires :category, type: String, regexp: /^hospital|physician|medication$/, desc: 'possible values: hospital|physician|medication'
          optional :page, type: Integer, desc: 'page number'
        end
        get do
          say_succeed Question.where('category = ?', params[:category]).page(params[:page]).each { |q|
            q.options.each { |o|
              o[0] = I18n.t(o.first)
            } if q.options
          }
        end
      end
    end
  end
end
