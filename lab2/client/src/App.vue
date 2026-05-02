<template>
  <main>
    <div id="map"></div>
  </main>
</template>

<script setup>
import { onMounted } from 'vue'

import 'ol/ol.css'
import Map from 'ol/Map'
import View from 'ol/View'
import TileLayer from 'ol/layer/Tile'
import VectorLayer from 'ol/layer/Vector'
import VectorSource from 'ol/source/Vector'
import GeoJSON from 'ol/format/GeoJSON'
import XYZ from 'ol/source/XYZ'
import { fromLonLat } from 'ol/proj'

import { Style, Fill, Stroke } from 'ol/style'

onMounted(() => {

  const baseLayer = new TileLayer({
    source: new XYZ({
      url: 'https://{a-c}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png'
    })
  })

  const getStyle = (feature) => {
    const type = feature.get('source_type')

    let color = 'gray'

    if (type === 'my') color = 'green'
    else if (type === 'osm') color = 'blue'
    else if (type === 'ml') color = 'orange'

    return new Style({
      fill: new Fill({
        color: color
      }),
      stroke: new Stroke({
        color: '#333',
        width: 1
      })
    })
  }

  const overtureLayer = new VectorLayer({
    source: new VectorSource({
      url: '/overture.geojson',
      format: new GeoJSON({
        dataProjection: 'EPSG:4326',
        featureProjection: 'EPSG:3857'
      })
    }),
    style: getStyle
  })

  const map = new Map({
    target: 'map',
    layers: [
      baseLayer,
      overtureLayer
    ],
    view: new View({
      center: fromLonLat([50.85, 53.28]),
      zoom: 14
    })
  })

})
</script>
<style>
#map {
  width: 100%;
  height: 100vh;
}
</style>