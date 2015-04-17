!function($) {
  var $document = $(document);

  var init = function() {
    $document.on('click', '.add-element', addElement);
    $document.on('click', '.remove-element', removeElement);
  }

  var addElement = function() {
    var $elements = $('fieldset.element');
    var template = $('#element-template').html().replace(/child_index/g, $elements.length);
    $('fieldset.elements').append(template);
    return false;
  };

  var removeElement = function() {
    var $link = $(this);
    $link.prev('input.destroy').val(true);
    var fieldset = $link.closest('fieldset.element');
    fieldset.hide();
    fieldset.find('input').not('.destroy', '.hidden').each(function(i, value){
      if(value.value === "") {
        value.remove();
      }
    });
    return false;
  };

  init();
}(jQuery);
