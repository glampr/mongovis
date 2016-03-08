jQuery ->

  mapCanvas = document.getElementById('google-map-canvas')
  if mapCanvas
    window.gmap = new google.maps.Map(mapCanvas, {
      center: new google.maps.LatLng(18, 0)
      zoom: 2,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })
    gmap.data.setStyle (feature) ->
      {
        strokeColor: feature.getProperty('c'),
        fillColor: feature.getProperty('c'),
        strokeWeight: feature.getProperty('w') || 2
      }

    gmap.data.addListener 'click', (event) ->
      v = event.feature.getProperty('v')
      new google.maps.InfoWindow({
        content: v + '',
        position: event.latLng
      }).open(gmap)

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
        $('#geofield').val(q.g)
        $('#displayfield').val(q.d)
        $('#query-color').val(q.f)
    })
  )

  $('#clear_layers').on('click', (event) ->
    event.preventDefault()
    gmap.data.forEach((feature) ->
      gmap.data.remove(feature)
    )
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
          sqKey = new Date().getTime()
          sqVal = {
            c: $('#query-collection').val(),
            g: $('#geofield').val(),
            d: $('#displayfield').val(),
            q: queryText,
            f: $('#query-color').val()
          }
          localStorage.setItem("sq-#{sqKey}", JSON.stringify(sqVal))
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

showSpinner = (placeholder) ->
  placeholder.data('originalContent', placeholder.html())
  placeholder.html($('#loading-spinner').html())
  placeholder.prop('disabled', true)

hideSpinner = (placeholder) ->
  placeholder.html(placeholder.data('originalContent'))
  placeholder.data('originalContent', undefined)
  placeholder.prop('disabled', false)

arrayToSelectOptions = (select, options) ->
  select.empty()
  for option in options
    select.append($("<option></option>").attr("value", option).text(option))

arrayToDropdownMenu = (menu, list) ->
  for item in list
    menu.append($('<li></li>').append($('<a></a>').attr('href', "##{item.key}").addClass('load-sq').text(item.descr)))
