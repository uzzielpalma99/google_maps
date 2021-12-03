import 'dart:async';

import 'package:dio/dio.dart';
import 'package:google_maps/app/domain/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class SearchAPI {
  final Dio _dio;
  CancelToken? _cancelToken; //Para poder cancelar una peticion que no ha terminado de ejecutarse, esto para evitar que se llame a la APi here miesntras el usuario busca y borra su busqueda
  SearchAPI(this._dio);
  final _controller = StreamController<List<Place>?>.broadcast();

  Stream<List<Place>?> get onResults => _controller.stream;

  void search(String query, LatLng at) async {
    try {
      _cancelToken = CancelToken();
      final response = await _dio.get('https://autosuggest.search.hereapi.com/v1/autosuggest',
      queryParameters: {
        "apiKey": '-plDP_dR7XAGxBSiHgTFyxkxNdjFFHqjQK9ge8b92CE',
        "q": query,
        "at": "${at.latitude},${at.longitude}",
        "in":"countryCode:MEX",
        "types":"place,street,city,locality,intersection"
      },
      cancelToken: _cancelToken, 
    );
    final results = (response.data['items'] as List)
    .map((e) => Place.fromJson(e),
    )
    .toList(); //Debido a que es una lista del response de api, 
    // tenemos que pasarlo a Mapa, luego a una lista, con la funcion map se itera cada elemneto y se almacena en Place.fromJson
    _controller.sink.add(results); //se agregan los resulyts al controller
    _cancelToken = null; //Una vez que finaliza la peticion
    } on DioError catch (e) {
      if (e.type != DioErrorType.cancel) {
        _controller.sink.add(null);
      }
    }
  }

  void cancel() { //Reinicioamos el valor del cancel a null
    if (_cancelToken != null) {
      _cancelToken!.cancel();
      _cancelToken = null;
    }
  }

  void dispose() {
    cancel();
    _controller.close();
  }
}