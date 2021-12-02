import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:google_maps/app/helpers/image_to_bytes.dart';
import 'package:google_maps/app/ui/utils/map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeController extends ChangeNotifier {
  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {}; //Se declaran los tipos polilynes
  final Map<PolygonId, Polygon> _polygons = {}; //Se declaran los tipos polygons

  Set<Marker> get markers => _markers.values.toSet();
  Set<Polyline> get polylines => _polylines.values.toSet(); //Se defin el metodo de polilyne
  Set<Polygon> get polygons => _polygons.values.toSet(); //Se defin el metodo de polygons

  late BitmapDescriptor _carPin; //Para utilizar el iocono del carro

  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;

  Position? _initialPosition, _lastPosition;
  Position? get initialPosition => _initialPosition;

  bool _loading = true;
  bool get loading => _loading;

  late bool _gpsEnabled;
  bool get gpsEnabled => _gpsEnabled;

  StreamSubscription? _gpsSubscription, _postionSubscription;
  GoogleMapController? _mapController;

  String _polylineId = '0';
  String _polygonId = '0';

  HomeController() {
    _init();
  }

  Future<void> _init() async {
    _carPin = BitmapDescriptor.fromBytes(
      await imageToBytes('assets/car-pin.png', width: 60),
    );
    _gpsEnabled = await Geolocator.isLocationServiceEnabled();
    _loading = false;
    _gpsSubscription = Geolocator.getServiceStatusStream().listen(
      (status) async {
        _gpsEnabled = status == ServiceStatus.enabled;
        if (_gpsEnabled) {
          _initLocationUpdates();
        }
      },
    );
    _initLocationUpdates();
  }
  
  Future<void> _initLocationUpdates() async { //es future porque en dispositivos reales el llamado a la ubicacion actual puede tardar
    bool initialized = false;
    await _postionSubscription?.cancel();//Se cancela la escucha de eventos anteriore, ya que se puede llamar muchas veces a initLocationUpdates
    _postionSubscription = Geolocator.getPositionStream(//Para conocer nuestra posicion GPS
      desiredAccuracy: LocationAccuracy.high, //Para evitar cambios bruscos en el movimiento de su rotacion 
      distanceFilter: 10, //Para hacer una rotacion mas fluida
    ).listen(
      (position) async { //Para no tener que renderizar varias veces el marcdor que se tiene, (carro)
        _setMyPositionMarker(position);
        if (initialized) {
          notifyListeners();
        }

        if (!initialized) {
          _setInitialPosition(position);
          initialized = true;
          notifyListeners();
        }

        if (_mapController != null) { //Para la vista de la camara se vaya moviendo con nuetsro dispositivo en el mapa
          final zoom = await _mapController!.getZoomLevel(); //se obtiene el zoom con el mapController actual
          final cameraUpdate = CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            zoom,
          );
          _mapController!.animateCamera(cameraUpdate);
        }
      },
      onError: (e) {
        if (e is LocationServiceDisabledException) { //se que se desactivo el gps y puedo notificar a la vista para que arroje el alert dialog
          _gpsEnabled = false;
          notifyListeners();
        }
      },
    );
  }

  void _setInitialPosition(Position position) { //se define la posicion actual
    if (_gpsEnabled && _initialPosition == null) {
      // _initialPosition = await Geolocator.getLastKnownPosition();
      _initialPosition = position;
    }
  }

  void _setMyPositionMarker(Position position) { //Enviar la posicion de nuestro marcador (carro)
    double rotation = 0;
    if (_lastPosition != null) {
      rotation = Geolocator.bearingBetween( //Para rotar el carro de acuerdo a la orientacion de nuetro punto
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
    }
    const markerId = MarkerId('my-position');
    final marker = Marker(
      markerId: markerId,
      position: LatLng(position.latitude, position.longitude),
      icon: _carPin,
      anchor: const Offset(0.5, 0.5), //Para ajustar el punto de nuestra localizacion enmedio del carro
      rotation: rotation,
    );
    _markers[markerId] = marker;
    _lastPosition = position;
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(mapStyle);
    _mapController = controller;
  }

  Future<void> turnOnGPS() => Geolocator.openLocationSettings();

  void newPolyline() { //para crear nuevos polilynes con +
    _polylineId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void newPolygon() { //para crear nuevos polygons con map
    _polygonId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void onTap(LatLng position) async {
    // final polylineId = PolylineId(_polylineId);
    // late Polyline polyline;
    // if (_polylines.containsKey(polylineId)) { //Si ya existe nuestro polilyne en nuestro mapa
    //   final tmp = _polylines[polylineId]!;
    //   polyline = tmp.copyWith( //Se crea una copia y lo que se modifica pointsParam
    //     pointsParam: [...tmp.points, position], //Se crea una nueva lista, y luego de pasa el nuevo punto que es position para que se vaya formando
    //   );
    // } else {
    //   final color = Colors.primaries[_polylines.length];
    //   polyline = Polyline(
    //     polylineId: polylineId,
    //     points: [position],
    //     width: 5, //ancho de la linea
    //     color: color, //color de la linea
    //     startCap: Cap.roundCap, //redondea bordes
    //     endCap: Cap.roundCap, //redondea bordes
    //   );
    // }

    //Para dibujar un poligono se necesitan almenos 3 puntos
    final polygonId = PolygonId(_polygonId); 
    late Polygon polygon;
    if (_polygons.containsKey(polygonId)) {
      final tmp = _polygons[polygonId]!;
      polygon = tmp.copyWith( //Se crea una copia y lo que se modifica pointsParam
        pointsParam: [...tmp.points, position], //Se crea una nueva lista, y luego de pasa el nuevo punto que es position para que se vaya formando
      );
    } else {
      final color = Colors.primaries[_polygons.length];
      polygon = Polygon(
        polygonId: polygonId,
        points: [position],
        strokeWidth: 4,
        strokeColor: color,
        fillColor: color.withOpacity(0.4),
      );
    }

    // _polylines[polylineId] = polyline;
    _polygons[polygonId] = polygon;

    notifyListeners();
  }

  @override
  void dispose() { //cuando se destruya la pagina
    _postionSubscription?.cancel();
    _gpsSubscription?.cancel();
    _markersController.close();
    super.dispose();
  }
}
