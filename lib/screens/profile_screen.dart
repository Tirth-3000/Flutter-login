// import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:login/screens/editprofile_screen.dart';

final ref = FirebaseDatabase.instance.ref('User');

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.uId});

  final String uId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedImage = '';
  String _userName = '';
  var _firstName = '';
  var _lastName = '';
  var _middleName = '';
  String _primaryPhoneNumber = '';
  String _secondaryPhoneNumber = '';

  String _primaryEmail = '';
  String _secondaryEmail = '';

  String _primaryAddress = '';
  String _secondaryAddress = '';

  String _birthDate = '';
  String _gender = '';

  String _discription = '';
  bool _isloading = false;
  final bool _isloadingPicture = false;

  var _isvisibleUserName = true;
  var _isvisiblePrimaryEmail = true;
  var _isvisibleSecondaryEmail = true;

  var _isvisiblePrimaryNumber = true;
  var _isvisibleSecondaryNumber = true;

  var _isvisiblePrimaryAddress = true;
  var _isvisibleSecondaryAddress = true;

  var _isvisibleDate = true;
  var _isvisibleGender = true;

  var _isvisibleDiscripton = true;

  @override
  void initState() {
    super.initState();
    _isloading = true;
    _getData();
  }

  void _getData() async {
    try {
      final snapshot = await ref.child(widget.uId).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print(data);

        setState(() {
          _firstName = data['firstName'] ?? '';
          _middleName = data['middleName'] ?? '';
          _lastName = data['lastName'] ?? '';
          _primaryPhoneNumber = data['phoneNumber'] ?? '';
          _secondaryPhoneNumber = data['phoneNumber2'] ?? '';
          _primaryEmail = data['email'] ?? '';
          _secondaryEmail = data['email2'] ?? '';
          _primaryAddress = data['primaryAddress'] ?? '';
          _secondaryAddress = data['secondaryAddress'] ?? '';
          _gender = data['gender'] ?? '';
          _birthDate = data['birthDate'] ?? '';
          _discription = data['description'] ?? '';
          _selectedImage = data['image'] ?? '';
        });
        setState(() {
          _userName = '$_firstName $_middleName $_lastName';
          if (_userName.isEmpty) {
            _isvisibleUserName = false;
          }
          if (_primaryPhoneNumber.isEmpty) {
            _isvisiblePrimaryNumber = false;
          }
          if (_primaryEmail.isEmpty) {
            _isvisiblePrimaryEmail = false;
          }
          if (_birthDate.isEmpty) {
            _isvisibleDate = false;
          }
          if (_primaryAddress.isEmpty) {
            _isvisiblePrimaryAddress = false;
          }
          if (_gender.isEmpty) {
            _isvisibleGender = false;
          }
          if (_secondaryPhoneNumber.isEmpty) {
            _isvisibleSecondaryNumber = false;
          }
          if (_secondaryEmail.isEmpty) {
            _isvisibleSecondaryEmail = false;
          }
          if (_secondaryAddress.isEmpty) {
            _isvisibleSecondaryAddress = false;
          }
          if (_discription.isEmpty) {
            _isvisibleDiscripton = false;
          }
        });
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Data is available'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
    _isloading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 65,
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.white, fontSize: 26),
          ),
          backgroundColor: const Color.fromARGB(255, 103, 39, 176),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditprofileScreen(
                      uId: widget.uId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              color: Colors.black,
            )
          ],
        ),
        body: _isloading == true
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 14,
                          ),
                          CircleAvatar(
                            backgroundImage: _selectedImage.isNotEmpty
                                ? NetworkImage(_selectedImage)
                                : const AssetImage('assets/images/luffy.jpg'),
                            radius: 70,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Visibility(
                            visible: _isvisibleUserName,
                            child: Text(
                              _userName,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Visibility(
                                    visible: _isvisiblePrimaryEmail,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Primary Email',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 133, 26, 209),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              _primaryEmail,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _isvisibleSecondaryEmail,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Secondary Email',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 133, 26, 209),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              _secondaryEmail,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _isvisiblePrimaryNumber,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Primary PhoneNumber',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 133, 26, 209),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              _primaryPhoneNumber,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _isvisibleSecondaryNumber,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Secondary PhoneNumber',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 133, 26, 209),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              _secondaryPhoneNumber,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _isvisibleGender,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Gender',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 133, 26, 209),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              _gender,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _isvisibleDate,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'BirthDate',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 133, 26, 209),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              _birthDate,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _isvisiblePrimaryAddress,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Primary Address',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 133, 26, 209),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              _primaryAddress,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _isvisibleSecondaryAddress,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Secondary Address',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 133, 26, 209),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              _secondaryAddress,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _isvisibleDiscripton,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'About Description',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 133, 26, 209),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              _discription,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      FirebaseAuth.instance.signOut();
                                    },
                                    child: const Text(
                                      'LogOut',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color:
                                            Color.fromARGB(255, 133, 26, 209),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
