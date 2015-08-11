//= require modernizr-2.6.2.min
//= require jquery
//= require jquery_ujs
//= require mobile/helper
//= require mobile/jquery.mmenu.min.all
//= require mobile/mustache.min.0.7.2
//= require bootstrap
//
//= require mobile/left_menu
//= require mobile/jquery-ui.autocomplete
//= require mobile/jquery.raty
//= require mobile/jquery.load_more
//= require mobile/registrations

// Raty global option
$.fn.raty.defaults.halfShow = false;

// Autocomplete with group
$.widget("custom.catcomplete", $.ui.autocomplete, {
  _renderMenu: function(ul, items) {
    var self = this;
    $.each(items, function(index, category) {
      if (category.name) {
        ul.append("<li class='category'>" + category.name + "</li>");
      }
      $.each(category.objects, function(index, item) {
        self._renderItemData(ul, {
          label: item.name,
          value: item.id
        });
      });
    });
  }
});

function showNotification(text) {
  $('#notificationModal').modal().find(".modal-body").html(text);
}

function showConfirmation(text) {
  $('#confirmationModal').modal().find(".modal-body").html(text);
}
