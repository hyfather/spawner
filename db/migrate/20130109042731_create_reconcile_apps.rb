class CreateReconcileApps < ActiveRecord::Migration
  def change
    create_table :reconcile_apps do |t|
      t.string :name
      t.string :url
      t.string :version
      t.boolean :posted_to_heroku
      t.boolean :cloned_from_github
      t.boolean :pushed_to_heroku

      t.timestamps
    end
  end
end
