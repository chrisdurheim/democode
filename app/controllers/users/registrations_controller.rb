class Users::RegistrationsController < Devise::RegistrationsController

  append_before_action :authenticate_user!, only: [:manage_users, :create_user, :edit_user, :update_user, :delete_user]
  append_before_action :logged_in_admins_only, only: [:manage_users, :create_user, :edit_user, :update_user, :delete_user]
  append_before_action :not_edit_self, only: [:edit_user, :update_user, :delete_user]
  append_before_action :only_in_same_organization, only: [:edit_user, :update_user, :delete_user]

  # GET /users/
  def manage_users
    @org_users = User.from_organization(current_user.organization_id)
    build_resource({})
    respond_with self.resource
  end

  # POST /users/create_user
  def create_user
    @org_users = User.from_organization(current_user.organization_id)
    @user = new_user_thru_admin
    if @user.save
      flash[:notice] = "User successfully added: #{@user.name}"
      redirect_to manage_users_path
    else
      render :manage_users
    end
  end

  # GET /users/:id/edit
  def edit_user
    @user = User.find_by_id(params[:id])
    @roles = User.valid_roles
    render :edit_user
  end

  # PUT /users/:id
  def update_user
    @user = User.find_by_id(params[:id])
    if @user.update_without_password(user_params)
      flash[:notice] = "User successfully updated: " + @user.name
      redirect_to manage_users_path
    else
      clean_up_passwords @user
      render :edit_user
    end
  end

  # DELETE /users/:id
  def delete_user
    if User.find(params[:id]).destroy
      flash[:notice] = "User successfully deleted"
      redirect_to manage_users_path
    else
      flash[:error] = "Error: User could not be deleted"
      redirect_to manage_users_path
    end
  end

  private
    def user_params
      if params[:user]
        params.require(:user).permit(:user, :name, :email, :password, :password_confirmation, :encrypted_password, :role, :organization_id)
      end
    end

    def new_user_thru_admin(password="TESTPASS")
      new_user_params = user_params
      new_user_params[:organization_id] = current_user.organization_id
      new_user_params[:password] = password
      new_user_params[:password_confirmation] = password
      User.new(new_user_params)
    end

    def logged_in_admins_only
      unless (user_signed_in? && current_user.admin?)
        flash[:error] = "You do not have administrative rights for this organization"
        flash.keep
        redirect_to(root_path)
      end
    end

    def not_edit_self
      if current_user.is_same_user_as?(params[:id])
        flash[:error] = "Please edit your info through this form"
        flash.keep
        redirect_to edit_user_registration_path and return
      end
    end

    def only_in_same_organization
      unless current_user.in_same_organization?(params[:id])
        flash[:error] = "You do not have administrative rights for this user"
        flash.keep
        redirect_to root_path and return
      end
    end
end
