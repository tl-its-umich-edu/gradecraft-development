!function(app, $) {
  $(document).ready(function() {
    $.ajax({
      url: $('.search-query').data('autocompleteurl'),
      dataType: "json",
      success: function(user) {
        var users = user.students;
        $('.search-query').omniselect({
          source: users,
          resultsClass: 'typeahead dropdown-menu',
          activeClass: 'active',
          itemLabel: function(user) {
            return user.name;
          },
          itemId: function(user) {
            return user.id;
          },
          renderItem: function(label) {
            return '<li><a href="#">' + label + '</a></li>';
          },
          filter: function(item, query) {
            return item.name.match(new RegExp(query, 'i'));
          }
        }).on('omniselect:select', function(event, id) {
          $(event.target).val();
          window.location = '/students/' + id;
          return false;
        });
      }
    });  
  });
}(Gradecraft, jQuery);