import 'dart:convert';
import 'package:blr_intern/otppage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Phone extends StatefulWidget {
  final String deviceId;
  const Phone({super.key, required this.deviceId});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  List<bool> isSelected = [true, false];
  final pnumber = TextEditingController();
  final email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawerScrimColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Image.asset(
              'asset/logo.png',
              height: 200,
            ),
          ),
          const SizedBox(height: 30),
          ToggleButtons(
            borderRadius: BorderRadius.circular(30),
            isSelected: isSelected,
            selectedColor: Colors.red,
            fillColor: Colors.red,
            color: Colors.grey,
            borderColor: Colors.red,
            selectedBorderColor: Colors.red,
            textStyle: const TextStyle(color: Colors.black),
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                }
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Phone',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Email',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Glad to see you!',
            style: TextStyle(fontSize: 30.0),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: isSelected[0] ? _phoneWidget() : _emailWidget(),
          ),
          GestureDetector(
            onTap: () async {
              try {
                Response request = await http.post(
                  Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/otp'),
                  body: {
                    "mobileNumber": pnumber.text,
                    "deviceId": widget.deviceId,
                  },
                );

                var rr = jsonDecode(request.body);
                var userid = rr["data"]["userId"];
                var did = rr["data"]["deviceId"];
                print(request.body);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(rr["data"]["message"])),
                  );
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Otppage(
                              pnumber: pnumber.text,
                              did: did.toString(),
                              userid: userid.toString(),
                            )));
              } catch (error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send OTP: $error')),
                  );
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(25.0),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                child: Text(
                  'SEND CODE',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneWidget() {
    return Container(
      key: const ValueKey<int>(1),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('Enter your phone number:',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone',
            ),
            controller: pnumber,
          ),
        ],
      ),
    );
  }

  Widget _emailWidget() {
    return Container(
      key: const ValueKey<int>(2),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('Enter your email address:',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            controller: email,
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
