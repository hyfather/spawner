class ReconcileApp < ActiveRecord::Base
  attr_accessible :cloned_from_github, :name, :posted_to_heroku, :pushed_to_heroku, :url, :version

  def install
    post_to_heroku
    clone_from_github
    push_to_heroku
  end
  
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

  def clone_from_github
    if cloned_from_github?
      Rails.logger.warn("Skipped cloning of app #{name} from github. Is this an error?")
      return
    end
    
    code_url = "https://github.com/hyfather/reconcileapp.git"
    projects_root = File.join("/", "tmp", "reconcile_apps")
    repo = Git.clone(code_url, name, :path => projects_root)
    repo.add_remote("heroku", "git@heroku.com:#{name}.git")

    self[:cloned_from_github] = true
    self.save
  end

  def push_to_heroku
    projects_root = File.join("/", "tmp", "reconcile_apps")
    git = Git.open(File.join(projects_root, name), :log => Rails.logger)
    git.chdir do
      git.push(git.remote("heroku"))
    end
    heroku.post_ps(name, "rake db:migrate")

    self[:pushed_to_heroku] = true
    self.save
  end
  
  def heroku
    @heroku ||= Heroku::API.new
  end

  def heroku=(hk)
    @heroku = hk
  end
end
