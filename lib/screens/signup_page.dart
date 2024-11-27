import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login/screens/profile_screen.dart';
import 'package:login/screens/otp_screen.dart';
import 'package:login/screens/signin_page.dart';

final _firebase = FirebaseAuth.instance;
final DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignupPage> {
  final _formemail = GlobalKey<FormState>();
  final _formnumber = GlobalKey<FormState>();
  bool? checkedValue1 = false;
  bool? checkedValue2 = false;
  var _enteredphonenumber = '';
  var _enteredemail = '';
  var _enteredpassword = '';
  var _enteredname = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  var _conformpassword = '';
  int _selectedIndex = 0;
  var _countryCode = '+91';

  void _submitemail() async {
    final isValid = _formemail.currentState!.validate();

    if (checkedValue1 == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isValid) {
      _formemail.currentState!.save();
      if (_formemail.currentState != null) {
        try {
          final userCredential = await _firebase.createUserWithEmailAndPassword(
              email: _enteredemail, password: _enteredpassword);

          await ref.child(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'userName': _enteredname,
            'email': _enteredemail,
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
              print(error.toString());
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.toString()),
                ),
              );
            },
          );
        } on FirebaseAuthException catch (error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message ?? 'Authentication Error'),
            ),
          );
        }
      }
    }
  }

  void _submitnumber() async {
    final isValid = _formnumber.currentState!.validate();

    if (checkedValue2 == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isValid) {
      _formnumber.currentState!.save();
      if (_formnumber.currentState != null) {
        try {
          _firebase.verifyPhoneNumber(
            phoneNumber: _countryCode + _enteredphonenumber,
            timeout: const Duration(minutes: 2),
            verificationCompleted: (PhoneAuthCredential credential) {},
            verificationFailed: (error) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.message ?? 'phone number error'),
                ),
              );
            },
            codeSent: (verificationId, forceResendingToken) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpScreen(
                    verificationId: verificationId,
                    phoneNumber: _enteredphonenumber,
                  ),
                ),
              );
            },
            codeAutoRetrievalTimeout: (verificationId) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Retrival time out '),
                ),
              );
            },
          );
        } on FirebaseAuthException catch (error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message ?? 'Authentication Error'),
            ),
          );
        }
      }
    }
  }

  void _signWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential credential1 =
          await _firebase.signInWithCredential(credential);
      print('User signed in successfully: ${credential1.user}');

      await ref.child(credential1.user!.uid).set({
        'uid': credential1.user!.uid,
        'userName': credential1.user!.displayName,
        'email': credential1.user!.email,
        'phoneNumber': credential1.user!.phoneNumber,
      }).then(
        (value) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                uId: credential1.user!.uid,
              ),
            ),
          );
        },
      ).onError(
        (error, stackTrace) {
          print(error.toString());
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        },
      );
    } catch (error) {
      print('Error occurred during Google Sign-In: $error'); // Debugging log
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SafeArea(
                    child: Container(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Skip'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ToggleButtons(
                  onPressed: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  isSelected: [_selectedIndex == 0, _selectedIndex == 1],
                  borderRadius: BorderRadius.circular(13),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 65),
                      child: Text('Email'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 65),
                      child: Text('Number'),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerLeft,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              if (_selectedIndex == 0)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Form(
                    key: _formemail,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 86,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                              autocorrect: false,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'UserName',
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(160, 39, 26, 25),
                                ),
                                filled: true,
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a valid username';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredname = value!;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 86,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(160, 39, 26, 25),
                                ),
                                filled: true,
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredemail = value!;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 86,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(160, 39, 26, 25),
                                ),
                                filled: true,
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Please enter at least 6 characters';
                                }
                                _conformpassword = value;
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 86,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(160, 39, 26, 25),
                                ),
                                filled: true,
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length < 6 ||
                                    value != _conformpassword) {
                                  return 'Enter Same Password';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredpassword = _conformpassword;
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              activeColor:
                                  const Color.fromARGB(255, 72, 5, 196),
                              value: checkedValue1,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  checkedValue1 = newValue;
                                });
                              },
                            ),
                            RichText(
                              text: const TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'I agree with ',
                                    style: TextStyle(
                                      color: Color.fromARGB(172, 40, 33, 33),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(182, 118, 42, 139),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: TextStyle(
                                      color: Color.fromARGB(172, 40, 33, 33),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Policy',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(182, 118, 42, 139),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitemail,
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.purple),
                            ),
                            child: const Text(
                              'Sign Up',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'or continue with',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                side: const BorderSide(
                                    color: Colors.grey, width: 2),
                                padding: const EdgeInsets.all(4),
                              ),
                              onPressed: () {
                                _signWithGoogle();
                              },
                              child: Image.asset(
                                'assets/images/google.png',
                                height: 45,
                                width: 45,
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                side: const BorderSide(
                                    color: Colors.grey, width: 2),
                                padding: const EdgeInsets.all(4),
                              ),
                              onPressed: () {},
                              child: Image.asset(
                                'assets/images/facebook.jpeg',
                                height: 45,
                                width: 45,
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                side: const BorderSide(
                                    color: Colors.grey, width: 2),
                                padding: const EdgeInsets.all(4),
                              ),
                              onPressed: () {},
                              child: Image.asset(
                                'assets/images/apple.png',
                                height: 45,
                                width: 45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16),
                            ),
                            const SizedBox(width: 5),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SigninPage(),
                                  ),
                                );
                              },
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (_selectedIndex == 1)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Form(
                    key: _formnumber,
                    child: Column(
                      children: [
                        const Image(
                          height: 250,
                          width: double.infinity,
                          image: AssetImage('assets/images/luffy.jpg'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(width: 1),
                              ),
                              child: CountryCodePicker(
                                onChanged: (value) {
                                  _countryCode = value.toString();
                                },
                                favorite: const ['IN', 'US'],
                                initialSelection: 'IN',
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Phone Number',
                                    hintStyle: const TextStyle(
                                      color: Color.fromARGB(160, 39, 26, 25),
                                    ),
                                    filled: true,
                                    // prefixIcon: const Icon(Icons.phone),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 10 ||
                                        value.trim().length > 10) {
                                      return 'Enter valid Phone number';
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _enteredphonenumber = newValue!;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              activeColor:
                                  const Color.fromARGB(255, 72, 5, 196),
                              value: checkedValue2,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  checkedValue2 = newValue;
                                });
                              },
                            ),
                            RichText(
                              text: const TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'I agree with ',
                                    style: TextStyle(
                                      color: Color.fromARGB(172, 40, 33, 33),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(182, 118, 42, 139),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: TextStyle(
                                      color: Color.fromARGB(172, 40, 33, 33),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Policy',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(182, 118, 42, 139),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitnumber,
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.purple),
                            ),
                            child: const Text(
                              'Sign Up',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'or continue with',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                side: const BorderSide(
                                    color: Colors.grey, width: 2),
                                padding: const EdgeInsets.all(4),
                              ),
                              onPressed: () {
                                _signWithGoogle();
                              },
                              child: Image.asset(
                                'assets/images/google.png',
                                height: 45,
                                width: 45,
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                side: const BorderSide(
                                    color: Colors.grey, width: 2),
                                padding: const EdgeInsets.all(4),
                              ),
                              onPressed: () {},
                              child: Image.asset(
                                'assets/images/facebook.jpeg',
                                height: 45,
                                width: 45,
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: const CircleBorder(),
                                side: const BorderSide(
                                    color: Colors.grey, width: 2),
                                padding: const EdgeInsets.all(4),
                              ),
                              onPressed: () {},
                              child: Image.asset(
                                'assets/images/apple.png',
                                height: 45,
                                width: 45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16),
                            ),
                            const SizedBox(width: 5),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SigninPage(),
                                  ),
                                );
                              },
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
