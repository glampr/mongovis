jQuery ->

  createGoogleMap = (container) ->

    mapCanvas = document.getElementById(container)
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
          strokeWeight: feature.getProperty('w') || 2,
          zIndex: feature.getProperty('z') || 1
        }

      gmap.dataFeaturesBounds ?= new google.maps.LatLngBounds()
      gmap.data.addListener "addfeature", (event) =>
        geometry = event.feature.getGeometry()
        switch geometry?.getType()
          when "Point"
            gmap.dataFeaturesBounds.extend(geometry.get())
          when "LineString", "LinearRing"
            for p in geometry.getArray()
              gmap.dataFeaturesBounds.extend(p)
          when "Polygon"
            for p in geometry.getAt(0).getArray()
              gmap.dataFeaturesBounds.extend(p)

      gmap.data.addListener 'click', (event) ->
        v = event.feature.getProperty('v')
        new google.maps.InfoWindow({
          content: v + '',
          position: event.latLng
        }).open(gmap)

      gmap

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

  $('.google-map-canvas').each (i) ->
    id = $(this).attr('id')
    [category, interval, direction] = id.split('.')
    console.log category, interval, direction
    index = if direction == 'incoming' then 0 else 1
    gmap = createGoogleMap(id)
    featureCollection = {type: 'FeatureCollection', features: []}
    uniques = {}
    data = regionLinks[interval][index]
    for d in data
      if d.line_weight > 1
        if !uniques[JSON.stringify(d.a_loc)]?
          featureCollection.features.push({
            type: 'Feature',
            geometry: d.a_loc,
            properties: {
              c: (if direction == 'incoming' then 'blue' else 'red'),
              z: 1
            }
          })
          uniques[JSON.stringify(d.a_loc)] = 1
        if !uniques[JSON.stringify(d.b_loc)]?
          featureCollection.features.push({
            type: 'Feature',
            geometry: d.b_loc,
            properties: {
              c: (if direction == 'incoming' then 'red' else 'blue'),
              z: 2
            }
          })
          uniques[JSON.stringify(d.b_loc)] = 1
        featureCollection.features.push({
          type: 'Feature',
          geometry: d.line,
          properties: {
            c: 'black',
            w: d.line_weight,
            v: d.line_weight,
            z: 0
          }
        })
    gmap.data.addGeoJson(featureCollection)
    gmap.fitBounds(gmap.dataFeaturesBounds)
