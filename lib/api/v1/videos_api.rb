module API
  module V1
    class VideosAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :videos, desc: '视频推荐接口' do
        desc "获取推荐视频列表"
        params do
          optional :cid,   type: Integer, desc: "类别ID, 如果不传该参数，默认返回所有的视频"
          optional :token, type: String,  desc: "如果用户登陆，那么需要传人认证Token"
          use :pagination
        end
        get do
          @videos = Video.sorted.hot.recent
          
          if params[:cid]
            @videos = @videos.where(category_id: params[:cid])
          end
          
          @videos = @videos.paginate(page: params[:page], per_page: page_size) if params[:page]
          
          user = params[:token].blank? ? nil : User.find_by(private_token: params[:token])

          render_json(@videos, API::V1::Entities::Video, { user: user })
        end # end get videos
        
        desc "上传视频"
        params do 
          requires :token,       type: String,  desc: "用户认证Token"
          optional :category_id, type: Integer, desc: "类别ID"
          requires :title,       type: String,  desc: "视频标题"
          optional :body,        type: String,  desc: "视频简介"
          requires :video,       type: Rack::Multipart::UploadedFile, desc: "视频二进制文件, 视频格式为：mp4,mov,3gp,avi,mpeg"
          requires :cover_image, type: Rack::Multipart::UploadedFile, desc: "图片二进制文件, 视频格式为：jpg,jpeg,gif,png"
        end
        post do
          user = authenticate!
          
          category_id = params[:category_id].blank? ? 3 : params[:category_id].to_i
          category = Category.find_by(id: category_id)
          if category.blank?
            return render_error(4004, '没有该类别')
          end
          
          @video = Video.new(user_id: user.id, 
                             title: params[:title], 
                             file: params[:video], 
                             category_id: params[:category_id],
                             cover_image: params[:cover_image],
                             body: params[:body])
          if @video.save
            render_json(@video, API::V1::Entities::Video)
          else
            render_error(6001, @video.errors.full_messages.join(','))
          end
        end # end post
        
      end # end resource
    end
  end
end