class Deployment
  @queue = :deploy_app

  def self.perform(reconcile_app_id)
    app = ReconcileApp.find(reconcile_app_id)
    app.install
  end
end
