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
import ImageLayer from 'ol/layer/Image'
import ImageWMS from 'ol/source/ImageWMS'
import { STYLE } from './assets/style'

import { applyStyle } from 'ol-mapbox-style'

onMounted(() => {

  const baseLayer = new TileLayer({
    source: new XYZ({
      url: 'https://{a-c}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png'
    })
  })

  const buildingsLayer = new ImageLayer({
    source: new ImageWMS({
      url: 'http://localhost:8080/geoserver/gis/wms',
      params: {
        LAYERS: 'gis:buildings',
        TILED: true,
        TRANSPARENT: true
      },
      ratio: 1,
      serverType: 'geoserver'
    })
  })

  const roadsLayer = new ImageLayer({
    source: new ImageWMS({
      url: 'http://localhost:8080/geoserver/gis/wms',
      params: {
        LAYERS: 'gis:roads',
        TILED: true,
        TRANSPARENT: true
      },
      ratio: 1,
      serverType: 'geoserver'
    })
  })

  const poisLayer = new ImageLayer({
    source: new ImageWMS({
      url: 'http://localhost:8080/geoserver/gis/wms',
      params: {
        LAYERS: 'gis:poi',
        TILED: true,
        TRANSPARENT: true
      },
      ratio: 1,
      serverType: 'geoserver'
    })
  })

  const overtureLayer = new VectorLayer({
    source: new VectorSource({
      url: '/overture.geojson',
      format: new GeoJSON({
        dataProjection: 'EPSG:4326',
        featureProjection: 'EPSG:3857'
      })
    })
  })

  const map = new Map({
    target: 'map',
    layers: [
      baseLayer,
      roadsLayer,
      poisLayer,
      buildingsLayer,
      overtureLayer  
    ],
    view: new View({
      center: fromLonLat([50.85, 53.28]),
      zoom: 14
    })
  })

  applyStyle(overtureLayer, STYLE, 'overture')

})
</script>

<style>
#map {
  width: 100%;
  height: 100vh;
}
</style>