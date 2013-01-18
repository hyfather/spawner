class AddUserIdToReconcileApp < ActiveRecord::Migration
  def change
    add_column :reconcile_apps, :user_id, :integer
  end
end
