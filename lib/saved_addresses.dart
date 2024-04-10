import 'package:first_app/home_screen.dart';
import 'package:first_app/providers/address_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


class SavedAddressesScreen extends StatefulWidget {

  @override
  _SavedAddressesScreenState createState() => _SavedAddressesScreenState();

}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(builder: (context , data , child){
      return Scaffold(
          appBar: AppBar(
            title: Text('Select a location'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Positioned(
                top: 40, left: 10, right: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Select Area, Street...",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                      prefixIcon: Icon(Icons.search, color: Colors.red[400],),
                      contentPadding: EdgeInsets.only(left: 20, bottom: 5, right: 5),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.grey.shade400)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              (data.selectedAddress.isNotEmpty) ? Text(data.selectedAddress[2]) : Container(),
              SizedBox(height: 20,),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeScreen()));
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 60,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius:
                    BorderRadius.circular(100),
                    border: Border.all(color: Colors.black)
                  ),
                  child: Text("Add New Address"),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.6,
                child: ListView.builder(
                    itemCount: data.address.length,
                    itemBuilder: (context , index){
                      return GestureDetector(
                        onTap: (){

                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => HomeScreen(addressInit: data.address[index],)));
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: 60,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                              BorderRadius.circular(100),
                              border: Border.all(color: Colors.black)
                          ),
                          child: Text(data.address[index][2]),
                        ),
                      );
                    }),
              )
            ],
          )

      );
    },);
  }
}