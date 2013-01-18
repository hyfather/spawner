require 'spec_helper'

describe ReconcileApp do

  it "should belong to a user" do
    user = User.create!(:email => "user@email.com", :password => "password")
    user.skip_confirmation!
    app = ReconcileApp.create!
    app.user = user; app.save!

    app.user.id.should == user.id
    user.reconcile_app.id.should == app.id
  end
  
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

  it "should clone the reconcile app repository from github for pushing to the heroku remote" do
    app = ReconcileApp.create!
    app.heroku = Heroku::API.new(:mock => true)
    app.post_to_heroku

    repository = stub(:repo)
    Git.should_receive(:clone).with("https://github.com/hyfather/reconcileapp.git",
                                    app.name,
                                    :path => "/tmp/reconcile_apps").and_return(repository)
    repository.should_receive(:add_remote).with("heroku",
                                                "git@heroku.com:#{app.name}.git")

    app.reload.clone_from_github

    app.should be_cloned_from_github
  end

  it "should not attempt cloning an app that is already marked as cloned" do
    app = ReconcileApp.create!(:cloned_from_github => true)
    Git.should_not_receive(:clone)
    app.clone_from_github
  end

  it "should push an app to heroku" do
    app = ReconcileApp.create!
    app.heroku = Heroku::API.new(:mock => true)
    app.post_to_heroku

    repository = stub(:repo)
    Git.should_receive(:open).with("/tmp/reconcile_apps/#{app.name}",
                                   :log => Rails.logger).and_return(repository)

    l = ->(){ repository.push(repository.remote("heroku")) }
    repository.should_receive(:chdir, &l)
    repository.should_receive(:remote).and_return(:heroku)
    repository.should_receive(:push).with(:heroku)

    app.heroku.should_receive(:post_ps).with(app.name,
                                             "rake db:migrate")

    app.push_to_heroku

    app.should be_pushed_to_heroku
  end
end
