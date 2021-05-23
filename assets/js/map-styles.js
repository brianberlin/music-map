const defaultStyle = {
  color: '#ccc',
  weight: 1
}

export default {
  water: {	// Apply these options to the "water" layer...
    fill: true,
    fillColor: '#06cccc',
  },

  // And so on, until every layer in https://openmaptiles.org/schema/ has a style

  aeroway:defaultStyle,
  boundary: defaultStyle,
  building: defaultStyle,
  housenumber:defaultStyle,
  landcover:defaultStyle,
  landuse: defaultStyle,
  park: defaultStyle,
  place:defaultStyle,
  poi:defaultStyle,
  transportation: defaultStyle,
  transportation_name: defaultStyle,
  water:defaultStyle,
  water_name:defaultStyle,
  waterway:defaultStyle,
};