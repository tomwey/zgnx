module API
  module V1
    class CategoriesAPI < Grape::API
      
      resource :types do
        desc "获取所有的类别"
        get do
          @types = Category.sorted.recent
          render_json(@types, API::V1::Entities::Category)
        end # end get
      end # end resource types
      
    end # end class
  end # end V1
end # end API