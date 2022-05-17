import 'dart:convert';

import 'package:flutter/material.dart' as w;
import 'package:location/location.dart';
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

  w.Widget getMaps(double? _lat, double? _long, List<dynamic>? coords, bool _isPolylineRequired) {

    List<LocationData>? coordinates = [];
    List<LatLng>? pathCoordinates = [];

    if(_isPolylineRequired){
      coordinates = List<LocationData>.from(coords!.map((e) => LocationData.fromJson(e)));

      for(var coords in coordinates){
        pathCoordinates.add(LatLng(coords.latitude, coords.longitude));
      }
    }

    const String htmlId = "map";

    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      final mapOptions = MapOptions()
        ..zoom = 15.0
        ..center = LatLng(_isPolylineRequired ? coordinates![0].latitude : _lat, _isPolylineRequired ? coordinates![0].longitude : _long);

      final elem = DivElement()
        ..style.height = "100%"
        ..style.width = "100%"
        ..id = htmlId;
      final map = GMap(elem, mapOptions);

      const _icon = w.Icon(w.Icons.location_on_rounded);

      if(_isPolylineRequired){
        final polyline = Polyline(PolylineOptions()
          ..path = pathCoordinates
          ..strokeColor = "#FF9F00"
          ..strokeOpacity = 1.0
          ..strokeWeight = 3);
        polyline.map = map;
      }else{
        Marker(MarkerOptions()
          ..anchorPoint = Point(0.5, 0.5)
          ..icon = _icon
          ..position = LatLng(_lat, _long)
          ..map = map
          ..title = htmlId);
      }

      return elem;
    });
    return const w.HtmlElementView(viewType: htmlId);
  }

}