class AddTrackerToIssueViewColumns < ActiveRecord::Migration[4.2]
  def up
    add_column :issue_view_columns, :tracker_id, :integer
    add_index :issue_view_columns, [:project_id, :tracker_id], name: 'index_ivc_on_project_and_tracker'
  end

  def down
    execute 'DELETE FROM issue_view_columns WHERE tracker_id IS NOT NULL'
    remove_index :issue_view_columns, name: 'index_ivc_on_project_and_tracker'
    remove_column :issue_view_columns, :tracker_id
  end
end
