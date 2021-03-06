@init_auth = () ->
  draw_popup = (url, width, height, name) ->
    left = (screen.width/2)-(width/2)
    top = (screen.height/2)-(height/2)
    return window.open(url, name, "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top)

  save_comment = () ->
    unless (typeof(window.localStorage) == 'undefined')
      window.localStorage.clear()
      window.localStorage.setItem('comment_body', $('form textarea', '.comments').val())
      if $('.comment_wrapper.active', '.comments').length
        window.localStorage.setItem('comment_id',   $('.comment_wrapper.active', '.comments').parent().attr('id'))
      else
      window.localStorage.setItem('comment_id', 'new_comment')

  $('.auth_links a').not('.charged').addClass('charged').on 'click', (evt) ->
    target = $(evt.target)

    save_comment() if target.parent().parent().parent().hasClass('comment_form')

    draw_popup(target.attr('href'), 700, 400, 'Авторизация')

    return false

@init_login = () ->
  $('.dashboard .sign_in').on 'click', ->
    $.ajax
      url: '/my/sessions/new'
      success: (response, textStatus, jqXHR) ->
        signin_container = $('<div class="sign_in_with" />').appendTo('body').hide().html(response)
        signin_container.dialog
          autoOpen: true
          draggable: false
          modal: true
          resizable: false
          title: 'Необходима авторизация'
          width: '500px'
          open:
            init_auth()
          close: (event, ui) ->
            $(this).dialog('destroy')
            $(this).remove()
            true

    true
  false

