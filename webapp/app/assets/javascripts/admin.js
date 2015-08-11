//= require jquery.remotipart

$(function() {
  function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
    results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
  }

  function replaceQueryString(url,param,value) {
    var re = new RegExp("([?|&])" + param + "=.*?(&|$)","i");
    if (url.match(re)) {
      return url.replace(re,'$1' + param + "=" + value + '$2');
    } else {
      return url + '&' + param + "=" + value;
    }
  }

  $('#hospital_table th#h_class').click(function() {
    var h_class_order = getParameterByName('h_class_order') == 'asc' ? 'desc' : 'asc';
    window.location.href = replaceQueryString(window.location.href, 'h_class_order', h_class_order);
  });

  $('.admin .reviews-form .export-btn').click(function() {
    var url = '/admin_panel/reviews/export?' + $('.admin .reviews-form').serialize();
    window.location.href = url;
  });
});
