import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:google_maps/app/helpers/current_position.dart';
import 'package:google_maps/app/ui/utils/map_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'home_state.dart';



class HomeController extends ChangeNotifier {
  HomeState _state = HomeState.initialState; //Le pasamos el initialState 
  HomeState get state => _state; //Con este get solo voy a poder modificar el estado de mi state desde el homecontroller



  StreamSubscription? _gpsSubscription, _postionSubscription;
  GoogleMapController? _mapController;


  HomeController() {
    _init();
  }

  Future<void> _init() async {

    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    _state = state.copyWith(gpsEnabled: gpsEnabled); //El estado actual sea modificado con el valor de gpsEnabled
    _gpsSubscription = Geolocator.getServiceStatusStream().listen( //Escuchamos los cambios ene l gps de android
      (status) async {
        final gpsEnabled = status == ServiceStatus.enabled;
        if (gpsEnabled) {//En el caso de que gpsEnable sea tru, modificamos el estado
          _state = state.copyWith(gpsEnabled: gpsEnabled);
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

        if (!initialized) {
          _setInitialPosition(position);
          initialized = true;
          notifyListeners();
          // print("LOLAAAA");
        }
        CurrentPosition.i.setValue( //se almacena la posicion actual para que sea enviada a la API
          LatLng(position.latitude, 
          position.longitude),
          );
      },
      onError: (e) {
        if (e is LocationServiceDisabledException) { //se que se desactivo el gps y puedo notificar a la vista para que arroje el alert dialog
          _state = state.copyWith(gpsEnabled: false); //se controla el estado actual
          notifyListeners();
        }
      },
    );
  }

  void _setInitialPosition(Position position) { //se define la posicion actual
    if (state.gpsEnabled && state.initialPosition == null) { //La condicion se valida con el gpsenabled dentro del state
      // _initialPosition = await Geolocator.getLastKnownPosition();
      _state = state.copyWith(
        initialPosition: LatLng(
          position.latitude, 
          position.longitude,
          ),
        loading: false,
      );
    }
  }


  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(mapStyle);
    _mapController = controller;
  }

  Future<void> turnOnGPS() => Geolocator.openLocationSettings();



  @override
  void dispose() { //cuando se destruya la pagina
    _postionSubscription?.cancel();
    _gpsSubscription?.cancel();
    super.dispose();
  }
}
