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
        fillColor: feature.getProperty('c')
      }

    gmap.data.addListener 'click', (event) ->
      v = event.feature.getProperty('v')
      new google.maps.InfoWindow({
        content: v + '',
        position: event.latLng
      }).open(gmap)

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
        arrayToSelectOptions($('#geofield, #displayfield'), data.keys)
        console.log data
      error: ->
        hideSpinner(button)
    })
  )

  $('#clear_layers').on('click', (event) ->
    gmap.data.forEach((feature) ->
      gmap.data.remove(feature)
    )
  )

  $('#visualize_layer').on('submit', (event) ->
    event.preventDefault()
    button = $(this).find('button')
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
        catch e
          alert(e.toString())
      error: ->
        hideSpinner(button)
    })
  )
