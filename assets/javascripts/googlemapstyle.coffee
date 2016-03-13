window.googlemap ||= {}
window.googlemap.styles = {
  "PaleDown" : [
    {"featureType":"water","stylers":[{"visibility":"on"},{"color":"#acbcc9"}]},
    {"featureType":"landscape","stylers":[{"color":"#f2e5d4"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#c5c6c6"}]},
    {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#e4d7c6"}]},
    {"featureType":"road.local","elementType":"geometry","stylers":[{"color":"#fbfaf7"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#c5dac6"}]},
    {"featureType":"administrative","stylers":[{"visibility":"on"},{"lightness":33}]},
    {"featureType":"road"},
    {"featureType":"poi.park","elementType":"labels","stylers":[{"visibility":"on"},{"lightness":20}]},
    {"featureType":"road","stylers":[{"lightness":20}]}
  ],
  "SubtleGrayscale" : [
    {"featureType":"landscape","stylers":[{"saturation":-100},{"lightness":65},{"visibility":"on"}]},
    {"featureType":"poi","stylers":[{"saturation":-100},{"lightness":51},{"visibility":"simplified"}]},
    {"featureType":"road.highway","stylers":[{"saturation":-100},{"visibility":"simplified"}]},
    {"featureType":"road.arterial","stylers":[{"saturation":-100},{"lightness":30},{"visibility":"on"}]},
    {"featureType":"road.local","stylers":[{"saturation":-100},{"lightness":40},{"visibility":"on"}]},
    {"featureType":"transit","stylers":[{"saturation":-100},{"visibility":"simplified"}]},
    {"featureType":"administrative.province","stylers":[{"visibility":"off"}]},
    {"featureType":"water","elementType":"labels","stylers":[{"visibility":"on"},{"lightness":-25},{"saturation":-100}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"hue":"#ffff00"},{"lightness":-25},{"saturation":-97}]}
  ],
  "BlackWhite": [
    {"featureType":"administrative.land_parcel","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"landscape","elementType":"all","stylers":[{"visibility":"on"}]},
    {"featureType":"landscape","elementType":"geometry","stylers":[{"visibility":"off"},{"hue":"#ff0000"}]},
    {"featureType":"landscape","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"landscape.man_made","elementType":"geometry","stylers":[{"visibility":"on"},{"color":"#944242"}]},
    {"featureType":"landscape.man_made","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},
    {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"visibility":"on"},{"color":"#ffffff"}]},
    {"featureType":"landscape.natural.landcover","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"landscape.natural.terrain","elementType":"geometry","stylers":[{"visibility":"off"},{"saturation":"-1"}]},
    {"featureType":"poi","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"poi.attraction","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"visibility":"off"}]},
    {"featureType":"road.local","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"road.local","elementType":"geometry.fill","stylers":[{"color":"#7f7f7f"}]},
    {"featureType":"transit","elementType":"all","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.line","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.station","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.station.airport","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.station.bus","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.station.rail","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#dddddd"}]},
    {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#b0aaaa"}]},
    {"featureType":"water","elementType":"geometry.stroke","stylers":[{"visibility":"off"}]}
  ],
  "BlackWhiteNoLabels": [
    {"featureType":"all","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"administrative.land_parcel","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"landscape","elementType":"all","stylers":[{"visibility":"on"}]},
    {"featureType":"landscape","elementType":"geometry","stylers":[{"visibility":"off"},{"hue":"#ff0000"}]},
    {"featureType":"landscape","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"landscape.man_made","elementType":"geometry","stylers":[{"visibility":"on"},{"color":"#944242"}]},
    {"featureType":"landscape.man_made","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},
    {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"visibility":"on"},{"color":"#ffffff"}]},
    {"featureType":"landscape.natural.landcover","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"landscape.natural.terrain","elementType":"geometry","stylers":[{"visibility":"off"},{"saturation":"-1"}]},
    {"featureType":"poi","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"poi.attraction","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"visibility":"off"}]},
    {"featureType":"road.local","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"road.local","elementType":"geometry.fill","stylers":[{"color":"#7f7f7f"}]},
    {"featureType":"transit","elementType":"all","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.line","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.station","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.station.airport","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.station.bus","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"transit.station.rail","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#dddddd"}]},
    {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#b0aaaa"}]},
    {"featureType":"water","elementType":"geometry.stroke","stylers":[{"visibility":"off"}]}
  ]
}
window.googlemap.providers = {
  "OSM" : {
    getTileUrl: (coord, zoom) ->
      x = coord.x
      y = coord.y
      if x < 0
        x = Math.pow(2, zoom) + x while (x < 0)
      else if x > Math.pow(2, zoom) - 1
        x = x - Math.pow(2, zoom) while (x > Math.pow(2, zoom) - 1)
      if y < 0
        y = Math.pow(2, zoom) + y while (y < 0)
      else if y > Math.pow(2, zoom) - 1
        y = y - Math.pow(2, zoom) while (y > Math.pow(2, zoom) - 1)
      "http://tile.openstreetmap.org/" + zoom + "/" + x + "/" + y + ".png"
    tileSize: new google.maps.Size(256, 256),
    isPng: true,
    maxZoom: 19,
    minZoom: 0,
    name: "OSM"
  }
}
