import 'dart:async';
// import 'dart:js_util';

import 'package:first_app/providers/address_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
// import 'package:geolocator_android/geolocator_android.dart';

class HomeScreen extends StatefulWidget {
  final List<dynamic>? addressInit;
  const HomeScreen({super.key, this.addressInit = const []});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _controller = Completer();
  String _draggedAddress = "";
  late LatLng _defaultLatLng;
  late LatLng _draggedLatLng;
  CameraPosition? _cameraPosition;

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Geolocator Error!!");
    });

    return Geolocator.getCurrentPosition();
  }

  Widget _showDraggedAddress() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 4,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ]
          ),

          child: Column(
            children: [
              Container(
                child: Text(
                  _draggedAddress
                ),
              ),
              Container(
                child: Text(
                  _draggedAddress,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                  onPressed: () {print('click');},
                  child: Text("Enter Complete Address"),
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                  )
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future _getAddress(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark address = placemarks[0];
    String addressStr =
        "${address.street}, ${address.locality}, ${address.administrativeArea}, ${address.country}";
    setState(() {
      _draggedAddress = addressStr;
    });
  }

  Future _goToSpecificAddress(LatLng position) async {
    GoogleMapController mapController = await _controller.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16)));
  }

  loadData() {
    getUserCurrentLocation().then((value) async {
      CameraPosition cameraPosition = CameraPosition(
          zoom: 17.5, target: _defaultLatLng);
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      _goToSpecificAddress(_defaultLatLng);
    });
  }

  TextEditingController _textController = TextEditingController();
  var uuid = Uuid();
  String _sessionToken = '12345';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();

    // _controller.addListener(() {
    //   onChange();
    // });

  }

  void onChange() {
    if(_sessionToken == null){
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
  }

  // India gate  28.6129° N, 77.2295° E

  @override
  _init() {
    if (widget.addressInit!.isNotEmpty) {
      _defaultLatLng = LatLng(widget.addressInit![1], widget.addressInit![0]);
      _draggedAddress = widget.addressInit![2];
    } else {
      _defaultLatLng = LatLng(28.6129, 77.2295);
      _draggedLatLng = _defaultLatLng;
    }
    _cameraPosition = CameraPosition(
      target: _defaultLatLng,
      zoom: 15,
    );
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select Location'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                // myLocationEnabled: true,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                    target: _defaultLatLng,
                    zoom: 10),
                onCameraIdle: () {
                  _getAddress(_draggedLatLng);
                },
                onCameraMove: (cameraPosition) {
                  _draggedLatLng = cameraPosition.target;
                },
                onTap: (position) {
                  _goToSpecificAddress(position);
                },
                // markers: Set<Marker>.of(_markers),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Search",
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.normal),
                    prefixIcon: Icon(
                      Icons.search,
                    ),
                    contentPadding:
                        EdgeInsets.only(left: 20, bottom: 5, right: 5),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade400)),
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 100,
                child: Lottie.asset("assets/location_pin.json"),
              ),
            ),
            _showDraggedAddress(),
            // Positioned(
            //     bottom: 40,
            //     left: 40,
            //     right: 40,
            //     child: ElevatedButton(
            //       onPressed: () {
            //         List<dynamic> address = [];
            //         address.add(_draggedLatLng.longitude);
            //         address.add(_draggedLatLng.latitude);
            //         address.add(_draggedAddress);
            //         context.read<AddressProvider>().address.add(address);
            //         context.read<AddressProvider>().selectedAddress = address;
            //         context.read<AddressProvider>().notifyListeners();
            //         Navigator.pop(context);
            //       },
            //       child: Text("Save Address"),
            //     ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red.shade300,
          onPressed: () async {
            getUserCurrentLocation().then((value) async {
              CameraPosition cameraPosition = CameraPosition(
                  zoom: 17.5, target: LatLng(value.latitude, value.longitude));
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(cameraPosition));
              setState(() {});
            });
          },
          child: const Icon(
            Icons.my_location,
            size: 20,
          ),
        ));
  }
}
