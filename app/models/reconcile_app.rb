class ReconcileApp < ActiveRecord::Base
  attr_accessible :cloned_from_github, :name, :posted_to_heroku, :pushed_to_heroku, :url, :version

  def post_to_heroku
    if posted_to_heroku?
      Rails.logger.warn("Skipped posting of app #{name} to heroku since it already exists. Is this an error?")
      return
    end
    response = heroku.post_app
    Rails.logger.info(response)
    if response.status == 202
      self[:name] = response.body["name"]
      self[:posted_to_heroku] = true
      self.save
    end
  end
  
  def heroku
    @heroku ||= Heroku::API.new
  end

  def heroku=(hk)
      @heroku = hk
  end
end
