require File.expand_path('../test_helper', __dir__)
require_dependency 'issue_view_columns_issues_helper'

class IssueViewColumnsIssuesHelperTest < ActiveSupport::TestCase
  class CoreRenderer
    def render_descendants_tree(issue)
      :core_descendants
    end

    def render_issue_relations(issue, relations)
      :core_relations
    end
  end

  class PluginRenderer < CoreRenderer
    include IssueViewColumnsIssuesHelper
  end

  def test_disabled_module_delegates_both_tables_without_resolving_columns
    project = mock('project')
    project.expects(:module_enabled?).with(:issue_view_columns).twice.returns(false)
    issue = stub(project: project)
    renderer = PluginRenderer.new
    renderer.expects(:get_fields_for_project).never
    assert_equal :core_descendants, renderer.render_descendants_tree(issue)
    assert_equal :core_relations, renderer.render_issue_relations(issue, [])
  end

  def test_unavailable_fields_use_plugin_defaults
    project = stub('project')
    issue = stub(project: project, project_id: 1, tracker_id: 2)
    columns = IssueViewColumns::DEFAULT_COLUMNS.map { |name| stub(name: name.to_sym) }
    query = mock('query')
    query.expects(:project=).with(project)
    query.expects(:available_inline_columns).returns(columns)
    IssueQuery.expects(:new).returns(query)
    IssueViewColumns.expects(:columns_for).with(1, 2).returns(['cf_999999'])
    assert_equal columns, PluginRenderer.new.send(:get_fields_for_project, issue)
  end
end
