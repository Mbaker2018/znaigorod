@afishaListPostersAutocomplete = ->
  input = $('.js-afisha_list_posters_autocomplete')
  target = $(input.data('target'))

  input.autocomplete
    source: input.data('autocomplete-source')
    minLength: 2

    focus: (event, ui) ->
      $(this).val(ui.item.label)
      false

    select: (event, ui) ->
      $(this).val(ui.item.label)
      target.val(ui.item.value)
      false
