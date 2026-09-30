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

    var reset = $('#issue-view-columns-reset');
    var selected = $('#selected_settings_issue_view_default_columns');
    var available = $('#available_settings_issue_view_default_columns');
    function resetGlobalColumns() {
        selected.children('option').prop('selected', false).appendTo(available);
        $.each(reset.data('columns') || [], function (_, name) {
            available.children('option').filter(function () {
                return this.value === name;
            }).prop('selected', true).appendTo(selected);
        });
    }
    reset.on('click', resetGlobalColumns);
    reset.closest('form').on('submit', function () {
        if (!selected.children('option').length) {
            resetGlobalColumns();
        }
        selected.children('option').prop('selected', true);
    });
});
