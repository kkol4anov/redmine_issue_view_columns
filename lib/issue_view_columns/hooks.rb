class IssueViewColumnsHeadHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = {})
    stylesheet_link_tag('issue_view_columns', plugin: 'redmine_issue_view_columns')
  end
end
