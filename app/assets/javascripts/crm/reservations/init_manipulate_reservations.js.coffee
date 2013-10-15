init_inputmask = ->
  $('#reservation_phone', '.reservations').inputmask 'mask',
    mask: '+7-(999)-999-9999'
    showMaskOnHover: false

handle_cancel = ->
  $('.cancel', '.reservations').on 'click', ->
    $(this).closest('tr').remove()
    $('.hidden', '.reservations').removeClass('hidden').show()

    false

@init_manipulate_reservations = ->
  $('.reservations').on 'ajax:success', (evt, response) ->
    tr = $(evt.target).closest('tr')

    if $('.hidden', '.reservations').length
      tr.replaceWith response
      $('.hidden', '.reservations').remove() unless $(response).find('form').length
    else
      tr.addClass('hidden').after(response)

    init_inputmask()
    handle_cancel()
