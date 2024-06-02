import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmo/Auth/Authantication/Login.dart';
import 'package:socialmo/Auth/cubit/SignupCubit/SignupCubit.dart';
import 'package:socialmo/Auth/cubit/SignupCubit/Signupstate.dart';
import 'package:socialmo/core/customtextformfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  File? _imageFile;

  void _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      BlocProvider.of<SignupCubit>(context)
          .emit(SignupInitial()); // Rebuild UI with updated image
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthdayController.text = picked.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => SignupCubit(),
        child: BlocListener<SignupCubit, SignupState>(
          listener: (context, state) {
            if (state is SignupSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            } else if (state is SignupFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          child: BlocBuilder<SignupCubit, SignupState>(
            builder: (context, state) {
              if (state is SignupLoading) {
                return Center(child: CircularProgressIndicator());
              }

              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.signup,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                if (_imageFile != null)
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: FileImage(_imageFile!),
                                  )
                                else
                                  CircleAvatar(
                                    radius: 50,
                                    child: Icon(Icons.person),
                                  ),
                                ElevatedButton(
                                  onPressed: () => _pickImage(context),
                                  child: Text(
                                    AppLocalizations.of(context)!.selectimage,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.purple),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          myfun(
                              _nameController,
                              AppLocalizations.of(context)!.name,
                              Icon(Icons.person), validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.requirename;
                            }
                            return null;
                          }, false),
                          const SizedBox(height: 10),
                          myfun(
                              _emailController,
                              AppLocalizations.of(context)!.email,
                              Icon(Icons.email), validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.requireemail;
                            }
                            return null;
                          }, false),
                          const SizedBox(height: 10),
                          myfun(
                              _passwordController,
                              AppLocalizations.of(context)!.password,
                              Icon(Icons.lock), validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .requirepassword;
                            }
                            return null;
                          }, true),
                          const SizedBox(height: 10),
                          myfun(
                            _birthdayController,
                            AppLocalizations.of(context)!.birthday,
                            Icon(Icons.calendar_today),
                            false,
                            onTap: () {
                              _selectDate(context);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .requirebirthday;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          myfun(
                              _locationController,
                              AppLocalizations.of(context)!.location,
                              Icon(Icons.location_on), validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .requirelocation;
                            }
                            return null;
                          }, false),
                          const SizedBox(height: 10),
                          myfun(
                              _aboutMeController,
                              AppLocalizations.of(context)!.about_me,
                              Icon(Icons.info), validator: (value) {
                            if (value!.isEmpty) {
                              return AppLocalizations.of(context)!.about_me;
                            }
                            return null;
                          }, false,
                              maxLines: null,
                              keyboardType: TextInputType.multiline),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<SignupCubit>(context).signUp(
                                      name: _nameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      birthday: _birthdayController.text,
                                      location: _locationController.text,
                                      aboutMe: _aboutMeController.text,
                                      imageFile: _imageFile,
                                      lowercase:
                                          _nameController.text.toLowerCase());
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)!.signup,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.purple),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: Text(AppLocalizations.of(context)!
                                .alreadyhaveaccount),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
