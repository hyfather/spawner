require 'spec_helper'

describe ReconcileAppsController do

  it "should list out any app that the user may already have" do
    @user = User.create(:email => "user@email.com", :password => "password")
    @user.confirm!
    sign_in @user
    app = ReconcileApp.create!
    app.user = @user; app.save!
    
    get :index

    assigns[:reconcile_app].id.should == app.id
    response.should be_success
  end

  
end
