$(document).ready(function() {
    $('#issues').DataTable({
    	columns: [
    		{ title: 'Variable', type: 'text' },
    		{ title: 'TableID', type: 'text' },
    		{ title: 'Experiment', type: 'text' },
    		{ title: 'Model', type: 'text' },
    		{ title: 'Issue', type: 'text' },
    		{ title: 'Status', type: 'text' }
    	],
        createdRow: function(row, data, dataIndex) {
            if (data[5] == 'open') {
                $(row).find('td:eq(5)').addClass('issue-green');
            } else if (data[5] == 'closed') {
                $(row).find('td:eq(5)').addClass('issue-purple');
            }
        }
    });
} );

