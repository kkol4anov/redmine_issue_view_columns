(function () {
    'use strict';

    var selector = 'table.issue-view-columns:not(.ivc-measuring)';

    function sizeSubjects(table) {
        if (!table.offsetWidth || !table.tHead) return;
        var headers = table.tHead.querySelectorAll('th.subject, th.parent-subject');
        if (!headers.length) return;

        var copy = table.cloneNode(true);
        copy.classList.add('ivc-measuring');
        copy.setAttribute('aria-hidden', 'true');
        copy.removeAttribute('id');
        // Do not duplicate Redmine's issue IDs or successful form controls.
        copy.querySelectorAll('[id]').forEach(function (node) { node.removeAttribute('id'); });
        copy.querySelectorAll('input, select, textarea, button').forEach(function (node) {
            node.disabled = true;
        });
        table.parentNode.appendChild(copy);
        try {
            var measured = copy.tHead.querySelectorAll('th.subject, th.parent-subject');
            var widths = Array.prototype.map.call(measured, function (cell) {
                return Math.ceil(cell.getBoundingClientRect().width);
            });
            headers.forEach(function (header, index) {
                header.style.width = widths[index] + 'px';
            });
        } finally {
            copy.remove();
        }
        // The browser shrinks these preferred widths when space is scarce.
        // No resize handler is needed; the empty spacer gets any surplus.
    }

    function start() {
        var content = document.getElementById('content');
        if (!content) return;
        var pending = false;
        function refresh() {
            pending = false;
            content.querySelectorAll(selector).forEach(sizeSubjects);
        }
        function schedule() {
            if (!pending) {
                pending = true;
                window.requestAnimationFrame(refresh);
            }
        }
        refresh();
        // Redmine can replace the relations/subtasks markup after an AJAX action.
        new MutationObserver(function (records) {
            var changed = records.some(function (record) {
                return Array.prototype.some.call(record.addedNodes, relevant) ||
                    Array.prototype.some.call(record.removedNodes, relevant) ||
                    record.type === 'characterData';
            });
            if (changed) schedule();
        }).observe(content, {childList: true, subtree: true, characterData: true});
        function relevant(node) {
            return node.nodeType !== 1 || !node.classList.contains('ivc-measuring');
        }
        if (document.fonts && document.fonts.ready) document.fonts.ready.then(schedule);
        window.addEventListener('load', schedule);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', start);
    } else {
        start();
    }
}());
