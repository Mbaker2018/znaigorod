@init_map_project = () ->

  ymaps.ready ->
    $map = $('.map_wrapper .map')
    map = new ymaps.Map $map[0],
      center: [$map.attr('data-latitude'), $map.attr('data-longitude')]
      zoom: 12
      behaviors: ['drag', 'scrollZoom']
      controls: []
    ,
      maxZoom: 23
      minZoom: 11

    map.controls.add 'fullscreenControl',
      float: 'none'
      position:
        top: 10
        left: 10

    map.controls.add 'geolocationControl',
      float: 'none'
      position:
        top: 50
        left: 10

    map.controls.add 'zoomControl',
      float: 'none'
      position:
        top: 90
        left: 10

    clusterIcons = [{
      size: [35, 35]
      offset: [-18, -18]
    }]

    clusterer = new ymaps.Clusterer
      clusterDisableClickZoom: true
      showInAlphabeticalOrder: true
      hideIconOnBalloonOpen: false
      clusterBalloonContentLayout: 'cluster#balloonCarousel'
      clusterBalloonPagerType: 'marker'
      clusterBalloonContentLayoutWidth: 192
      clusterBalloonContentLayoutHeight: 355
      clusterIcons: clusterIcons

    $('.map_projects_wrapper .placemarks_list p').each (index, item) ->
      link = $('a', item)
      title = link.text()

      img_width = 190
      img_height = 190
      schedule = ""
      if $(item).attr('data-type') == 'afisha'
        img_height = 260
        schedule = $(item).attr('data-when')

      point = new ymaps.GeoObject
        geometry:
          type: 'Point'
          coordinates: [$(item).attr('data-latitude'), $(item).attr('data-longitude')]
        properties:
          balloonContentBody: "" +
            "<div class='ymaps-2-1-17-b-cluster-content__body'>" +
            "<a href='#{link.attr('href')}' target='_blank'>" +
            "<img width='#{img_width}' height='#{img_height}' src='#{$(item).attr('data-image')}' />" +
            "</a>" +
            "<div class='balloon_content_header' style='border-bottom:1px dashed #ccc;margin:5px 0;padding-bottom:5px;width:190px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>" +
            "<a href='#{link.attr('href')}' target='_blank' title='#{title}'>#{title}</a>" +
            "</div>" +
            "<div style='margin-bottom: 5px;width:190px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>" +
            "<a href='#{$(item).attr('data-organization-url')}' target='_blank' title='#{$(item).attr('data-organization-title')}'>#{$(item).attr('data-organization-title')}</a>" +
            "</div>" +
            "<div>#{schedule}</div>"
          hintContent: title
      ,
        balloonMinWidth: 192
        balloonMaxWidth: 192
        hideIconOnBalloonOpen: false
        iconLayout: 'default#image'
        iconImageHref: $(item).attr('data-icon')
        iconImageSize: [35, 35]
        iconImageOffset: [-18, -18]

      clusterer.add point

      true

    map.geoObjects.options.set
      showHintOnHover: false

    map.geoObjects.add clusterer

    true

  true
