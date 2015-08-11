var Registration = {
  showError: function(message) {
    $('.page').prepend(
      '<div class="error flash">' +
      message +
      '<a class="close" href="javascript:" onclick="$(this).closest(&quot;.flash&quot;).remove()">×</a>' +
      '</div>'
    );
  },

  pushToken: function(tokenObj, callback) {
    $.post('/v1/account/authentications', tokenObj, function(response) {
      if (response && response.error) showNotification(response.error);
      if (typeof(callback) === 'function') callback(response);
    });
  }
};
