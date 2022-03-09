import 'dart:convert';

import 'package:location/location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocationService{

  static LocationService? instance;
  static WebSocketChannel? _socketChannel;

  final Location _location = Location();

  LocationData? _locationData;

  static LocationService init(WebSocketChannel webSocketChannel){
    _socketChannel = webSocketChannel;
    if(instance == null){
      instance = LocationService();
      return instance!;
    }else{
      return instance!;
    }

  }

  void checkLocationPermission() async {
    PermissionStatus? _permissionGranted;

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _checkLocationStatus();
      }
    }
  }

  void _checkLocationStatus() async {
    bool? _serviceEnabled;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _locationData = await _location.getLocation();
  }


  void getCurrentLocation() async {
    double? lat = _locationData!.latitude;
    double? long = _locationData!.longitude;
    var locationData = {
      'current_lat' : lat,
      'current_long' : long,
    };
    _socketChannel!.sink.add(json.encode(locationData));
  }


  void getLocationChanges() {
    _location.onLocationChanged.listen((LocationData location){

      var locationData = {
        'lat' : location.latitude,
        'long' : location.longitude,
      };

      _socketChannel!.sink.add(json.encode(locationData));
    });
  }

}