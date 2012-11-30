$(document).ready(function() {
  var initialDrawDateInput = $('[data-behaviour=initial-draw-date] input');
  var projectedMaturityDateControl = $('[data-behaviour=projected-maturity-date]')

  if(initialDrawDateInput.length == 0 || projectedMaturityDateControl.length == 0) {
    return;
  }

  var maturityDatePlaceholder = projectedMaturityDateControl.find('.controls').text()
  var reset = function() {
    projectedMaturityDateControl.find('.controls').text(maturityDatePlaceholder)
  }

  var quickDateRegex = /(\d{1,2})\/(\d{1,2})\/(\d{2,4})/
  var calculateMaturityDate = function() {
    var value = initialDrawDateInput.val();
    var match = value.match(quickDateRegex);
    if(match) {
      var day = parseInt(match[1], 10)
      var month = parseInt(match[2], 10) - 1
      var year = match[3]
      if(year.length == 2) {
        year = "20" + year
      }
      year = parseInt(year, 10)

      try {
        Date.validateDay(day, year, month)

        var initialDrawDate = new Date(year, month, day)
        var repaymentDuration = parseInt(projectedMaturityDateControl.data('repayment-duration'), 10)
        var projectedMaturityDate = initialDrawDate.add({months: repaymentDuration, day: 1})

        projectedMaturityDateControl.find('.controls').text(projectedMaturityDate.toString('dd/MM/yyyy'))
      } catch (e) {
        reset()
      }
    } else {
      reset()
    }
  }

  initialDrawDateInput.blur(calculateMaturityDate);
  calculateMaturityDate();
});
