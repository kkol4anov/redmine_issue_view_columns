class IssueViewColumns < ActiveRecord::Base
  belongs_to :project
  belongs_to :tracker, optional: true

  # A marker preserves an explicitly empty override; no rows means inheritance.
  EMPTY_COLUMNS = '#'.freeze

  def self.configured_columns(project_id, tracker_id = nil)
    where(project_id: project_id, tracker_id: tracker_id).order(:order, :id).pluck(:ident)
  end

  def self.columns_for(project_id, tracker_id)
    specific = configured_columns(project_id, tracker_id) if tracker_id
    specific.present? ? specific : configured_columns(project_id)
  end

  def self.replace_columns!(project, tracker_id, columns, inherit: false)
    project.with_lock do
      where(project_id: project.id, tracker_id: tracker_id).delete_all
      unless inherit && tracker_id
        names = Array(columns).map(&:to_s).reject { |name| name == 'tracker' }.uniq
        names = [EMPTY_COLUMNS] if names.empty?
        names.each_with_index do |name, index|
          create!(project_id: project.id, tracker_id: tracker_id, ident: name, order: index + 1)
        end
      end
    end
  end
end
