module IssueViewColumnsHelper
  include QueriesHelper

  def build_query_for_project
    @issue_view_columns_tracker = if params[:tracker_id].present?
                                   @project.trackers.find(params[:tracker_id])
                                 end
    tracker_id = @issue_view_columns_tracker.try(:id)
    specific = IssueViewColumns.configured_columns(@project.id, tracker_id)
    @issue_view_columns_inherit = specific.empty?
    @selected_columns = IssueViewColumns.columns_for(@project.id, tracker_id)
    @query = IssueQuery.new(column_names: @selected_columns)
    @query.project = @project
    @query
  end
end
