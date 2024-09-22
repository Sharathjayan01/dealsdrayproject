import 'dart:convert';

import 'package:blr_intern/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Register extends StatelessWidget {
  final userid;
  Register({super.key, required this.userid});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final pass = TextEditingController();
    final referal = TextEditingController();
    Future mailsend() async {
      print('ok');
      Response rt = await http.post(
          Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/email/referral'),
          body: {
            "email": email.text,
            "password": pass.text,
            "referralCode": referal.text,
            "userId": "${userid}"
          });
      print(rt.body);
      var r = jsonDecode(rt.body);
      String x = r["data"]["message"];
      print(x);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(r["data"]["message"])),
        );
      });
      if (x == 'Successfully Added') {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        print('p');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Center(
              child: Image.asset('asset/logo.png'),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Let\'s Begin!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Please enter your credential to proceed',
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: Colors.grey),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Your Email',
                ),
                controller: email,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextField(
                obscureText: true, // Hide password input
                decoration: const InputDecoration(
                  labelText: 'Create Password',
                ),
                controller: pass,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Referral Code (Optional)',
                ),
                controller: referal,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: mailsend,
        backgroundColor: Colors.red,
        child: Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
