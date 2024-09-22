import 'dart:async';
import 'dart:convert';
import 'package:blr_intern/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Otppage extends StatefulWidget {
  final String pnumber;
  final String did;
  final String userid;
  Otppage({required this.pnumber, required this.did, required this.userid});

  @override
  _OtppageState createState() => _OtppageState();
}

class _OtppageState extends State<Otppage> {
  late Timer _timer;
  int _remainingTime = 120;
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();

  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  Future otpverification() async {
    String reslt = _otpController1.text +
        _otpController2.text +
        _otpController3.text +
        _otpController4.text;
    print(reslt);
    Response rt = await http.post(
        Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/otp/verification'),
        body: {
          "otp": '$reslt',
          "deviceId": "${widget.did}",
          "userId": "${widget.userid}"
        });
    print(rt.body);
    var t = jsonDecode(rt.body);
    if (t["data"]["message"] == "Successfully verified mobile number") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Register(
                    userid: "${widget.userid}",
                  )));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t["data"]["message"])),
        );
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _otpController1.dispose();
    _otpController2.dispose();
    _otpController3.dispose();
    _otpController4.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 100),
            Row(
              children: [
                SizedBox(width: 20),
                Image.asset(
                  'asset/otp.png',
                  width: 150,
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 20),
                Text(
                  'OTP Verification',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 20),
                Text(
                  'We have sent a unique OTP number \nto your mobile ${widget.pnumber}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _otpBox(context, _focusNode1, _focusNode2, _otpController1),
                _otpBox(context, _focusNode2, _focusNode3, _otpController2),
                _otpBox(context, _focusNode3, _focusNode4, _otpController3),
                _otpBox(context, _focusNode4, null, _otpController4),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                Text(
                  '${formatTime(_remainingTime)}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 200,
                ),
                Text('Send again'),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: otpverification,
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
      ),
    );
  }

  Widget _otpBox(BuildContext context, FocusNode currentNode,
      FocusNode? nextNode, TextEditingController controller) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        focusNode: currentNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            if (nextNode != null) {
              FocusScope.of(context).requestFocus(nextNode);
            } else {
              currentNode.unfocus();
            }
          }
        },
      ),
    );
  }
}
