require 'spec_helper'

describe ReconcileAppsController do

  before(:each) do
    @user = User.create(:email => "user@email.com", :password => "password")
    @user.confirm!
    sign_in @user
  end

  it "should list out any app that the user may already have" do
    app = ReconcileApp.create!
    app.user = @user; app.save!

    get :index

    assigns[:reconcile_app].id.should == app.id
    response.should be_success
  end

  it "should redirect index to new if the user doesn't have an app" do
    get :index
    response.should redirect_to new_reconcile_app_path
  end

  it "should make a new reconcile app for populating the form" do
    get :new
    assigns[:reconcile_app].should_not be_persisted
  end

  it "should create a new reconcile app for the current user" do
    post :create
    response.should redirect_to reconcile_apps_path
    @user.reconcile_app.should_not be_nil
  end

  it "should not create a new reconcile app for the current user if they already have one" do
    app = ReconcileApp.create!
    app.user = @user; app.save!

    post :create
    response.code.should == "403"
  end



end
