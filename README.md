# Redmine Issue View Columns Plugin [![Maintainability](https://api.codeclimate.com/v1/badges/48f3036ae9ede022185b/maintainability)](https://codeclimate.com/github/kenan3008/redmine_issue_view_columns/maintainability)

Redmine plugin to customize shown columns in subtasks and related issues on issue page

![screenshot](https://raw.github.com/kenan3008/redmine_issue_view_columns/gh-pages/screenshot.png)

Basic functionality
-------------------

* Provide configurable list of columns that are shown for subtasks list in issue view
* Provide configurable list of columns that are shown for related issues in issue view
* Configuration is possible per project, with optional overrides for each tracker
* Global defaults are inherited by projects with the plugin module enabled. Disabled projects use Redmine's original tables.
* Tracker and issue ID are always shown in the first column. Subject is a configurable column.
* Related issues contain an icon that is used to remove the relation from corresponding ticket. This icon is always shown as the last column on the right side of the related issues table
* Same configuration is applied to both subtasks and related issues sections

Tracker-specific columns (1.1.0)
-------------------------------

Settings are selected by the tracker of the **open issue**, not by the trackers
of individual rows. The same ordered set is used for subtasks and relations,
even when their rows contain different trackers.

1. Enable the Issue View Columns module in the project.
2. Open Project settings → Issue columns.
3. Select “All trackers (project default)” to edit the existing common set.
4. Select a tracker and click Apply. Clear “Use the project default columns”,
   choose and order its columns, and save.
5. Re-enable inheritance and save to remove that tracker's override.

Existing nonempty project sets and tracker overrides keep their order.
In “All trackers”, “Use global settings” is enabled by default when no local
set is stored, and disables the fields selector below. Tracker inheritance
uses the effective project set, including its inherited global settings.
Saving an empty project/tracker set restores inheritance.

Global settings use Subject, Status, % Done, Start date when empty or unset.
“Reset to default columns” restores these four fields in order; click Save
to persist the reset. Clearing the global list also uses these defaults.
The plugin only renders tables in projects where its module is enabled.
Disabling the module preserves saved column settings for later reactivation.
Only users with the existing manage_issue_view_columns permission can save.

Compatibility
-------------

Plugin is compatible with:
- Redmine 4.2.9.stable
- MariaDB 10.5.18
- Database adapter Mysql2
- Ruby 2.7.4-p191
- Rails 5.2.8.1

Newer and older versions might work but these haven't been tested so far.

Installation
------------

* Clone https://github.com/kkol4anov/redmine_issue_view_columns or download zip to **redmine_dir/plugins/** folder
```
$ git clone https://github.com/kkol4anov/redmine_issue_view_columns.git
```
* From redmine root directory, run:
```
$ rake redmine:plugins:migrate RAILS_ENV=production NAME=redmine_issue_view_columns
$ rake tmp:cache:clear RAILS_ENV=production
```
* Restart redmine:
```
$ touch tmp/restart.txt
```

Credits
-------

Plugin is inspired by http://www.redmine.org/plugins/subtaskcolumns and http://www.redmine.org/plugins/subtask_list_columns