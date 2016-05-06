ActiveAdmin.register User do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

actions :index

filter :nickname
filter :mobile
filter :private_token
filter :created_at

scope 'all', default: true do |users|
  users.no_delete
end

scope '正常用户', :verified do |users|
  users.no_delete.verified
end

index do
  selectable_column
  column :id
  column :nickname, sortable: false
  column :avatar, sortable: false do |u|
    u.avatar.blank? ? "" : image_tag(u.avatar.url(:small))
  end
  column :mobile, sortable: false
  column 'Token', sortable: false do |u|
    u.private_token
  end
  column :verified, sortable: false
  column :created_at
  
  actions defaults: false do |u|
    if u.verified
      item "禁用", block_admin_user_path(u), method: :put
    else
      item "启用", unblock_admin_user_path(u), method: :put
    end
  end
end

# 批量禁用账号
batch_action :block do |ids|
  batch_action_collection.find(ids).each do |user|
    user.block!
  end
  redirect_to collection_path, alert: "已经禁用"
end

# 批量启用账号
batch_action :unblock do |ids|
  batch_action_collection.find(ids).each do |user|
    user.unblock!
  end
  redirect_to collection_path, alert: "已经启用"
end

member_action :block, method: :put do
  resource.block!
  redirect_to admin_users_path, notice: "已禁用"
end

member_action :unblock, method: :put do
  resource.unblock!
  redirect_to admin_users_path, notice: "取消禁用"
end

end