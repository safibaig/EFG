$(document).ready(function() {

  $('.sic-code-input').each(function(index, element) {
    var $sicCodeInput = $(element),
        $sicCodeSelect = $sicCodeInput.find('select'),
        $eligibilityMessage = $sicCodeInput.find('.sic-code-restricted-eligibility'),
        $selectedOption;

    $sicCodeSelect.change(function() {
      $selectedOption = $(this).find(':selected');
      
      if ($selectedOption.data('eligibility') === 'restricted') {
        $eligibilityMessage.show();
      } else {
        $eligibilityMessage.hide();
      }
    }).chosen();
    
    // on page load, display restricted eligibility message 
    // if a restricted SIC code is already selected
    $sicCodeSelect.trigger('change');
  });
  
});
