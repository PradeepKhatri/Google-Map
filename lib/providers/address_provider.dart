import "package:flutter/foundation.dart";

class AddressProvider extends ChangeNotifier {
  List<List<dynamic>> _address = [];

  List<dynamic> _selectedAddress = [];

  List<dynamic> get selectedAddress => _selectedAddress;

  set selectedAddress(value){
    _selectedAddress = value;
    notifyListeners();
  }

  // List<dynamic>
  // 0 : Longitude
  // 1 : Latitude
  // 2 : Address Name

  List<List<dynamic>> get address => _address;
}