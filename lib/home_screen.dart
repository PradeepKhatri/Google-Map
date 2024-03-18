import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator_android/geolocator_android.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {

  Completer<GoogleMapController> _controller = Completer();

  final List<Marker> _markers = <Marker> [

  ];



  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {
    }).onError((error, stackTrace) {
      print("Geolocator Error!!");
  }
  );

    return Geolocator.getCurrentPosition();


}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Choose Delivery Location")
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: GoogleMap(
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  10,
                  10
                ),
              zoom: 10),
              // onMapCreated: (GoogleMapController controller) {
                // _controller.complete(controller);
              // },
            ),
          ),
          Positioned(
            top: 10, left: 20, right: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Select Area, Street...",
                    suffixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.only(left: 20, bottom: 5, right: 5),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25),borderSide: BorderSide(color: Colors.white)),
                 ),
              ),
            ),
          ),

        ],
      ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // getUserCurrentLocation().then((value)async {
              //     _markers.add(
              //       Marker(
              //           markerId: MarkerId('2'),
              //         position: LatLng(value.latitude, value.longitude),
              //         infoWindow: InfoWindow(
              //           title: "Current Location"
              //         )
              //       )
              //     );
              //     CameraPosition cameraPosition = CameraPosition(
              //       zoom: 14,
              //         target: LatLng(value.latitude, value.longitude)
              //     );
              //     final GoogleMapController controller = await _controller.future;
              //     controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
              //     setState(() {
              //
              //     });
              // });
            }
        )
    );
  }

}
