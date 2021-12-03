import 'dart:async';

import 'package:flutter/widgets.dart' show ChangeNotifier;
import 'package:google_maps/app/domain/models/place.dart';
import 'package:google_maps/app/domain/models/repositories/search_repository.dart';
import 'package:google_maps/app/helpers/current_position.dart';

class SearchPlaceController extends ChangeNotifier {
  final SearchRepository _searchRepository;
  String _query = '';
  String get query => _query;

  late StreamSubscription _subscription;

  List<Place>? _places = [];
  List<Place>? get places => _places; //Get para obtener el valor de nuestra lista

  SearchPlaceController(this._searchRepository){
    _subscription =  _searchRepository.onResults.listen(
      (results) {
        print("results ${results?.length}");
        _places = results;
        notifyListeners();
      }
    );
  } //Se estaran escuchan los resultados de la API de Here Maps
  

  
  Timer? _debouncer; //Para esperar que el usuario ingrese su busqueda

  void onQueryChanged(String text) {
    _query = text;
    _debouncer?.cancel(); //se cancela la tarea anterior
    _debouncer = Timer(
      const Duration(milliseconds: 500), //espera 400 ms para llamar a la API
      () {
        if (_query.length >= 3) { //Si la buesqueda tiene 3 o mas caracteres, se llama a la API
          print('Call to API');
          final currentPosition = CurrentPosition.i.value;
          if (currentPosition != null) { //Verificamos ue la posicion actual no sea nula
            _searchRepository.cancel(); //Se cancelan peticiones anteriores
            _searchRepository.search(query, currentPosition); //_search es una funcion que retorna un future
          }
        }
        else {
          print('Cancel API call');
          _searchRepository.cancel();
          _places = [];
          notifyListeners(); //Se limpia las listas que se muestran en la bsuqueda
        }
      });
  }

  @override
  void dispose() {
    _debouncer?.cancel(); //En el momento que se destruya el searchplacecontroller, tamnbien destruimos el dispose
    _subscription.cancel();
    _searchRepository.dispose();
    super.dispose();
  }
}