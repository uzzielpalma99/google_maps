String distanceFormat(int valueInMeters) { //Pasar los valores de la respuesta de la API A metros o km
  if (valueInMeters >= 1000) {
    return "${(valueInMeters / 1000).toStringAsFixed(1)}\nkm";
  }
  return "$valueInMeters\nm";
}