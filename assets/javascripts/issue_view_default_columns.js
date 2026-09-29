$(document).ready(function () {
    // Tracker is already part of the issue link; subject is a configurable column.
    $("#available_settings_issue_view_default_columns option[value='tracker'], " +
      "#selected_settings_issue_view_default_columns option[value='tracker'], " +
      "#available_c option[value='tracker'], #selected_c option[value='tracker']").remove();

    var inherit = $('#inherit_columns');
    function updateInheritance() {
        $('.issue-view-columns-fields').prop('disabled', inherit.prop('checked') === true);
    }
    inherit.on('change', updateInheritance);
    updateInheritance();
});
