class ReconcileAppsController < ApplicationController
  def index
    @reconcile_app = current_user.reconcile_app
    redirect_to new_reconcile_app_path unless @reconcile_app
  end

  def new
    @reconcile_app = ReconcileApp.new
  end

  def create
    if current_user.reconcile_app
      head :forbidden
    else
      @reconcile_app = current_user.create_reconcile_app
      Resque.enqueue(Deployment, @reconcile_app.id)
      redirect_to reconcile_apps_path
    end
  end
end
