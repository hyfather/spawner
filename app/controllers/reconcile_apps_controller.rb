class ReconcileAppsController < ApplicationController
  def index
    @reconcile_app = current_user.reconcile_app
  end
end
