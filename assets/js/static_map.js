// assets/js/static_map.js
import * as mjslive from 'markerjs-live';

export default class {
  constructor(sampleImage, markerMaps) {
    this.markerMaps = markerMaps;
    const markers = this.markersListGenerator(this.markerMaps);
    this.config = this.configGenerator(markers);
    this.markerView = new mjslive.MarkerView(sampleImage);
    this.markerView.show(this.config);
  }

  configGenerator(markers) {
    return {
      width: 798,
      height: 775,
      markers: markers,
    };
  }

  updateMarkerDistance(imsi, distance, capacity_rate) {
    const markerIndex = this.markerMaps.findIndex(marker => marker.imsi == imsi);
    const marker = this.markerMaps[markerIndex];
    marker.distance = distance;
    marker.capacity_rate = capacity_rate;
    this.markerMaps[markerIndex] = marker;
  }

  updatePoint(imsi, distance, capacity_rate) {
    this.updateMarkerDistance(imsi, distance, capacity_rate);
    const markers = this.markersListGenerator(this.markerMaps);
    this.config = this.configGenerator(markers);
    this.markerView.close();
    this.markerView.show(this.config);
  }

  markersListGenerator(markerMaps) {
    const markers = [];
    markerMaps.forEach((marker, index) => {
      markers.push(this.markerGenerator(marker, index + 1));
    });
    return markers;
  }

  markerTextAndColor(capacity_rate) {
    const textAndColor = { text: capacity_rate.toString() + '%' };
    if (capacity_rate > 80) {
      textAndColor.color = '#fc2003';
    } else if (capacity_rate > 60) {
      textAndColor.color = '#fca903';
    } else {
      textAndColor.color = '#28fc03';
    }
    return textAndColor;
  }

  markerGenerator(marker, index) {
    const { left, top } = marker;
    const {text, color} = this.markerTextAndColor(marker.capacity_rate);

    return {
      bgColor: color,
      tipPosition: { x: -20, y: 70 },
      color: 'white',
      fontFamily: 'Helvetica, Arial, sans-serif',
      padding: 5,
      text: index + ') ' + text,
      left: left,
      top: top,
      width: 80,
      height: 75,
      rotationAngle: 0,
      visualTransformMatrix: {
        a: 1, b: 0, c: 0, d: 1, e: 0, f: 0,
      },
      containerTransformMatrix: {
        a: 1,
        b: 0,
        c: 0,
        d: 1,
        e: 0,
        f: 0,
      },
      typeName: 'CalloutMarker',
      state: 'select',
    };
  }

}
