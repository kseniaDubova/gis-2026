export const STYLE = {
  version: 8,
  sources: {
    overture: {
      type: "geojson",
      data: "/overture.geojson",
    },
  },
  layers: [
    {
      id: "buildings",
      type: "fill",
      source: "overture",
      paint: {
        "fill-color": [
          "match",
          ["get", "source_type"],
          "my",
          "#00FF00",
          "osm",
          "#0000FF",
          "ml",
          "#FFA500",
          "#CCCCCC",
        ],
        "fill-opacity": 0.7,
        "fill-outline-color": "#333333",
      },
    },
  ],
};
