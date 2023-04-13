$(document).ready(function() {
	$('#issues thead .column-filter').each(function() {
		var title = $(this).closest('th').text();
		$(this).empty().append('<option value="">  </option>');
        <!--$(this).empty().append('<option value="">Filter ' + title + '</option>');-->
	});

	$('#issues').DataTable({
		searchHighlight: true,
		initComplete: function() {
			this.api().columns().every(function() {
				var column = this;
				var select = $(column.header()).find('.column-filter')
					.on('change', function() {
						var val = $.fn.dataTable.util.escapeRegex($(this).val());
						column.search(val ? '^' + val + '$' : '', true, false).draw();
					});

				column.data().unique().sort().each(function(d, j) {
					select.append('<option value="' + d + '">' + d + '</option>');
				});
			});
		}
	});
});
