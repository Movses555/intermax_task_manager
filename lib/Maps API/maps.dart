import 'dart:convert';

import 'package:flutter/material.dart';
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

  Widget getMaps(double? _lat, double? _long) {
    const String htmlId = "map";
    if(UniversalPlatform.isWeb){
      ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
        final mapOptions = MapOptions()
          ..zoom = 15.0
          ..center = LatLng(40.792834, 43.846661);

        final elem = DivElement()..id = htmlId;
        final map = GMap(elem, mapOptions);
        return elem;
      });
    }
    return const HtmlElementView(viewType: htmlId);
  }
}