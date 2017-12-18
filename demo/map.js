var interactiveLayerId = 'label-amenity';
var defaultType = defaultType || 'map';
var cookieName = defaultType + 'Data';

var mapTypes = mapTypes || {
  map: 'm',
  orto: 'o',
  hybrid: 'h'
};
var mapData = {
  type: defaultType,
  zoom: 7,
  lat: 55.19114,
  lng: 23.87100,
  bearing: 0,
  pitch: 0
};

var showAttributes = [
  'name',
  'official_name',
  'alt_name',
  'street',
  'opening_hours',
  'email',
  'phone',
  'website',
  'heritage',
  'wikipedia',
  'height',
  'fee',
  'image',
  'style_lager'
];

var label = {
  official_name: 'Oficialus pavadinimas',
  alt_name: 'Kiti pavadinimai',
  street: 'Adresas',
  email: 'E-paštas',
  phone: 'Telefono nr.',
  fee: 'Mokestis'
};

var icons = {
  opening_hours: "fa fa-clock-o",
  email: 'fa fa-envelope-o',
  phone: 'fa fa-phone',
  website: 'fa fa-globe',
  heritage: 'fa fa-globe',
  wikipedia: 'fa fa-wikipedia-w',
  height: 'fa fa-arrows-v',
  style_lager: 'fa fa-beer'
};

var attributeType = {
  name: 'bold',
  website: 'link',
  image: 'image',
  street: 'address',
  heritage: 'kvr_link',
  wikipedia: 'wikipedia',
  height: 'height',
  fee: 'fee',
  style_lager: 'beer_styles'
};
var legendData = legendData || {};
var legendTechUrl = legendTechUrl || null;

if (!mapboxgl.supported()) {
  alert('Jūsų naršyklė nepalaiko Mapbox GL. Prašome atsinaujinti naršyklę.');
} else {
  if (hashData = getMapDataFromHashUrl()) {
    $.extend(mapData, hashData);
  }

  if (!hashData && (cookieData = readCookie(cookieName))) {
    $.extend(mapData, cookieData);
  }

  $("button[data-style='" + mapData.type + "']").addClass('active');
  $('#layers').removeClass('hidden');

  changeHashUrl();

  var map = new mapboxgl.Map({
    container: 'map',
    style: 'styles/' + mapData.type + '.json',
    zoom: mapData.zoom,
    minZoom: 7,
    maxZoom: 18,
    center: [mapData.lng, mapData.lat],
    hash: false,
    maxBounds: [20.880, 53.888, 26.862, 56.453],
    bearing: mapData.bearing,
    pitch: mapData.pitch
  })
    .addControl(new mapboxgl.NavigationControl(), 'top-left')
    .addControl(new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: true
    }), 'top-left')
    .on('sourcedata', function () {
      if (map.isStyleLoaded()) {
        poiInteractive();
      }
    })
    .on('moveend', function () {
      setMapData();
      changeHashUrl();
    })
    .on('load', function() {
      showLegend();
    });
}

$('#layers button').on('click', function (e) {
  if ($(this).hasClass('active')) {
    return false;
  }
  $('#layers button').removeClass('active');
  $(this).addClass('active');

  var selectLayer = $(e.target).data('style');
  map.setStyle('styles/' + selectLayer + '.json');

  mapData.type = selectLayer;
  changeHashUrl(mapData);
});

function changeHashUrl() {
  var formatHash = [];
  for (var key in mapData) {
    var value = mapData[key];
    if (key === 'type') {
      value = mapTypes[mapData.type]
    }
    formatHash.push(value);
  }
  window.location.hash = '#' + formatHash.join('/');
  storeCookie(cookieName, mapData);
}

function getMapDataFromHashUrl() {
  var hash = window.location.hash;
  if (hash.length > 0) {
    hash = hash.replace('#', '');

    // Add support old hash format: #l=55.23777,23.871,8,L
    var result = hash.match(new RegExp('l=([^]+)'));
    if (result) {
      var mapQueries = result[1].split(',');
      return {
        lat: parseFloat(mapQueries[0]),
        lng: parseFloat(mapQueries[1]),
        zoom: parseInt(mapQueries[2])
      };
    }

    var mapQueries = hash.split('/');

    // Add support old hash format: #8/55.23777/23.871
    if (mapQueries.length === 3) {
      return {
        zoom: parseFloat(mapQueries[0]),
        lat: parseFloat(mapQueries[1]),
        lng: parseFloat(mapQueries[2])
      }
    }

    if (mapQueries.length < 6) {
      return null;
    }

    var type = defaultType;
    for (var key in mapTypes) {
      if (mapTypes[key] === mapQueries[0]) {
        type = key;
        break;
      }
    }

    return {
      type: type,
      zoom: parseFloat(mapQueries[1]),
      lat: parseFloat(mapQueries[2]),
      lng: parseFloat(mapQueries[3]),
      bearing: parseInt(mapQueries[4]),
      pitch: parseInt(mapQueries[5])
    };
  }
  return null;
}

function setMapData() {
  mapData.zoom = Number(map.getZoom().toFixed(2));
  mapData.lat = Number(map.getCenter().lat.toFixed(5));
  mapData.lng = Number(map.getCenter().lng.toFixed(5));
  mapData.bearing = parseInt(map.getBearing());
  mapData.pitch = parseInt(map.getPitch());
}

