class IssueViewColumnsHeadHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = {})
    project = context[:project]
    return '' unless project && project.module_enabled?(:issue_view_columns)

    stylesheet_link_tag('issue_view_columns', plugin: 'redmine_issue_view_columns') +
      javascript_include_tag('issue_view_columns_layout', plugin: 'redmine_issue_view_columns')
  end
end
