class CreateAdminTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_tasks do |t|
      t.string :title
      t.string :description
      t.references :project, index: true

      t.timestamps
    end

    add_foreign_key :admin_tasks, :projects, column: :project_id
  end
end
