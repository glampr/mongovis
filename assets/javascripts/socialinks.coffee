jQuery ->

  mapCanvas = document.getElementById('google-map-canvas')
  if mapCanvas
    mapStylesNames  = [google.maps.MapTypeId.ROADMAP, google.maps.MapTypeId.SATELLITE]
    mapStylesObject = {}
    for name, definition of googlemap.providers
      mapStylesNames.push name
      mapStylesObject[name] = new google.maps.ImageMapType(definition)
    for name, definition of googlemap.styles
      mapStylesNames.push name
      mapStylesObject[name] = new google.maps.StyledMapType(definition, {name: name})

    window.gmap = new google.maps.Map(mapCanvas, {
      center: new google.maps.LatLng(18, 0)
      zoom: 2,
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      mapTypeControlOptions: {
        mapTypeIds: mapStylesNames
      }
    })

    for styleName in mapStylesNames
      gmap.mapTypes.set(styleName, mapStylesObject[styleName])
    gmap.setMapTypeId(mapStylesNames.slice(-1)[0])

    # transitLayer = new google.maps.TransitLayer()
    # transitLayer.setMap(gmap)

    gmap.data.setStyle (feature) ->
      {
        fillColor: feature.getProperty('c'),
        fillOpacity: 0.2,
        strokeColor: feature.getProperty('c'),
        strokeOpacity: 0.5,
        strokeWeight: feature.getProperty('w') || 2
      }

    gmap.data.addListener 'click', (event) ->
      v = event.feature.getProperty('v')
      new google.maps.InfoWindow({
        content: v + '',
        position: event.latLng
      }).open(gmap)

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

  list = []
  for key, value of localStorage
    if key.indexOf('sq-') == 0
      v = JSON.parse(value)
      v.key = key
      v.descr = "#{v.c}: (#{v.q}) | [#{v.g}/#{v.d}]"
      list.push(v)
  arrayToDropdownMenu($('#saved-queries'), list)

  $('.select_collection').on('click', (event) ->
    event.preventDefault()
    collection = $(this).text()
    button = $('#select_collection')
    showSpinner(button)
    $.ajax({
      url: $(this).attr('href'),
      type: 'GET',
      dataType: 'json',
      success: (data, textStatus, jqXHR) ->
        hideSpinner(button)
        $('.active_connection').text(collection)
        $('#query-collection').val(collection)
        arrayToSelectOptions($('#geofield, #displayfield'), data.keys)
        arrayToSelectOptions($('#distinctfield'), [].concat.call('', data.keys))
      error: ->
        hideSpinner(button)
    })
  )

  $(document).on('click', '.load-sq', (event) ->
    event.preventDefault()
    qv = localStorage.getItem($(this).attr('href').substring(1))
    q = JSON.parse(qv)
    $.ajax({
      url: "/collection/#{q.c}",
      type: 'GET',
      dataType: 'json',
      success: (data, textStatus, jqXHR) ->
        $('.active_connection').text(q.c)
        $('#query-collection').val(q.c)
        $('#query').val(q.q)
        arrayToSelectOptions($('#geofield, #displayfield'), data.keys)
        arrayToSelectOptions($('#distinctfield'), [].concat.call('', data.keys))
        $('#geofield').val(q.g)
        $('#displayfield').val(q.d)
        $('#distinctfield').val(q.n)
        $('#query-color').val(q.f)
    })
  )

  $('#clear_layers').on('click', (event) ->
    event.preventDefault()
    gmap.data.forEach((feature) ->
      gmap.data.remove(feature)
    )
  )

  $('#clead-saved-queries').on('click', (event) ->
    event.preventDefault()
    localStorage.clear()
    $('#saved-queries li').slice(2).remove()
  )

  $('#visualize_layer').on('submit', (event) ->
    event.preventDefault()
    button = $(this).find('button')
    queryText = $('#query').val()
    error = null
    if queryText.trim().length != 0
      try
        JSON.parse(queryText)
      catch error
        alert('Invalid JSON in query!\n' + error)
        return
    showSpinner(button)
    $.ajax({
      url: $(this).attr('action'),
      data: $(this).serialize(),
      type: 'POST',
      dataType: 'json',
      success: (data, textStatus, jqXHR) ->
        hideSpinner(button)
        try
          gmap.data.addGeoJson(data)
          sqKey = "sq-#{new Date().getTime()}"
          sqVal = {
            c: $('#query-collection').val(),
            g: $('#geofield').val(),
            d: $('#displayfield').val(),
            n: $('#distinctfield').val(),
            q: queryText,
            f: $('#query-color').val()
          }
          localStorage.setItem(sqKey, JSON.stringify(sqVal))
          arrayToDropdownMenu($('#saved-queries'), [{
            key: sqKey,
            descr: "#{sqVal.c}: (#{sqVal.q}) | [#{sqVal.g}/#{sqVal.d}]"
          }])
        catch e
          alert(e.toString())
      error: ->
        hideSpinner(button)
    })
  )

window.showSpinner = (placeholder) ->
  placeholder.data('originalContent', placeholder.html())
  placeholder.html($('#loading-spinner').html())
  placeholder.prop('disabled', true)

window.hideSpinner = (placeholder) ->
  placeholder.html(placeholder.data('originalContent'))
  placeholder.data('originalContent', undefined)
  placeholder.prop('disabled', false)

window.arrayToSelectOptions = (select, options) ->
  select.empty()
  for option in options
    select.append($("<option></option>").attr("value", option).text(option))

window.arrayToDropdownMenu = (menu, list) ->
  for item in list
    menu.append($('<li></li>').append($('<a></a>').attr('href', "##{item.key}").addClass('load-sq').text(item.descr)))
