class IssueViewColumns < ActiveRecord::Base
  belongs_to :project
  belongs_to :tracker, optional: true

  DEFAULT_COLUMNS = %w[subject status done_ratio start_date].freeze
  # Ignore the legacy empty-set marker: empty sets now inherit.
  EMPTY_COLUMNS = '#'.freeze

  def self.normalize_columns(columns)
    Array(columns).map(&:to_s).reject { |name| name.blank? || [EMPTY_COLUMNS, 'tracker'].include?(name) }.uniq
  end

  def self.global_columns
    columns = normalize_columns(Setting.plugin_redmine_issue_view_columns['issue_view_default_columns'])
    columns.presence || DEFAULT_COLUMNS.dup
  end

  def self.configured_columns(project_id, tracker_id = nil)
    normalize_columns(where(project_id: project_id, tracker_id: tracker_id).order(:order, :id).pluck(:ident))
  end

  def self.columns_for(project_id, tracker_id = nil)
    specific = configured_columns(project_id, tracker_id) if tracker_id
    specific.presence || configured_columns(project_id).presence || global_columns
  end

  def self.replace_columns!(project, tracker_id, columns, inherit: false)
    project.with_lock do
      where(project_id: project.id, tracker_id: tracker_id).delete_all
      unless inherit
        normalize_columns(columns).each_with_index do |name, index|
          create!(project_id: project.id, tracker_id: tracker_id, ident: name, order: index + 1)
        end
      end
    end
  end
end
