require 'spec_helper'

describe ReconcileApp do
  
  it "should post an app to heroku if it hasn't been posted" do
    app = ReconcileApp.create!
    app.heroku = Heroku::API.new(:mock => true)

    app.post_to_heroku

    app.name.should_not be_nil
    app.should be_posted_to_heroku
  end

  it "should not repost an app to heroku if it has been posted" do
    app = ReconcileApp.create!
    app.posted_to_heroku = true
    app.save; app.reload
    
    app.heroku = :mock

    lambda { app.post_to_heroku }.should_not raise_error
  end
end
