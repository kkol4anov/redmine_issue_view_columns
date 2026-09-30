module IssueViewColumnsIssuesHelper
  def render_descendants_tree(issue)
    columns_list = get_fields_for_project(issue)
    # No fields defined, use default rendering from core Redmine (or other plugins loaded earlier)
    unless columns_list.count > 0
      return super
    end

    # Continue here if there are custom fields defined
    field_values = "".html_safe
    s = '<table class="list issues odd-even issue-view-columns">'.html_safe
    
    # Render table header structure (<thead> and <tr>)
    s << '<thead>'.html_safe
    s << '<tr>'.html_safe
    
    # First base column — always an issue link (Tracker #ID) to maintain table structure
    s << content_tag('th', l(:label_issue), style: 'text-align:left')
    
    # Dynamic columns from the plugin (including Subject in the order defined by admin)
    columns_list.each do |column|
      next if column.name == :tracker
      s << content_tag("th", column.caption, class: column.css_classes)
    end

    s << content_tag('th', '', class: 'ivc-spacer', 'aria-hidden' => 'true')
    if (Redmine::VERSION::MAJOR >= 4)
      s << content_tag('th', '', class: 'buttons') # Empty header for the context menu
    end
    s << '</tr>'.html_safe
    s << '</thead>'.html_safe

    # Children issues table data
    s << '<tbody>'.html_safe
    issue_list(issue.descendants.visible.preload(:status, :priority, :tracker, :assigned_to).sort_by(&:lft)) do |child, level|
      css = "issue issue-#{child.id} hascontextmenu #{child.css_classes}"
      css << " idnt idnt-#{level}" if level > 0

      field_content = "".html_safe
      
      # 1. Render the link in "Tracker #ID" format (without subject inside the link text) in the first cell
      issue_link = link_to_issue(child, tracker: true, subject: false)
      field_content << content_tag("td", issue_link, class: "id", style: "text-align:left; white-space: nowrap;")

      # 2. Render other dynamic columns in the order configured by the admin
      columns_list.each do |column|
        next if column.name == :tracker
        
        if column.name == :subject
          # If it's a Subject column, render it as plain text while keeping the 'subject' class for CSS compatibility
          field_content << content_tag("td", content_tag("span", child.subject, class: "ivc-subject-text"), class: "subject", style: "text-align:left;")
        else
          # Use standard content helper for all other columns
          field_content << content_tag("td", column_content(column, child), class: "#{column.css_classes}")
        end
      end

      field_content << content_tag('td', '', class: 'ivc-spacer', 'aria-hidden' => 'true')
      if (Redmine::VERSION::MAJOR >= 4)
        field_content << content_tag('td', link_to_context_menu, class: 'buttons')
      end

      field_values << content_tag("tr", field_content, class: css)
    end

    s << field_values
    s << '</tbody>'.html_safe
    s << "</table>".html_safe
    s.html_safe
  end

  # Renders the list of related issues on the issue details view
  def render_issue_relations(issue, relations)
    columns_list = get_fields_for_project(issue)
    unless columns_list.count > 0
      return super
    end

    manage_relations = User.current.allowed_to?(:manage_issue_relations, issue.project)

    s = '<table class="list issues odd-even issue-view-columns">'.html_safe

    # Render table header structure
    s << '<thead>'.html_safe
    s << '<tr>'.html_safe
    
    # First base column — always an issue link (Tracker #ID)
    s << content_tag('th', l(:label_issue), style: 'text-align:left')
    
    columns_list.each do |column|
      next if column.name == :tracker
      s << content_tag("th", column.caption, class: column.css_classes)
    end

    s << content_tag('th', '', class: 'ivc-spacer', 'aria-hidden' => 'true')
    s << content_tag('th', '', class: 'buttons') # Empty header for actions
    s << '</tr>'.html_safe
    s << '</thead>'.html_safe

    s << '<tbody>'.html_safe
    relations.each do |relation|
      other_issue = relation.other_issue(issue)
      css = "issue hascontextmenu #{other_issue.css_classes}"
      
      # Relation delete button
      link = manage_relations ? link_to(l(:label_relation_delete),
                                        relation_path(relation),
                                        remote: true,
                                        method: :delete,
                                        data: { confirm: l(:text_are_you_sure) },
                                        title: l(:label_relation_delete),
                                        class: "icon-only icon-link-break") : ""

      field_content = "".html_safe
      
      # 1. Base link to the issue in "Tracker #ID" format (without subject inside the link text)
      issue_link = link_to_issue(other_issue, tracker: true, subject: false)
      field_content << content_tag("td", issue_link, class: "id", style: "text-align:left; white-space: nowrap;")
      
      # 2. Dynamic columns in the same order as the subtasks table
      columns_list.each do |column|
        next if column.name == :tracker
        
        if column.name == :subject
          field_content << content_tag("td", content_tag("span", other_issue.subject, class: "ivc-subject-text"), class: "subject", style: "text-align:left;")
        else
          field_content << content_tag("td", column_content(column, other_issue), class: "#{column.css_classes}")
        end
      end

      field_content << content_tag('td', '', class: 'ivc-spacer', 'aria-hidden' => 'true')
      buttons = "".html_safe
      buttons << link.html_safe if link.present?
      buttons << link_to_context_menu if Redmine::VERSION::MAJOR >= 4
      
      field_content << content_tag('td', buttons, class: 'buttons')

      s << content_tag("tr", field_content, id: "relation-#{relation.id}", class: css)
    end
    s << '</tbody>'.html_safe

    s << "</table>".html_safe
    s.html_safe
  end

  private

  def get_fields_for_project(issue)
    query = IssueQuery.new()
    query.project = issue.project
    available_fields = query.available_inline_columns
    subtask_fields = []

    unless issue.project.module_enabled?(:issue_view_columns)
      all_fields = Setting.plugin_redmine_issue_view_columns["issue_view_default_columns"] || []
    else
      all_fields = IssueViewColumns.columns_for(issue.project_id, issue.tracker_id)
    end

    all_fields.each do |field|
      # Exclude ONLY tracker, as it is displayed inside the first column as part of the link text.
      # Subject is NO longer excluded — allowing it to be part of the dynamic fields array.
      if ["tracker"].include? field
        next
      end
      proj_field = available_fields.select { |f| f.name.to_s == field }
      
      # FIX: Extract the first element from the array (.first) so we insert the Column object, not the Array wrapper
      subtask_fields << proj_field.first if proj_field.count > 0
    end
    subtask_fields
  end
end
