jQuery.ajaxSetup({ 
  beforeSend: function(xhr) { 
    xhr.setRequestHeader("Accept", "application/json"); 
  }
});


$(document).ready(function() {
  $("input#lookup_term").autocomplete({ 
    source: "/search", 
    minLength: 3,
    select: function(event) {
      event.target.form.submit();
    }
  });
});
