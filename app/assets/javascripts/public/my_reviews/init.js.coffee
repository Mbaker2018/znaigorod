clone = (obj) ->
  return obj  if obj is null or typeof (obj) isnt "object"

  temp = new obj.constructor()
  for key of obj
    temp[key] = clone(obj[key])

  temp

beforeImageInsert = (h) ->
  textarea = $(h.textarea)

  before = textarea.val()[0...h.caretPosition]
  after = textarea.val()[(h.caretPosition + h.selection.length)...textarea.val().length]

  file_input = $('.upload_gallery_images #gallery_image_file')

  file_input.fileupload
    dataType: 'json'

    done: (e, data) ->
      url = data.result.files[0].url
      textarea.val("#{before}!#{url}!#{after}")
      textarea.trigger('preview')

    start: (e) ->
      top = $(document).scrollTop()
      $('body').addClass('non_scrollable')

      $('.loader').show().offset
        left: 0
        top: top

    stop: (e) ->
      $('body').removeClass('non_scrollable')
      $('.loader').hide()

    fail: (e, data) ->
      message = data.jqXHR.responseText
      $('.message_wrapper').text(message).show().delay(5000).slideUp('slow')

markItUpSettings = ->
  settings = clone(mySettings)

  settings.afterInsert = (h) ->
    $('textarea[name="review[content]"]').trigger('preview')

  imageButton = {
    name:'Изображение'
    className: 'image_button'
    openWith: ''
    beforeInsert: (h) ->
      beforeImageInsert(h)
  }

  youtubeButton = {
    name: 'Видео с Youtube'
    className: 'youtube_button'
    replaceWith: '[![Добавление видео с Youtube:!:Просто вставьте сюда ссылку на видео с Youtube, например, http://www.youtube.com/watch?v=e-GYrbecb88]!]'
  }

  vimeoButton = {
    name: 'Видео с Vimeo'
    className: 'vimeo_button'
    replaceWith: '[![Добавление видео с Vimeo:!:Просто вставьте сюда ссылку на видео с Vimeo, например, http://vimeo.com/11192521]!]'
  }

  settings.markupSet.push(imageButton)
  settings.markupSet.push(youtubeButton)
  settings.markupSet.push(vimeoButton)

  settings

tagitFor = (element) ->
  options = {
    allowSpaces:              true
    caseSensitive:            false
    closeAutocompleteOnEnter: true
    singleFieldDelimiter:     ', '

    autocomplete:
      delay:     0
      minLength: 1
      source:    element.data('autocomplete-source')
  }

  element.tagit options

initMarkitup = ->
  $('.markitup').markItUp(markItUpSettings())

handleImageButtonClick = ->
  $('.image_button').click ->
    $('#gallery_image_file').focus().trigger('click')

initTagit = ->
  tagitFor $('#review_tag')

delay = (->
  timer = 0
  (callback, ms) ->
    clearTimeout timer
    timer = setTimeout(callback, ms)
)()

handlePreview = ->
  form = $('.my_review_form')

  textInputs = $('#review_title, .with-preview')
  tagsInput = $('#review_tag')

  textInputs.on 'keyup', ->
    delay (->
      form.trigger('preview')
    ), 1000

  tagsInput.on 'change', ->
    delay (->
      form.trigger('preview')
    ), 1000

  form.on 'preview', ->
    serialized = $('input[name!=_method], textarea', form)
    $.post('/my/reviews/preview', serialized)
      .done (data) ->
        $('.reviews_show').html(data)

linkWithAutocomplete = ->
  input = $('#review_link_with_title')
  target = $(input.data('target'))
  reset = $(input.data('reset'))

  input.autocomplete
    source: input.data('autocomplete-source')
    minLength: 2

    focus: (event, ui) ->
      $(this).val(ui.item.label)
      false

    select: (event, ui) ->
      $(this).val(ui.item.label)
      target.val(ui.item.value)
      reset.val('')
      false

linkWithChange = ->
  $('.link_with_change').click ->
    $('.link_with_content').closest('.link_with_wrapper').hide()
    $('.review_link_with_title').removeClass('linked').addClass('not_linked')
    $('#review_link_with_reset').val('true')
    $('#review_link_with_title').focus()
    false

handleLinkWith = ->
  linkWithAutocomplete()
  linkWithChange()

@initMyReviews = ->
  initMarkitup()
  handleImageButtonClick()
  initTagit()
  handlePreview()
  handleLinkWith()