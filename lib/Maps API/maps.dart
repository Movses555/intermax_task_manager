import 'dart:convert';

import 'package:flutter/material.dart' as w;
import 'package:universal_platform/universal_platform.dart';
import 'dart:html';
import 'package:universal_ui/universal_ui.dart';
import 'package:google_maps/google_maps.dart';

class MapsAPI {

  static var instance;

  static MapsAPI init() {
    if (instance == null) {
      instance = MapsAPI();
      return instance;
    } else {
      return instance;
    }
  }

  w.Widget getMaps(double? _lat, double? _long) {
    const String htmlId = "map";
    if(UniversalPlatform.isWeb){
      ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
        final mapOptions = MapOptions()
          ..zoom = 15.0
          ..center = LatLng(_lat, _long);

        final elem = DivElement()
          ..id = htmlId;
        final map = GMap(elem, mapOptions);

        const _icon = w.Icon(w.Icons.location_on_rounded);

        Marker(MarkerOptions()
          ..anchorPoint = Point(0.5, 0.5)
          ..icon = _icon
          ..position = LatLng(_lat, _long)
          ..map = map
          ..title = htmlId);

        return elem;
      });
    }
    return const w.HtmlElementView(viewType: htmlId);
  }



  w.Widget getMapsPolyLine(List<LatLng>? cords) {
    const String htmlId = "map";
    if(UniversalPlatform.isWeb){
      ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
        final mapOptions = MapOptions()
          ..zoom = 15.0
          ..center = LatLng(cords![0].lat, cords[0].lng);

        final elem = DivElement()
          ..id = htmlId;
        final map = GMap(elem, mapOptions);

        final polyline = Polyline(PolylineOptions()
          ..path = cords
          ..icons = [
            w.Image.asset('assets/images/maps_a.png') as IconSequence,
            w.Image.asset('assets/images/maps_b.png') as IconSequence
          ]
          ..strokeColor = "#75A9FF"
          ..strokeOpacity = 1.0
          ..strokeWeight = 3);
        polyline.map = map;

        return elem;
      });
    }
    return const w.HtmlElementView(viewType: htmlId);
  }
}