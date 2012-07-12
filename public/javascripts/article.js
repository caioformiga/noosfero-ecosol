jQuery(function($) {
  $(".lead-button").live('click', function(){
    article_id = this.getAttribute("article_id");
    $(this).toggleClass('icon-add').toggleClass('icon-remove');
    $(article_id).slideToggle();
    return false;
  })
  $("#body-button").click(function(){
    $(this).toggleClass('icon-add').toggleClass('icon-remove');
    $('#article-body-field').slideToggle();
    return false;
  })

  $("#textile-quickref-show").click(function(){
    $('#textile-quickref-hide').show();
    $(this).hide();
    $('#textile-quickref').slideToggle();
    return false;
  })
  $("#textile-quickref-hide").click(function(){
    $('#textile-quickref-show').show();
    $(this).hide();
    $('#textile-quickref').slideToggle();
    return false;
  })

  var button_add = $('.text-editor-sidebar meta[name=button.add]').attr('value');
  var button_zoom = $('.text-editor-sidebar meta[name=button.zoom]').attr('value');
  var button_close = $('.text-editor-sidebar meta[name=button.close]').attr('value');

  function add_to_text_button() {
    return '<a class="button icon-add add-to-text" href="#"><span>' + button_add + '</span></a>';
  }

  function add_to_text_link() {
    return '<a class="add-to-text" href="#">' + button_add + '</a>';
  }

  function close_link() {
    return '<a class="close" href="#">' + button_close + '</a>';
  }

  function zoom_button() {
    return '<a class="button icon-zoom zoom" href="#" title="' + button_zoom + '"><span>' + button_zoom + '</span></a>';
  }

  function list_items(items, selector, auto_add) {
    var html_for_items = '';

    var images  = [];
    var files   = [];
    var errors  = [];

    $.each(items, function(i, item) {
      if (item.error) {
        errors.push(item);
        return;
      }
      if (item.content_type && item.content_type.match(/^image/)) {
        images.push(item);
      } else {
        files.push(item);
      }
    });

    $.each(images, function(i, item) {
      html_for_items += '<div class="item image" data-item="span"><span><img src="' + item.url + '"/></span><div class="controls image-controls">' + add_to_text_button() + zoom_button() + '</div></div>';
    });

    $.each(files, function(i, item) {
      html_for_items += '<div class="item file ' + item.icon + '" data-item="div"><div><a href="' + item.url + '">' + item.title + '</a></div> <div class="controls file-controls">' + add_to_text_button() + '</div></div>';
    });

    $.each(errors, function(i, item) {
      html_for_items += '<div class="media-upload-error">' + item.error + '</div>';
    });

    $(selector).html(html_for_items);

    if (auto_add) {
      $(selector).find('a.add-to-text').click();
    }
  }

  $('.controls a.add-to-text').live('click', function() {
    var $item = $(this).closest('.item');
    var html_selector = $item.attr('data-item');
    insert_item_in_text($item.find(html_selector));
    $.colorbox.close();
    return false;
  });
  $('.controls a.zoom').live('click', function() {
    var $item = $(this).closest('.item');
    var html_selector = $item.attr('data-item');
    var img = $item.find(html_selector).find('img').attr('src');
    $.colorbox({ html: '<div class="item" data-item="div"><div><img src="' + img + '" style="max-width: 580px; max-height: 580px"/></div>' + '<div class="controls" style="padding-top: 5px;">' + add_to_text_link() + '&nbsp;&nbsp;&nbsp;' + close_link() + '</div></div>', maxWidth: '640px', maxHeight: '670px', scrolling: false });
    return false;
  });
  $('.controls a.close').live('click', function() {
    $.colorbox.close();
    return false;
  })

  // FIXME the user may also want to add the item to the abstract textarea!
  var text_field = 'article_body';

  function insert_item_in_text($wrapper) {
    if (window.tinymce) {

      var html = $wrapper.html();

      var editor = tinymce.get(text_field);

      editor.setContent(editor.getContent() + html);

    } else {
      // simple text editor
      var $text_element = $('#' + text_field);
      var text = $text_element.val();
      var $item = $wrapper.children().first();
      if ($item.attr('src')) {
        $text_element.val(text + '!' + $item.attr('src') + "!\n");
      }
      if ($item.attr('href')) {
        $text_element.val(text + $item.attr('href'));
      }
    }
  }

  $('#media-search-button').click(function() {
    var query = '*' + $('#media-search-query').val() + '*';
    var $button = $(this);
    $('#media-search-box .header').toggleClass('icon-loading');
    $.get($(this).parent().attr('action'), { 'q': query }, function(data) {
      list_items(data, '#media-search-results .items', false);
      if (data.length && data.length > 0) {
        $('#media-search-results').slideDown();
      }
    $('#media-search-box .header').toggleClass('icon-loading');
    });
    return false;
  });

  $('#media-upload-form form').ajaxForm({
    dataType: 'json',
    resetForm: true,
    beforeSubmit:
      function() {
        $('#media-upload-form').slideUp();
        $('#media-upload-box .header').toggleClass('icon-loading');
      },
    success:
      function(data) {
        list_items(data, '#media-upload-results .items', true);
        if (data.length && data.length > 0) {
          $('#media-upload-results').slideDown();
        }
        $('#media-upload-box .header').toggleClass('icon-loading');
      }
  });

  $('#media-upload-more-files').click(function() {
    $('#media-upload-results').hide();
    $('#media-upload-form').show();
  });

});
