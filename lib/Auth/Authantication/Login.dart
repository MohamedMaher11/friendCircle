import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmo/Auth/Authantication/signup.dart';
import 'package:socialmo/Auth/cubit/SigninCubit/signinCubit.dart';
import 'package:socialmo/Auth/cubit/SigninCubit/signinstate.dart';
import 'package:socialmo/Posts/Page/myposts.dart';
import 'package:socialmo/core/customtextformfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.welcomeback,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        myfun(
                          _emailController,
                          AppLocalizations.of(context)!.email,
                          Icon(Icons.email),
                          false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.requireemail;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        myfun(
                          _passwordController,
                          AppLocalizations.of(context)!.password,
                          Icon(Icons.lock),
                          true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!
                                  .requirepassword;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        BlocConsumer<LoginCubit, LoginState>(
                          listener: (context, state) {
                            if (state is LoginSuccess) {
                              setState(() {
                                _isLoading = false;
                              });
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyPosts(
                                    userId: state.user.uid,
                                    name: state.userInfo['name'],
                                    ProfileImage:
                                        state.userInfo['profile_image'],
                                    email: state.user.email.toString(),
                                    myid: state.userInfo['myid'],
                                    about_me: state.userInfo['about_me'],
                                    birthday: state.userInfo['birthday'],
                                    location: state.userInfo['location'],
                                  ),
                                ),
                              );
                            } else if (state is LoginFailure) {
                              setState(() {
                                _isLoading = false;
                              });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        AppLocalizations.of(context)!.error),
                                    content: Text(state.error),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!.ok),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (state is LoginLoading) {
                              setState(() {
                                _isLoading = true;
                              });
                            }
                          },
                          builder: (context, state) {
                            if (_isLoading) {
                              return Center(child: CircularProgressIndicator());
                            }
                            return ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<LoginCubit>(context)
                                      .signInWithEmailAndPassword(
                                          _emailController.text,
                                          _passwordController.text,
                                          context);
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Colors.purple,
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.login,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupPage(),
                              ),
                            );
                          },
                          child:
                              Text(AppLocalizations.of(context)!.createaccount),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
