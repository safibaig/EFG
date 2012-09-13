$(document).ready(function() {
  
  var $toggleAdvancedSearch = $('#toggle_advanced_search'),
      $advancedSearchOptions = $('#advanced_search_options');
  
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
  
});