$(document).ready(function() {
  $('[data-behaviour^=loan-table-selector]').each(function(_, element) {
    var totalAmountHeader = $('<th>').attr({colspan: 6}).text('Total Amount to be Settled');
    var totalAmountInput = $('<input>').attr({type: 'text', disabled: true});
    var totalAmountCell = $('<td>').html('<div class="currency"><div class="input-prepend"><span class="add-on">£</span></div></div>');
    totalAmountCell.find('.input-prepend').append(totalAmountInput)
    var footerRow = $('<tr>').append(totalAmountHeader, totalAmountCell);

    $(element).find('tfoot').prepend(footerRow);

    var calculateAmountSettledTotal = function() {
      var totalAmountSettled = 0;

      $(element).find('tbody tr').each(function(_, row) {
        var row = $(row);
        var selected = row.find('input[type=checkbox]').attr('checked');

        if(selected) {
          var amountSettledText = row.find('input[type=text]').val();
          var amountSettled = parseFloat(amountSettledText, 10);
          totalAmountSettled = totalAmountSettled + amountSettled;
        }
      });

      totalAmountInput.val(totalAmountSettled.toFixed(2));
    }

    calculateAmountSettledTotal();

    $(element).on('change', 'input[type=checkbox]', function() {
      var checked = $(this).attr('checked');
      var row = $(this).parents('tr');
      row.toggleClass('info', checked);

      calculateAmountSettledTotal();
    });
  });
});