function storeCookie(name, value) {
  var date = new Date();
  date.setDate(date.getDate() + 365);
  var expires = "expires=" + date.toUTCString();
  document.cookie = name + '=' + JSON.stringify(value) + ';domain=.' + window.location.host.toString() + ';path=/;' + expires;
}

function readCookie(name) {
  var result = document.cookie.match(new RegExp(name + '=([^;]+)'));
  if (result) {
    return JSON.parse(result[1]);
  }
  return null;
}

function poiInteractive() {
  map.off('mouseenter', interactiveLayerId, addMousePointerCursor);
  map.off('mouseleave', interactiveLayerId, removeMousePointerCursor);
  map.off('click', interactiveLayerId, poiOnClick);

  if (map.getLayer(interactiveLayerId)) {
    map.on('mouseenter', interactiveLayerId, addMousePointerCursor);
    map.on('mouseleave', interactiveLayerId, removeMousePointerCursor);
    map.on('click', interactiveLayerId, poiOnClick);
  }
}

function addMousePointerCursor() {
  map.getCanvas().style.cursor = 'pointer';
}

function removeMousePointerCursor() {
  map.getCanvas().style.cursor = '';
}

function poiOnClick(e) {
  var poi = e.features[0];
  var html = getHtml(poi).join('<br />');

  if (html.length) {
    new mapboxgl.Popup()
      .setLngLat(poi.geometry.coordinates)
      .setHTML(html)
      .addTo(map);
  }
}

function getHtml(poi) {
  return showAttributes
    .filter(function (prop_name) {
      return poi.properties[prop_name];
    })
    .map(function (prop_name) {
      var formatedValue = getFomatedValue(prop_name, poi.properties);

      if (icons[prop_name]) {
        return '<span class="icon"><i class="' + icons[prop_name] + '"></i></span> ' + formatedValue;
      }

      if (label[prop_name]) {
        return '<strong>' + label[prop_name] + ':</strong> ' + formatedValue;
      }

      return formatedValue;
    });
}

function getFomatedValue(attribute, properties) {
  var value = properties[attribute];
  switch (attributeType[attribute]) {
    case 'bold':
      return '<strong>' + value + '</strong>';
    case 'height':
      return value + ' m.';
    case 'fee':
      return value === 'yes' ? 'Yra' : 'Nėra';
    case 'link':
      return '<a href="' + value + '" target="_blank">' + value + '</a>';
    case 'kvr_link':
      return '<a href="https://kvr.kpd.lt/heritage/Pages/KVRDetail.aspx?lang=lt&MC=' + value + '" target="_blank">Kultūros vertybių registras</a>';
    case 'image':
      return '<img src="' + value + '" />';
    case 'address':
      return [properties['city'], properties['street'], properties['housenumber']].join(' ');
    case 'wikipedia':
      var splitValue = value.split(':');
      return '<a href="https://' + splitValue[0] + '.wikipedia.org/wiki/' + splitValue[1].replace(/\s/g, '_') + '" target="_blank">' + splitValue[1] + '</a>';
    case 'beer_styles':
      var styles = [];
      if (properties['style_lager'] == 'y') {
        styles.push('lageris');
      }
      if (properties['style_ale'] == 'y') {
        styles.push('elis');
      }
      if (properties['style_stout'] == 'y') {
        styles.push('stautas');
      }
      if (properties['style_ipa'] == 'y') {
        styles.push('IPA');
      }
      return '<b>Stiliai:</b> ' + styles.join(', ');
  }

  return value;
}

function showLegend() {
  if (Object.keys(legendData).length === 0) {
    return;
  }

  var legendBlock = document.createElement('div');;
  legendBlock.id = 'legend';
  legendBlock.classList.add('map-overlay');

  var legendHeader = document.createElement('strong');
  legendHeader.classList.add('legend-header');
  legendHeader.innerHTML = 'Sutartiniai ženklai';
  legendHeader.addEventListener('click', function (e) {
    e.stopPropagation();
    legendBlock.classList.toggle('active');
  });
  legendBlock.addEventListener('click', function(e) {
    e.stopPropagation();
    legendBlock.classList.add('active');
  });
  document.body.addEventListener('click', function() {
    if (legendBlock.classList.contains('active')) {
      legendBlock.classList.remove('active');
    }
  });

  legendBlock.appendChild(legendHeader);

  var ul = document.createElement('ul');
  ul.classList.add('legend-items');

  for (var key in legendData) {
    if (!legendData.hasOwnProperty(key)) {
      continue;
    }

    var legend = legendData[key];

    if (!legend.type) {
      continue;
    }

    var legendSymbolIcon = document.createElement('span');
    legendSymbolIcon.classList.add('label-' + legend.type, key);

    var legendSymbol = document.createElement('span');
    legendSymbol.classList.add('label-item');
    legendSymbol.appendChild(legendSymbolIcon);

    var legendItem = document.createElement('li');
    legendItem.appendChild(legendSymbol);
    legendItem.insertAdjacentHTML('beforeend', legend.label);

    ul.appendChild(legendItem);
  }
  legendBlock.appendChild(ul);

  if (legendTechUrl) {
    var legendUrl = document.createElement('a');
    legendUrl.classList.add('legend-doc');
    legendUrl.setAttribute('href', legendTechUrl);
    legendUrl.setAttribute('target', '_blank');
    legendUrl.innerHTML = 'Techninė informaciją';
    legendBlock.appendChild(legendUrl);
  }

  document.body.appendChild(legendBlock);
}