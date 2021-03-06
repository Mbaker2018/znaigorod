@init_saunas = () ->
  wrapper = $("#sauna_tabs").tabs()
  $("div.input.integer", wrapper).each (index, item) ->
    label = $("label", item)
    label_for = label.attr("for")
    input = $("input", item)
    input.attr("id", "#{input.attr("id")}_input")
    input.wrap("<div class='input_wrapper' />")
    $("<span>руб.</span>").insertAfter(input) if input.hasClass("cost")
    input_wrapper = input.closest(".input_wrapper")
    if input.hasClass("required")
      input_wrapper.removeClass("input_wrapper")
      return true
    checkbox = $("<input class='boolean optional' type ='checkbox' id='#{label_for}' />").insertAfter(label)
    if input.val()
      checkbox.attr("checked", "checked")
    else
      input_wrapper.hide()
    checkbox.click (event) ->
      elem = $(this)
      input_wrapper.animate
        width: 'toggle'
      , ->
        if elem.is(":checked")
          input.val("0").focus().select()
        else
          input.val("")
      true
    true
  true
