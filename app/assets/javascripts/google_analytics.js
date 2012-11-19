$(document).ready(function() {
  
  if (typeof _gaq != 'undefined') {
  
    $('form.csv-download').submit(function() {
      _gaq.push(['_trackEvent', 'Download', 'CSV', this.action]);
    });
  
    $('a.csv-download').click(function() {    
      _gaq.push(['_trackEvent', 'Download', 'CSV', $(this).attr('href')]);
    });
  
    $('a.pdf-download').click(function() {
      _gaq.push(['_trackEvent', 'Download', 'PDF', $(this).attr('href')]);
    });
    
  }
  
});
