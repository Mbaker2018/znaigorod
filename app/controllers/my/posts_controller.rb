class My::PostsController < My::ApplicationController
  load_and_authorize_resource
  custom_actions :resource => [:poster, :send_to_published, :send_to_draft]

  def index
    @posts = PostDecorator.decorate(current_user.account.posts)
    render :partial => 'posts/post_posters', :layout => false and return if request.xhr?
  end

  def show
    show!{
      @post = PostDecorator.new(@post)
    }
  end

  def update
    update! do |success, failure|
      success.html {
        if params[:crop]
          redirect_to poster_my_post_path(resource)
        else
          redirect_to my_post_path(resource)
        end
      }

      failure.html {
        render :poster and return if params[:crop]

        render :edit
      }
    end
  end

  def destroy
    destroy! {
      render :json => Posts::MyCounters.new(current_user.account).counters  and return if request.xhr?

      my_root_path
    }
  end

  def send_to_published
    @post = current_user.account.posts.available_for_edit.find(params[:id])
    @post.to_published!

    redirect_to post_path(@post), :notice => "Обзор «#{@post.title}» опубликован."
  end

  def send_to_draft
    @post = current_user.account.posts.available_for_edit.find(params[:id])
    @post.to_draft!

    redirect_to my_post_path(@post), :notice => "Обзор «#{@post.title}» возвращен в черновики."
  end

  def available_tags
    render :json => Posts::Tags.new(params[:term]).tags.to_json
  end

  def preview
    post = Post.new(params[:post])

    render :partial => 'posts/post_show', :locals => { :post => PostDecorator.new(post), :for_preview => true }
  end

  def link_with
    render :json => Posts::LinkWithAutocomplete.new(params[:term]).json
  end

  protected

  def begin_of_association_chain
    current_user.account
  end
end
