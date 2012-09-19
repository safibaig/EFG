$(document).ready(function() {
  
  if ($('#search')) {
    
    var $toggleAdvancedSearch         = $('#toggle_advanced_search'),
        $advancedSearchOptions        = $('#advanced_search_options'),
        $lendingLimitSelect           = $('#search_lending_limit_id'),
        $originalLendingLimitOptions  = $lendingLimitSelect.find('optgroup');

    $toggleAdvancedSearch.click(function() {    
      if ($advancedSearchOptions.is(":visible")) {
        $advancedSearchOptions.slideUp('fast');
        $toggleAdvancedSearch.text('Show Advanced Search Options');
      } else {
        $advancedSearchOptions.slideDown('fast');
        $toggleAdvancedSearch.text('Hide Advanced Search Options');

        $('html,body').animate({ scrollTop: $advancedSearchOptions.offset().top }, 'fast');
      }

      return false;
    });
    
    // Only show lending limits for the chosen lender
    $('#search_lender_id').change(function() {
      var chosenLender = $(this).find(':selected').text();

      $lendingLimitSelect.append($originalLendingLimitOptions);
      if (chosenLender != 'All') {
        $('#search_lending_limit_id').find("optgroup[label!='" + chosenLender + "']").remove();
      }
    });
    
  }
  
});