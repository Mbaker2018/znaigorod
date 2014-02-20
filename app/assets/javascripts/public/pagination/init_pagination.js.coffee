@init_pagination = () ->

  $('body nav.pagination').css
    'height': '0'
    'visibility': 'hidden'
  list_url = window.location.pathname
  list = $(
    '.content_wrapper .afisha_list:not(.pagination_none) > ul,' +
    '.content_wrapper .discounts_list > ul,' +
    '.content_wrapper .organizations_list:not(.pagination_none) > ul,' +
    '.content_wrapper .search_results ul.items_list,' +
    '.content_wrapper .tickets_list,' +
    '.content_wrapper .accounts_list ul,' +
    '.content_wrapper .reviews_show .gallery,' +
    '.content_wrapper .organization_show .afisha_list ul,' +
    '.content_wrapper .contest .works ul,' +
    '.feeds > ul, ' +
    '#notifications > ul, ' +
    '#invites > ul, ' +
    '.content_wrapper .images_list > ul'
  )

  # отключаем пагинацию для обзоров при просмотре в /my
  return true if $('.my_reviews_show').length

  first_item = $('li:first', list)
  return true unless first_item.length

  if first_item.siblings().length
    last_item = first_item.siblings().last()
  else
    last_item = first_item
  last_item_top = last_item.position().top
  feeds = $('.feeds .feed').length

  unless feeds
    last_item_offset = 400
  else
    last_item_offset = 200
  page = 1
  busy = false
  $(window).scroll ->
    if ($(this).scrollTop() + $(this).height()) >= (last_item_top - last_item_offset) && !busy
      busy = true
      search_params = ""
      search_params = window.location.search.replace(/^\?/, "&").replace(/&page=\d+/, "")

      url = $('.feeds .feed_pagination a').attr('href') if feeds

      if url == undefined && feeds
        return true

      unless feeds
        url = "#{list_url}?page=#{parseInt(page) + 1}#{search_params}"
      else
        url = url.replace(/^\?/, "&").replace(/&page=\d+/, "") + '&' + 'page=' + (page+1)

      $.ajax
        url: url
        beforeSend: (jqXHR, settings) ->
          $('<li class="ajax_loading_items_indicator">&nbsp;</li>').appendTo(list)
          true
        complete: (jqXHR, textStatus) ->
          $('li.ajax_loading_items_indicator', list).remove()
          true
        success: (data, textStatus, jqXHR) ->
          return true if data.match(/empty_items_list/)
          return true if data.trim().isBlank()
          list.append(data)
          last_item = first_item.siblings().last()
          last_item_top = last_item.position().top
          page += 1
          busy = false unless data.trim().isBlank()
          init_photogallery() if $('.content_wrapper .was_in_city_photos li').length && data.length
          init_payment() if $('.content_wrapper .tickets_list li').length && data.length
          init_sms_claims() if $('.content_wrapper .sms_claims li').length && data.length
          init_payment() if $('.feeds .feed').length
          init_sauna_halls_scroll() if $('.content_wrapper .organizations_list > ul .sauna_halls').length
          init_post_photos() if $('.post_show a[rel="colorbox"], .post_show a.colorbox').length
          process_change_message_status() if $('#notifications').length
          true

    true

  true
