@init_discounts_account_tabs = () ->
  $('#discounts_filter, #reviews_filter').tabs()
  $(window).unbind('scroll')
  window_scroll_init('all')

  $('#discounts_filter, #reviews_filter').on "tabsselect", (event, ui) ->
    $(window).unbind('scroll')
    window_scroll_init(ui.panel.id)
