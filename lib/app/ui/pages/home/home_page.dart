import 'package:flutter/material.dart';
import 'package:google_maps/app/ui/pages/home/controller/home_controller.dart';
import 'package:google_maps/app/ui/pages/home/widgets/google_map.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>(
      create: (_) {
        final controller = HomeController();
        return controller;
      },
      child: Scaffold(
        body: Selector<HomeController, bool>(
          selector: (_, controller) => controller.state.loading,
          builder: (context, loading, loadingWidget) {
            if (loading) {
              return loadingWidget!;
            }
            return const MapView();
          },
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
