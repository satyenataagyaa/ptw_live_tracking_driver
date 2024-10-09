// ignore_for_file: constant_identifier_names

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State createState() => MapViewState();
}

class MapViewState extends State<MapView>
    with AutomaticKeepAliveClientMixin<MapView> {
  static const LOCATION_ARROW_IMAGE_PATH =
      "assets/images/markers/location-arrow-blue.png";

  @override
  bool get wantKeepAlive {
    return true;
  }

  bg.Location? _stationaryLocation;
  // bg.Location? _lastLocation;

  LatLng _currentPosition =
      const LatLng(40.712939536467424, -74.55517628644046);

  final List<LatLng> _polyline = [];
  final List<Marker> _locations = [];
  final List<CircleMarker> _stopLocations = [];
  final List<Polyline> _motionChangePolylines = [];
  final List<CircleMarker> _stationaryMarker = [];

  final LatLng _center = const LatLng(40.712939536467424, -74.55517628644046);

  late MapController _mapController;
  late MapOptions _mapOptions;

  @override
  void initState() {
    super.initState();
    _mapOptions = MapOptions(
      onPositionChanged: _onPositionChanged,
      center: _center,
      zoom: 12.0,
    );
    _mapController = MapController();

    bg.BackgroundGeolocation.onLocation(_onLocation);
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
    bg.BackgroundGeolocation.onEnabledChange(_onEnabledChange);
  }

  void _onEnabledChange(bool enabled) {
    if (!enabled) {
      setState(() {
        _locations.clear();
        _polyline.clear();
        _stopLocations.clear();
        _motionChangePolylines.clear();
        _stationaryMarker.clear();
      });
    }
  }

  void _onMotionChange(bg.Location location) async {
    LatLng ll = LatLng(location.coords.latitude, location.coords.longitude);

    _updateCurrentPositionMarker(ll);

    _mapController.move(ll, 16);

    // clear the big red stationaryRadius circle.
    _stationaryMarker.clear();

    if (location.isMoving) {
      _stationaryLocation ??= location;
      // Add previous stationaryLocation as a small red stop-circle.
      _stopLocations.add(_buildStopCircleMarker(_stationaryLocation!));
      // Create the green motionchange polyline to show where tracking engaged from.
      _motionChangePolylines
          .add(_buildMotionChangePolyline(_stationaryLocation!, location));
    } else {
      // Save a reference to the location where we became stationary.
      _stationaryLocation = location;
      // Add the big red stationaryRadius circle.
      bg.State state = await bg.BackgroundGeolocation.state;
      setState(() {
        _stationaryMarker.add(_buildStationaryCircleMarker(location, state));
      });
    }
  }

  void _onLocation(bg.Location location) {
    // _lastLocation = location;
    LatLng ll = LatLng(location.coords.latitude, location.coords.longitude);
    _mapController.move(ll, _mapController.zoom);

    _updateCurrentPositionMarker(ll);

    if (location.sample) {
      return;
    }

    // Add a point to the tracking polyline.
    _polyline.add(ll);
    // Add a marker for the recorded location.
    //_locations.add(_buildLocationMarker(location));
    //_locations.add(CircleMarker(point: ll, color: Colors.black, radius: 5.0));
    //_locations.add(CircleMarker(point: ll, color: Colors.blue, radius: 4.0));

    double heading = (location.coords.heading >= 0)
        ? location.coords.heading.round().toDouble()
        : 0;
    _locations.add(Marker(
        point: ll,
        width: 16,
        height: 16,
        rotate: false,
        builder: (context) {
          return Transform.rotate(
              angle: (heading * (math.pi / 180)),
              child: Image.asset(LOCATION_ARROW_IMAGE_PATH));
        }));
  }

  /// Update Big Blue current position dot.
  void _updateCurrentPositionMarker(LatLng ll) {
    setState(() {
      _currentPosition = ll;
    });
    /*
    // White background
    _currentPosition
        .add(CircleMarker(point: ll, color: Colors.white, radius: 10));
    // Blue foreground
    _currentPosition
        .add(CircleMarker(point: ll, color: Colors.blue, radius: 7));

   */
  }

  CircleMarker _buildStationaryCircleMarker(
      bg.Location location, bg.State state) {
    return CircleMarker(
        point: LatLng(location.coords.latitude, location.coords.longitude),
        color: const Color.fromRGBO(255, 0, 0, 0.5),
        useRadiusInMeter: true,
        radius: (state.trackingMode == 1)
            ? 200
            : (state.geofenceProximityRadius! / 2));
  }

  Polyline _buildMotionChangePolyline(bg.Location from, bg.Location to) {
    return Polyline(points: [
      LatLng(from.coords.latitude, from.coords.longitude),
      LatLng(to.coords.latitude, to.coords.longitude)
    ], strokeWidth: 10.0, color: const Color.fromRGBO(22, 190, 66, 0.7));
  }

  CircleMarker _buildStopCircleMarker(bg.Location location) {
    return CircleMarker(
        point: LatLng(location.coords.latitude, location.coords.longitude),
        color: const Color.fromRGBO(200, 0, 0, 0.3),
        useRadiusInMeter: false,
        radius: 20);
  }

  void _onPositionChanged(MapPosition pos, bool hasGesture) {
    _mapOptions.crs.scale(_mapController.zoom);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(children: [
      Container(
        color: const Color(0xfffff1a5),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 15,
            ),
            // Text(
            //   "Long-press on map to add Geofences",
            //   style: TextStyle(color: Colors.black),
            // ),
          ],
        ),
      ),
      Expanded(
          child: FlutterMap(
              mapController: _mapController,
              options: _mapOptions,
              children: [
            TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            // Active geofence circles
            // CircleLayer(circles: _geofences),
            // PolygonLayer(polygons: _geofencePolygons),
            // Small, red circles showing where motionchange:false events fired.
            CircleLayer(circles: _stopLocations),
            // Recorded locations.
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _polyline,
                  strokeWidth: 10.0,
                  color: const Color.fromRGBO(0, 179, 253, 0.6),
                ),
              ],
            ),
            // Polyline joining last stationary location to motionchange:true location.
            PolylineLayer(polylines: _motionChangePolylines),
            MarkerLayer(markers: _locations),
            // Geofence events (edge marker, event location and polyline joining the two)
            CircleLayer(circles: [
              // White background
              CircleMarker(
                  point: _currentPosition, color: Colors.white, radius: 10),
              // Blue foreground
              CircleMarker(
                  point: _currentPosition, color: Colors.blue, radius: 7)
            ]),
          ]))
    ]);
  }
}
