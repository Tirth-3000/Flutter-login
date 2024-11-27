import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login/screens/profile_screen.dart';

final DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');

class OtpScreen extends StatefulWidget {
  const OtpScreen(
      {super.key, required this.verificationId, required this.phoneNumber});

  final String phoneNumber;
  final String verificationId;

  @override
  State<OtpScreen> createState() {
    return _OtpScreenState();
  }
}

class _OtpScreenState extends State<OtpScreen> {
  final _form = GlobalKey<FormState>();

  final _otp1 = TextEditingController();
  final _otp2 = TextEditingController();
  final _otp3 = TextEditingController();
  final _otp4 = TextEditingController();
  final _otp5 = TextEditingController();
  final _otp6 = TextEditingController();

  void _verify() async {
    final String otp = _otp1.text +
        _otp2.text +
        _otp3.text +
        _otp4.text +
        _otp5.text +
        _otp6.text;
    print(otp);
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit OTP'),
        ),
      );
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      await ref.child(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'phoneNumber': widget.phoneNumber,
      }).then(
        (value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                uId: userCredential.user!.uid,
              ),
            ),
          );
        },
      ).onError(
        (error, stackTrace) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(6.0),
                child: Image(
                  height: 250,
                  width: double.infinity,
                  image: AssetImage('assets/images/luffy.jpg'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.topLeft,
                child: Text('OTP Verification',
                    style: GoogleFonts.lato(
                        fontSize: 27, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Enter OTP sent to your phone number',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(182, 35, 35, 41),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Form(
                key: _form,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 54,
                          width: 54,
                          child: TextFormField(
                            controller: _otp1,
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(87, 194, 149, 202),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: '0',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 54,
                          width: 54,
                          child: TextFormField(
                            controller: _otp2,
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(87, 194, 149, 202),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: '0',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 54,
                          width: 54,
                          child: TextFormField(
                            controller: _otp3,
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(87, 194, 149, 202),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: '0',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 54,
                          width: 54,
                          child: TextFormField(
                            controller: _otp4,
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(87, 194, 149, 202),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: '0',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 54,
                          width: 54,
                          child: TextFormField(
                            controller: _otp5,
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(87, 194, 149, 202),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: '0',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 54,
                          width: 54,
                          child: TextFormField(
                            controller: _otp6,
                            onChanged: (value) {
                              if (value.length == 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(87, 194, 149, 202),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: '0',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 250,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Didn\'t receive OTP? Click on',
                          style: TextStyle(color: Colors.black45, fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Resend',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _verify();
                          },
                          style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                            backgroundColor:
                                WidgetStateProperty.all<Color>(Colors.purple),
                          ),
                          child: const Text(
                            'Verify',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
