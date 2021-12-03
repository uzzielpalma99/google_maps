import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps/app/ui/pages/search_place/search_place_page.dart';

class WhereAreYouGoingButton extends StatelessWidget {
  const WhereAreYouGoingButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 35, //Mantener visible el logo de google 2da opcion
      left: 20,
      right: 20,
      child: SafeArea(
        child: CupertinoButton(
          onPressed: () {
            final route = MaterialPageRoute(
              builder: (_) => SearchPlacePage()
              );
            Navigator.push(context, route);
          },
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                  BoxShadow(
                  color: Colors.black26, 
                  blurRadius: 10, 
                  offset: Offset(0,4),
                  ),
                ],
            ),
            child: const Text(
              "Where ae you going",
              textAlign: TextAlign.center,
              style: TextStyle(
              color: Colors.black54
            ),),
          ), 
        ),
      ),
    );
  }
}