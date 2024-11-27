import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:login/screens/profile_screen.dart';
import 'package:login/screens/signup_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _firebase = FirebaseAuth.instance;
final DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});
  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _form = GlobalKey<FormState>();
  bool? checkedValue = false;
  var _enteredemail = '';
  var _enteredpassword = '';
  bool _isPasswordVisible = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (isValid) {
      _form.currentState!.save();
      if (_form.currentState != null) {
        try {
          final userCredential = await _firebase.signInWithEmailAndPassword(
              email: _enteredemail, password: _enteredpassword);
          print(userCredential);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                uId: userCredential.user!.uid,
              ),
            ),
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
      print('Credential created successfully: $credential'); // Debugging log

      UserCredential credential1 =
          await _firebase.signInWithCredential(credential);
      print('User signed in successfully: ${credential1.user?.email}');

      await ref.child(credential1.user!.uid).set({
        'uid': credential1.user!.uid,
        'userName': credential1.user!.displayName,
        'email': credential1.user!.email,
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

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => HomeScreen(),
      //   ),
      // );
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
            const Padding(
              padding: EdgeInsets.all(6.0),
              child: Image(
                height: 180,
                width: double.infinity,
                image: AssetImage('assets/images/luffy.jpg'),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(left: 8),
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  'Hello,',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 95,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                              borderRadius: BorderRadius.circular(15),
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
                      height: 95,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                  _isPasswordVisible =
                                      !_isPasswordVisible; // Toggle password visibility
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Please enter at least 6 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredpassword = value!;
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              activeColor:
                                  const Color.fromARGB(255, 72, 5, 196),
                              value: checkedValue,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  checkedValue = newValue;
                                });
                              },
                            ),
                            const Text('Remember me'),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
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
                          'Sign In',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'or continue with',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 19),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const CircleBorder(),
                            side:
                                const BorderSide(color: Colors.grey, width: 2),
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
                            side:
                                const BorderSide(color: Colors.grey, width: 2),
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
                            side:
                                const BorderSide(color: Colors.grey, width: 2),
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
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account?',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        const SizedBox(width: 5),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupPage(),
                              ),
                            );
                          },
                          child: const Text('Sign Up'),
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
    );
  }
}
