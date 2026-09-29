require File.expand_path('../test_helper', __dir__)

class IssueViewColumnsTest < ActiveSupport::TestCase
  fixtures :projects, :trackers

  def setup
    @project = Project.find(1)
    @tracker = Tracker.first
    IssueViewColumns.where(project_id: @project.id).delete_all
    IssueViewColumns.replace_columns!(@project, nil, %w[subject status])
  end

  def test_existing_project_columns_are_inherited
    assert_equal %w[subject status], IssueViewColumns.columns_for(@project.id, @tracker.id)
  end

  def test_tracker_override_preserves_order_and_project_default
    IssueViewColumns.replace_columns!(@project, @tracker.id, %w[priority subject])
    assert_equal %w[priority subject], IssueViewColumns.columns_for(@project.id, @tracker.id)
    assert_equal %w[subject status], IssueViewColumns.configured_columns(@project.id)
    other_tracker = Tracker.where.not(id: @tracker.id).first
    assert_equal %w[subject status], IssueViewColumns.columns_for(@project.id, other_tracker.id)
  end

  def test_restoring_inheritance_removes_only_tracker_override
    IssueViewColumns.replace_columns!(@project, @tracker.id, ['priority'])
    IssueViewColumns.replace_columns!(@project, @tracker.id, [], inherit: true)
    assert_empty IssueViewColumns.configured_columns(@project.id, @tracker.id)
    assert_equal %w[subject status], IssueViewColumns.columns_for(@project.id, @tracker.id)
  end

  def test_empty_override_does_not_inherit_project_columns
    IssueViewColumns.replace_columns!(@project, @tracker.id, [])
    assert_equal [IssueViewColumns::EMPTY_COLUMNS], IssueViewColumns.columns_for(@project.id, @tracker.id)
  end

  def test_subject_is_saved_and_tracker_is_excluded
    IssueViewColumns.replace_columns!(@project, @tracker.id, %w[tracker subject subject status])
    assert_equal %w[subject status], IssueViewColumns.columns_for(@project.id, @tracker.id)
  end

  def test_other_project_is_unchanged
    other_project = Project.where.not(id: @project.id).first
    IssueViewColumns.replace_columns!(other_project, @tracker.id, ['assigned_to'])
    IssueViewColumns.replace_columns!(@project, @tracker.id, ['priority'])
    assert_equal ['assigned_to'], IssueViewColumns.columns_for(other_project.id, @tracker.id)
  end

  def test_failed_save_rolls_back_deleted_columns
    IssueViewColumns.stubs(:create!).raises(ActiveRecord::RecordInvalid.new(IssueViewColumns.new))
    assert_raises(ActiveRecord::RecordInvalid) do
      IssueViewColumns.replace_columns!(@project, nil, ['priority'])
    end
    assert_equal %w[subject status], IssueViewColumns.configured_columns(@project.id)
  end
end
