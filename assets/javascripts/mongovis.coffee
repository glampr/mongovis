jQuery ->

  mapCanvas = document.getElementById('google-map-canvas')
  if mapCanvas
    window.gmap = new google.maps.Map(mapCanvas, {
      center: new google.maps.LatLng(18, 0)
      zoom: 2,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })

  if window.geojson
    gmap.data.addGeoJson(geojson)
