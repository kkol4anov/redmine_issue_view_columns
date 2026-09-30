class IssueViewColumnsController < ApplicationController
  include QueriesHelper
  include IssueViewColumnsHelper
  before_action :find_project_by_project_id
  before_action :authorize
  before_action :build_query_for_project

  def index
    redirect_to settings_project_path(@project, tab: 'issue_view_columns', tracker_id: params[:tracker_id])
  end

  def update
    allowed = @query.available_inline_columns.map { |column| column.name.to_s } - ['tracker']
    columns = Array(params[:c]).map(&:to_s).select { |name| allowed.include?(name) }
    IssueViewColumns.replace_columns!(
      @project, @issue_view_columns_tracker.try(:id), columns,
      inherit: params[:inherit_columns] == '1'
    )
    redirect_to settings_project_path(@project, tab: 'issue_view_columns', tracker_id: @issue_view_columns_tracker.try(:id)),
                notice: l(:label_issue_columns_created_sucessfully)
  end
end
