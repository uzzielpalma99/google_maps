import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentPosition { //Me permitira esta clase obtener el valor actual de la posicion y ocuparlo en mi llamado a la API Here
  CurrentPosition._(); //Se va a utilizar un singleton
  static CurrentPosition i = CurrentPosition._();

  LatLng? _value;
  LatLng? get value => _value;

  void setValue(LatLng? v) {
    _value = v;
  }
  
}