import 'dart:async';
import 'dart:convert';
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
import 'package:http/http.dart' as http;
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

  //get user's current location and set the map's camera to that location
  Future _gotoUserCurrentPosition() async {
    Position currentPosition = await getUserCurrentLocation();
    _goToSpecificAddress(LatLng(currentPosition.latitude, currentPosition.longitude));
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

          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 20,// Adjust the color as needed
                      ),
                      SizedBox(width: 8.0),
                      // Add spacing between icon and text
                      Text(

                        _draggedAddress.split(',')[0],
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    _draggedAddress,
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () {  },
                      child: Text("Enter Complete Address",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
                        ),
                        minimumSize: Size(double.infinity, 45),
                      )
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // int? _value = 0;

  // void _showAddressBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return Padding(
  //           padding: const EdgeInsets.all(15.0),
  //           child: Column(
  //
  //             children: [
  //               TextField(
  //                 decoration: InputDecoration(
  //                   filled: true,
  //                   fillColor: Colors.white,
  //                   hintText: "House/Flat number",
  //                   hintStyle: TextStyle(
  //                       color: Colors.grey.shade400,
  //                       fontWeight: FontWeight.w600),
  //                   contentPadding:
  //                   EdgeInsets.only(left: 20, bottom: 5, right: 5),
  //                   enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(15),
  //                       borderSide: BorderSide(color: Colors.grey.shade400)),
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //
  //               TextField(
  //                 decoration: InputDecoration(
  //                   filled: true,
  //                   fillColor: Colors.white,
  //                   hintText: "Landmark(Optional)",
  //                   hintStyle: TextStyle(
  //                       color: Colors.grey.shade400,
  //                       fontWeight: FontWeight.w600),
  //                   contentPadding:
  //                   EdgeInsets.only(left: 20, bottom: 5, right: 5),
  //                   enabledBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(15),
  //                       borderSide: BorderSide(color: Colors.grey.shade400)),
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //               Wrap(
  //                 spacing: 5.0,
  //                 children: List<Widget>.generate(
  //                   3,
  //                       (int index) {
  //                         String label = '';
  //                         switch (index) {
  //                           case 0:
  //                             label = 'Home';
  //                             break;
  //                           case 1:
  //                             label = 'Office';
  //                             break;
  //                           case 2:
  //                             label = 'Other';
  //                             break;
  //                         }
  //                     return ChoiceChip(
  //                       label: Text(label),
  //                       selected: _value == index,
  //                       onSelected: (bool selected) {
  //                         setState(() {
  //                           _value = selected ? index : null;
  //                         });
  //                       },
  //                     );
  //                   },
  //                 ).toList(),
  //               ),
  //             ],
  //           ),
  //         );
  //   });
  // }

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
  List<dynamic> _placesList = [];

  bool _isListVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();

    _textController.addListener(() {
      onChange();
    });

  }

  void onChange() {
    if(_sessionToken == null){
      setState(() {
        _sessionToken = uuid.v4();
      });
    }

    getSuggestion(_textController.text);
  }

  void getSuggestion(String input) async {
    String apiKey = 'AIzaSyAVWpA7zMjI41ix5PnInbFyre4C62RreGQ';
    String type = '(regions)';
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    String request = '$baseURL?input=$input&key=$apiKey&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();
    print(data);

    if(response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData.containsKey('predictions')) {
        setState(() {
          _placesList = jsonData['predictions'];
        });
      } else {
        print('No predictions found in JSON response');
      }
    }else {
      throw Exception('Failed to load');
    }

  }


  @override
  _init() async {

    if (widget.addressInit!.isNotEmpty) {
      _defaultLatLng = LatLng(widget.addressInit![1], widget.addressInit![0]);
      _draggedAddress = widget.addressInit![2];
    }
    else {
      _defaultLatLng = LatLng(28.6129, 77.2295);
      _draggedLatLng = _defaultLatLng;
      _gotoUserCurrentPosition();
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
      resizeToAvoidBottomInset: false,
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


            Center(
              child: Container(
                width: 100,
                child: Lottie.asset("assets/location_pin.json"),
              ),
            ),
            _showDraggedAddress(),
            Positioned(
              bottom: 215,
              left: 80,
              right: 80,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Shadow color
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 2), // Shadow offset
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () async {
                    getUserCurrentLocation().then((value) async {
                      CameraPosition cameraPosition = CameraPosition(
                          zoom: 17.5, target: LatLng(value.latitude, value.longitude));
                      final GoogleMapController controller = await _controller.future;
                      controller.animateCamera(
                          CameraUpdate.newCameraPosition(cameraPosition));
                      setState(() {
                        _textController.clear();
                      });
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 20,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 10,),
                      Text("Use Current Location", style: TextStyle(color: Colors.blue),),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _isListVisible = true;
                        });
                      },

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
                        suffixIcon: _textController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            setState(() {
                              _textController.clear(); // Clear the text field
                            });
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade400)),
                      ),
                    ),
                  ),
                ),
                if ( _placesList.isNotEmpty && _isListVisible)
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _placesList.length,
                            itemBuilder:  (context, index) {
                              return ListTile(
                                leading: Icon(
                                  Icons.location_on,
                                ),
                                title: Text(_placesList[index]['description']),
                                onTap: ()
                                async {
                                  List<Location> locations = await locationFromAddress(_placesList[index]['description']);
                                  // print(locations.last.latitude);
                                  // print(locations.last.longitude);
                                  LatLng position = LatLng(locations.last.latitude, locations.last.longitude);
                                  _goToSpecificAddress(position);

                                  setState(() {
                                    _textController.text = _placesList[index]['description'];
                                    _isListVisible = false;
                                  });
                                },
                              );
                            }

                        ),
                      ),
                    ),
                  ),
              ],
            ),

          ],
        ),

    );
  }
}
