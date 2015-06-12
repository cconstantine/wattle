require 'spec_helper'

describe SessionsController, :type => :controller do
  describe "create" do
    it "should read auth data from the session environment" do
      request.env['omniauth.auth'] = {info: {email: "test@example.com"}}
      get :create, provider: "gplus"
      expect(response).to redirect_to(root_path)
      expect(session[:watcher_id]).to eq watchers(:default).to_param
    end
  end

  describe "destroy" do
    before do
      request.env['omniauth.auth'] = {info: {email: "test@example.com"}}
      get :create, provider: "gplus"
    end

    it "should read auth data from the session environment" do
      request.env['omniauth.auth'] = {info: {email: "test@example.com"}}
      get :delete
      expect(response).to redirect_to(root_path)
      expect(session[:watcher_id]).to eq nil
    end
  end
end
