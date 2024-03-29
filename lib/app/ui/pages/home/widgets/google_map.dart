import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:google_maps/app/ui/pages/home/widgets/where_are_you_going_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controller/home_controller.dart';

class MapView extends StatelessWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (_, controller, gpsMessageWidget) {
        final state = controller.state;
        if (!state.gpsEnabled) {
          return gpsMessageWidget!;
        }

        final initialCameraPosition = CameraPosition(
          target: LatLng(
            state.initialPosition!.latitude,
            state.initialPosition!.longitude,
          ),
          zoom: 15,
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              markers: state.markers.values.toSet(),
              polylines: state.polylines.values.toSet(),
              onMapCreated: controller.onMapCreated,
              initialCameraPosition: initialCameraPosition,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              compassEnabled: false,
              zoomControlsEnabled: false, //esconde los botones de zoom
              // padding: EdgeInsets.only(bottom: 100), //Mantiene visible el logo de google 1 opcion
            ),
            const WhereAreYouGoingButton(),
          ],
        );
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "To use our app we need the access to your location,\n so you must enable the GPS",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final controller = context.read<HomeController>();
                controller.turnOnGPS();
              },
              child: const Text("Turn on GPS"),
            ),
          ],
        ),
      ),
    );
  }
}


