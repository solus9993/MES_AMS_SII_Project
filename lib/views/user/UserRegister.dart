import 'package:TrackerApp/models/User.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:flutter/material.dart';

class UserRegister extends StatefulWidget {
  @override
  _UserRegisterState createState() => new _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  User user = new User();
  static TextEditingController _emailController = new TextEditingController();
  static TextEditingController _passwordController =
      new TextEditingController();
  static TextEditingController _nameController = new TextEditingController();
  Widget widgetMsg = Column();

  _registerUser(context) async {
    user.email = _emailController.text.trim();
    user.password = _passwordController.text.trim();
    user.name = _nameController.text.trim();
    Commons.log(user.toJson());
    String msg = await user.register();
    if (msg != null) {
      Commons.showError(context, 'Register Error:', msg, Commons.colorErrorMsg);
      setState(() {});
    } else {
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: 160,
                alignment: Alignment.center,
                child: Text(
                  "REGISTER",
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Commons.input(Icon(Icons.account_circle), "NAME",
                    _nameController, false),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 20,
                ),
                child: Commons.input(
                    Icon(Icons.email), "EMAIL", _emailController, false),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Commons.input(
                    Icon(Icons.lock), "PASSWORD", _passwordController, true),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  child: Commons.button(
                      "REGISTER",
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor,
                      Commons.colorBodyBackgroud,
                      onPressed:_registerUser,
                      fParams:context),
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ]),
          ),
        ],
      ),
      height: MediaQuery.of(context).size.height / 1.1,
      width: MediaQuery.of(context).size.width,
      color: Commons.colorBodyBackgroud,
      // ),
      //   ),
    );
  }
}
