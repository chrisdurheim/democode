require 'spec_helper'

describe Users::RegistrationsController do
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "GET #manage_users" do

    context "as a logged-in admin" do

      before :each do
        my_org = create(:organization)
        current_user = create(:admin, organization: my_org)
        create_list(:user, 5, organization: my_org)
        create_list(:user, 2)
        sign_in current_user
        get :manage_users
      end

      it "populates an array of users for the organization" do
        assigns(:org_users).count.should eq(6)
      end

      it "assigns a new User to @user" do
        assigns(:user).should be_new_record
        assigns(:user).kind_of?(User).should be_true
      end

      it "renders the :manage_users template" do
        response.should render_template :manage_users
      end
    end

    context "as a logged-in non-admin" do
      it "redirects to the home page" do
        sign_in create(:user)
        get :manage_users
        response.should redirect_to root_path
      end
    end

    context "while not logged in" do
      it "redirects to the home page" do
        sign_out :user
        get :manage_users
        response.should redirect_to root_path
      end
    end
  end

  describe "GET #:id/edit" do
    let (:admin_org) { create(:organization)}
    let (:admin_for_test) { create(:admin, organization: admin_org) }
    let (:user_for_test) { create(:user, organization: admin_org) }
    let (:outside_user) { create(:user) }

    context "as a logged-in admin" do

      before :each do
        sign_in admin_for_test
      end

      context "editing another user in his organization" do

        before :each do
          get :edit_user, id: user_for_test
        end

        it "assigns the identified user to @user" do
          assigns(:user).id.should eq(user_for_test.id)
        end

        it "renders the :admin_edit_user template" do
          response.should render_template :edit_user
        end
      end

      context "editing another user outside his organization" do
        it "redirects to the home page" do
          get :edit_user, id: outside_user.id
          response.should redirect_to root_path
        end
      end

      context "editing himself" do
        it "redirects to the current user edit page" do
          get :edit_user, id: admin_for_test.id
          response.should redirect_to edit_user_registration_path
        end
      end
    end

   context "as a logged-in non-admin" do
      it "redirects to the home page" do
        sign_in user_for_test
        get :edit_user, id: admin_for_test.id
        response.should redirect_to root_path
      end
    end

    context "while not logged in" do
      it "redirects to the home page" do
        sign_out :user
        get :edit_user, id: admin_for_test.id
        response.should redirect_to root_path
      end
    end
  end

  describe "PATCH #:id" do
    let (:admin_org) { create(:organization)}
    let (:admin_for_test) { create(:admin, organization: admin_org) }
    let (:user_for_test) { create(:user, organization: admin_org) }
    let (:outside_user) { create(:user) }
    let (:updated_user_params) { attributes_for(:user_thru_admin) }
    let (:updated_admin_params) { attributes_for(:admin_thru_admin) }

    context "as a logged-in admin" do

      before :each do
        sign_in admin_for_test
      end

      context "editing another user in his organization" do

        it "should be successful" do
          patch :update_user, id: user_for_test, user: updated_user_params
          flash[:notice].should have_content("successfully updated")
        end
      end

      context "editing another user outside his organization" do
        it "redirects to the manage users path" do
          patch :update_user, id: outside_user, user: updated_user_params
          flash[:error].should have_content("not have administrative rights")
        end
      end

      context "editing himself" do
        it "redirects to the manage users path" do
          patch :update_user, id: admin_for_test, user: updated_user_params
          flash[:error].should have_content("Please edit your info through this form")
        end
      end
    end

   context "as a logged-in non-admin" do
      it "redirects to the home page" do
        sign_in user_for_test
        patch :update_user, id: admin_for_test.id, user: updated_user_params
        response.should redirect_to root_path
      end
    end

    context "while not logged in" do
      it "redirects to the home page" do
        sign_out :user
        patch :update_user, id: admin_for_test.id, user: updated_user_params
        response.should redirect_to root_path
      end
    end
  end

  describe "POST #" do
    context "as a logged-in admin" do

      context "with valid attributes" do

        before :each do
          sign_in create(:admin)
          @proposed_user_params = attributes_for(:user_thru_admin)
        end

        it "saves the user in the database" do
          expect {
            post :create_user, user: @proposed_user_params
          }.to change(User,:count).by(1)
        end
        it "redirects to the manage_users page" do
          post :create_user, user: @proposed_user_params
          response.should redirect_to manage_users_path
        end
      end

      context "with invalid attributes" do
        before :each do
          sign_in create(:admin)
          @proposed_user_params = attributes_for(:user_thru_admin, name: "")
        end
        it "does not save the user in the database" do
          expect {
            post :create_user, user: @proposed_user_params
          }.to_not change(User,:count)
        end
        it "re-renders the :manage_users template" do
          post :create_user, user: @proposed_user_params
          response.should render_template :manage_users
        end
      end
    end

    context "as a logged-in non-admin" do
      before :each do
        sign_in create(:user)
        @proposed_user_params = attributes_for(:user_thru_admin)
      end

      it "does not save the user in the database" do
        expect {
          post :create_user, user: @proposed_user_params
        }.to_not change(User,:count)
      end
      it "redirects to the home page" do
        post :create_user, user: @proposed_user_params
        response.should redirect_to root_path
      end
    end

    context "while not logged in" do
      before :each do
        sign_out :user
        @proposed_user_params = attributes_for(:user_thru_admin)
      end

      it "does not save the user in the database" do
        expect {
          post :create_user, user: @proposed_user_params
        }.to_not change(User,:count)
      end
      it "redirects to the home page" do
        post :create_user, user: @proposed_user_params
        response.should redirect_to root_path
      end
    end

  end

  describe "DELETE #:id" do
    let! (:admin_org) { create(:organization)}
    let! (:admin_for_test) { create(:admin, organization: admin_org) }
    let! (:user_for_test) { create(:user, organization: admin_org) }
    let! (:outside_user) { create(:user) }

    context "as a logged-in admin" do

      before :each do
        sign_in admin_for_test
      end

      context "deleting a user from his own organization" do
        it "deletes the user from the database" do
          expect {
            delete :delete_user, id: user_for_test.id
          }.to change(User,:count).by(-1)
        end

        it "redirects to the manage_users page" do
          delete :delete_user, id: user_for_test.id
          response.should redirect_to manage_users_path
        end
      end

      context "deleting another user outside his organization" do
        it "redirects to the manage users path" do
          delete :delete_user, id: outside_user
          flash[:error].should have_content("not have administrative rights")
        end
      end

      context "deleting himself" do
        it "redirects to the edit users path" do
          delete :delete_user, id: admin_for_test
          flash[:error].should have_content("Please edit your info through this form")
        end
      end
    end

    context "as a logged-in non-admin" do
      before :each do
        sign_in user_for_test
      end

      it "does not save the user in the database" do
        expect {
          delete :delete_user, id: admin_for_test.id
        }.to_not change(User,:count)
      end
      it "redirects to the home page" do
        delete :delete_user, id: admin_for_test.id
        response.should redirect_to root_path
      end
    end

    context "while not logged in" do
      before :each do
        sign_out :user
      end

      it "does not save the user in the database" do
        expect {
          delete :delete_user, id: user_for_test.id
        }.to_not change(User,:count)
      end
      it "redirects to the home page" do
        delete :delete_user, id: user_for_test.id
        response.should redirect_to root_path
      end
    end

  end

end
