import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login/screens/profile_screen.dart';

final DatabaseReference ref = FirebaseDatabase.instance.ref().child('User');

class EditprofileScreen extends StatefulWidget {
  const EditprofileScreen({super.key, required this.uId});
  final String uId;

  @override
  State<EditprofileScreen> createState() => _EditprofileScreenState();
}

class _EditprofileScreenState extends State<EditprofileScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _birthDateController;
  DateTime? _selectedDate;
  var _firstName = '';
  var _lastName = '';
  var _middleName = '';
  var _gender = '';
  var _birthDate;
  var _primaryPhoneNumber = '';
  var _secondaryPhoneNumber = '';
  var _primaryEmail = '';
  var _secondaryEmail = '';
  var _primaryAddress = '';
  var _secondaryAddress = '';
  var _aboutDescription = '';
  XFile? _selectedImage;
  String _profileImage = '';
  var _countryCode;
  var _countryCode1;
  bool _isLoading = false;
  var downloadUrl;

  @override
  void initState() {
    _isLoading = true;
    _getData();

    // _birthDateController = TextEditingController(text: _birthDate);
    super.initState();
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  void _getData() async {
    try {
      final snapshot = await ref.child(widget.uId).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print(data);

        setState(() {
          _firstName = data['firstName'] ?? '';
          _lastName = data['lastName'] ?? '';
          _middleName = data['middleName'] ?? '';
          _primaryPhoneNumber = data['phoneNumber'] ?? '';
          _secondaryPhoneNumber = data['phoneNumber2'] ?? '';
          _primaryEmail = data['email'] ?? '';
          _secondaryEmail = data['email2'] ?? '';
          _primaryAddress = data['primaryAddress'] ?? '';
          _secondaryAddress = data['secondaryAddress'] ?? '';
          _gender = data['gender'] ?? '';
          _aboutDescription = data['description'] ?? '';
          _profileImage = data['image'] ?? '';
          _birthDate = data['birthDate'] ?? '';
        });
        print(_primaryPhoneNumber);
        print(_primaryEmail);
        print(_firstName);
        print(_middleName);
        print(_birthDate);
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
    setState(() {
      _birthDateController = TextEditingController(text: _birthDate);

      print('thisssssssssssssss $_birthDate');
    });
    _isLoading = false;
  }

  void _SaveDetail() async {
    final Date = _birthDateController.text;
    final isValid = _form.currentState!.validate();

    if (isValid) {
      _form.currentState!.save();

      try {
        final ref1 = FirebaseStorage.instance
            .ref('images/${widget.uId}')
            .child(_selectedImage!.path);
        await ref1.putFile(File(_selectedImage!.path));
        downloadUrl = await ref1.getDownloadURL();
        setState(() {
          _profileImage = downloadUrl;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
      }
      if (downloadUrl == null) {
        downloadUrl = _profileImage;
      }
      try {
        await ref.child(widget.uId).set({
          'firstName': _firstName,
          'middleName': _middleName,
          'lastName': _lastName,
          'gender': _gender,
          'birthDate': Date,
          'phoneNumber': _primaryPhoneNumber,
          'phoneNumber2': _secondaryPhoneNumber,
          'email': _primaryEmail,
          'email2': _secondaryEmail,
          'primaryAddress': _primaryAddress,
          'secondaryAddress': _secondaryAddress,
          'description': _aboutDescription,
          'image': downloadUrl,
        }).onError(
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
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(uId: widget.uId),
        ),
      );
    }
  }

  void _takePicture() async {
    final imagePicker = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (imagePicker == null) {
      return;
    }
    setState(() {
      _selectedImage = imagePicker;
      _profileImage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _SaveDetail();
            },
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      body: _isLoading == true
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 14),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: _profileImage.isNotEmpty
                            ? NetworkImage(_profileImage)
                            : _selectedImage != null
                                ? FileImage(File(_selectedImage!.path))
                                : const AssetImage('assets/images/luffy.jpg'),
                        radius: 70,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(251, 226, 163, 237),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt_outlined),
                            onPressed: () {
                              _takePicture();
                            },
                            color: Colors.white,
                            iconSize: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'First Name',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      TextFormField(
                                        initialValue: _firstName,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          hintText: 'First name',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Enter valid name';
                                          }
                                          return null;
                                        },
                                        onSaved: (newValue) {
                                          _firstName = newValue!;
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Middle Name',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      TextFormField(
                                        initialValue: _middleName,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          hintText: 'Middle name',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Enter valid name';
                                          }
                                          return null;
                                        },
                                        onSaved: (newValue) {
                                          _middleName = newValue!;
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Last Name',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      TextFormField(
                                        initialValue: _lastName,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        decoration: InputDecoration(
                                          hintText: 'Last name',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Enter valid name';
                                          }
                                          return null;
                                        },
                                        onSaved: (newValue) {
                                          _lastName = newValue!;
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Gender',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        DropdownButtonFormField<String>(
                                          value: _gender.isNotEmpty
                                              ? _gender
                                              : null,
                                          hint: const Text('Select Gender'),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          items: <String>[
                                            'Male',
                                            'Female',
                                            'Other'
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? value) {},
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Select a Gender';
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            if (newValue != null) {
                                              _gender = newValue;
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'BirthDate',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        TextFormField(
                                          // initialValue: _birthDate,
                                          readOnly: true,
                                          controller: _birthDateController,
                                          decoration: InputDecoration(
                                            hintText: 'BirthDate',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            suffixIcon: const Icon(
                                                Icons.calendar_today),
                                          ),
                                          onTap: () async {
                                            DateTime? selectedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: _selectedDate ??
                                                  DateTime.now(),
                                              firstDate: DateTime(1900),
                                              lastDate: DateTime.now(),
                                            );
                                            if (selectedDate != null &&
                                                selectedDate != _selectedDate) {
                                              setState(() {
                                                _selectedDate = selectedDate;
                                                _birthDateController.text =
                                                    DateFormat.yMd()
                                                        .format(selectedDate);
                                              });
                                            }
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Select BirthDate';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 7),
                                  child: Text(
                                    'Primary PhoneNumber',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: TextFormField(
                                          initialValue: _primaryPhoneNumber,
                                          keyboardType: TextInputType.number,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: InputDecoration(
                                            hintText: 'Phone Number',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Enter a phone number';
                                            } else if (!RegExp(r'^[0-9]+$')
                                                .hasMatch(value.trim())) {
                                              return 'Only digits are allowed';
                                            } else if (value.trim().length !=
                                                10) {
                                              return 'Phone number must be 10 digits';
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            _primaryPhoneNumber = newValue!;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 7),
                                  child: Text(
                                    'Secondary PhoneNumber',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(width: 1),
                                        ),
                                        child: CountryCodePicker(
                                          onChanged: (value) {
                                            _countryCode1 = value.toString();
                                          },
                                          favorite: const ['IN', 'US'],
                                          initialSelection: 'IN',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: TextFormField(
                                          initialValue: _secondaryPhoneNumber,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Phone Number',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          onSaved: (newValue) {
                                            _secondaryPhoneNumber = newValue!;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Primary Email',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        TextFormField(
                                          initialValue: _primaryEmail,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: InputDecoration(
                                            hintText: 'Primary Email',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty ||
                                                !value.contains('@')) {
                                              return 'Please enter a valid email';
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            _primaryEmail = newValue!;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Secondary Email',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        TextFormField(
                                          initialValue: _secondaryEmail,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            hintText: 'Secondary Email',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          onSaved: (newValue) {
                                            _secondaryEmail = newValue!;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        8.0), // Adjusted padding for better spacing
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Primary Address',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          initialValue: _primaryAddress,
                                          keyboardType:
                                              TextInputType.streetAddress,
                                          maxLines: 2,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Enter your primary address',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            isDense: true,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.length <= 10) {
                                              return 'Enter address properly';
                                            }
                                            return null;
                                          },
                                          onSaved: (newValue) {
                                            _primaryAddress = newValue!;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Secondary Address',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        TextFormField(
                                          initialValue: _secondaryAddress,
                                          keyboardType:
                                              TextInputType.streetAddress,
                                          maxLines: 2,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Enter your secondary address',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          onSaved: (newValue) {
                                            if (newValue == null) {
                                              _secondaryAddress = newValue!;
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'About Description',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        TextFormField(
                                          initialValue: _aboutDescription,
                                          keyboardType:
                                              TextInputType.streetAddress,
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                            hintText: 'Enter your Description',
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          onSaved: (newValue) {
                                            if (newValue == null) {
                                              _aboutDescription = newValue!;
                                            }
                                          },
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
