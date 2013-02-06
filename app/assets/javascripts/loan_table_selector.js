$(document).ready(function() {
  $('[data-behaviour^=loan-table-selector]').each(function(_, element) {
    $(element).on('change', 'input[type=checkbox]', function() {
      var checked = $(this).attr('checked');
      var row = $(this).parents('tr');
      row.toggleClass('info', checked);
    });
  });
});
