require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#index action" do
    it "should successfully show the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "gramse#new action" do
    it "should require user to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path 
    end 

    it "should successfully show the new form" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "shouldn't let unauthenticated  users create a gram" do 
      post :create, gram: {message: 'Hello'}
      expect(response).to redirect_to new_user_session_path
    end

    it "Should successfully create a gram in our database" do 
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: {
        message: 'Hello!',
        picture: fixture_file_upload("/picture.png", 'image/png')
      }

      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq('Hello!')
      expect(gram.user).to eq(user)
    end 

    it "should properly deal with validation errors" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: {message: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq 0
      expect(response).to render_template(:new)
    end
  end

  describe "grams@show action" do
    it "Should successfully show the page if the gram is found" do
      gram = FactoryGirl.create(:gram)
      get :show, id: gram.id
      expect(response).to have_http_status(:success)
      expect(assigns(:gram)).to eq gram 
    end

    it "Should return a 404 error if a gram isn't found" do
      get :show, id: 'TACOCAT'
      expect(response).to have_http_status(:not_found)
    end 
  end 

  describe "grams@edit action" do
    it "shouldn't let a user who didn't create the gram edit the gram" do 
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      get :edit, id: gram.id
      expect(response).to have_http_status(:forbidden)
    end 

    it "shouldn't let unauthenticated users edit grams" do
      gram = FactoryGirl.create(:gram)
      get :edit, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end 

    it "Should successfully show the edit form if the gram is found" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user
      get :edit, id: gram.id
      expect(response).to have_http_status(:success)
    end 

    it "Should return a 404 message if the gram is not found" do 
      u = FactoryGirl.create(:user)
      sign_in u 
      get :edit, id: 'TACOCAT'
      expect(response).to have_http_status(:not_found)
    end   
  end

  describe "grams@update action" do
    it "shouldn't let users who didn't create the gram update it" do 
      p = FactoryGirl.create(:gram)
      u = FactoryGirl.create(:user)
      sign_in u

      patch :update, id: p.id, gram: {message: 'wahoo'}
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't allow unauthenticated users to update grams" do
      p = FactoryGirl.create(:gram)
      patch :update, id: p.id, gram: {message: 'Hello'}
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow users to successfully update grams" do
      p = FactoryGirl.create(:gram, message: "Intial Value")
      sign_in p.user
      patch :update, id: p.id, gram: { message: 'Changed'}
      expect(response).to redirect_to root_path
      p.reload
      expect(p.message).to eq 'Changed'
    end

    it "should have a 404 error if a gram isn't found" do 
      u = FactoryGirl.create(:user)
      sign_in u
      patch :update, id: "YOLOSWAG", gram: {message: 'Changed'}
      expect(response).to have_http_status(:not_found)
    end 

    it "should render the edit form with an http status of unprocessable_entity" do 
      p = FactoryGirl.create(:gram, message: "Initial Value")
      sign_in p.user
      patch :update, id: p.id, gram: { message: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      p.reload
      expect(p.message).to eq "Initial Value"
    end
  end 


  describe "grams@destroy action" do
    it "shouldn't allow users who didn't create the gram destroy it" do
      p = FactoryGirl.create(:gram)
      u = FactoryGirl.create(:user)
      sign_in u

      delete :destroy, id: p.id
      expect(response).to have_http_status(:forbidden)
    end

    it "Shouldn't let unauthenticated users destroy grams" do
      p = FactoryGirl.create(:gram) 
      delete :destroy, id: p.id
      expect(response).to redirect_to new_user_session_path
    end

    it "Should allow users to destroy grams" do
      p = FactoryGirl.create(:gram)
      sign_in p.user
      delete :destroy, id: p.id
      expect(response).to redirect_to root_path
      p = Gram.find_by_id(p.id)
      expect(p).to eq nil
    end 

    it "Should return a 404 error message if a gram with the specified id cannot be found" do
      u = FactoryGirl.create(:user)
      sign_in u
      delete :destroy, id: 'SPACEDUCK'
      expect(response).to have_http_status(:not_found)
    end
  end
end
