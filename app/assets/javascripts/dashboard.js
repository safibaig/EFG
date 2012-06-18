$(document).ready(function() {
  
  $("span.pie").peity("pie", {
    colours: function() {
      return ["#dddddd", this.getAttribute("data-colour")]
    },
    diameter: function() {
      return this.getAttribute("data-diameter")
    }
  });
  
  $("span.bar").peity("bar", {
    colour: function() {
      return this.getAttribute("data-colour")
    },
    width: function() {
      return this.getAttribute("data-width")
    },
    height: function() {
      return this.getAttribute("data-height")
    }
  });
  
});
