import 'package:TrackerApp/main.dart';
import 'package:TrackerApp/models/User.dart';
import 'package:TrackerApp/providers/UserProvider.dart';
import 'package:TrackerApp/utils/commons.dart';
import 'package:TrackerApp/views/MyHomePage.dart';
import 'package:TrackerApp/views/init/InitializeLocationProvider.dart';
import 'package:TrackerApp/views/init/InitializeUserProviderData.dart';
import 'package:TrackerApp/views/user/UserRegister.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => new _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final title = 'LogIn';
  final _showAppBar = Commons.showAppBarUserLogin;
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      new GlobalKey<ScaffoldState>();
  static final TextEditingController _nameController =
      new TextEditingController();
  static final TextEditingController _passwordController =
      new TextEditingController();
  bool _isLoading = false;
  User user = new User();

  _loginUser(context) async {
    print('login');
    user.name = _nameController.text;
    user.password = _passwordController.text;
    setState(() {
      _isLoading = true;
    });
    String msg = await user.login();
    if (msg != null) {
      Commons.log('Login FAILED.');
      Commons.showError(context, 'Login Error:', msg, Commons.colorErrorMsg);
    } else {
      Commons.log('Login Successful.');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => ChangeNotifierProvider(
            create: (context) => UserProvider(),
            child: InitializeUserProviderData())),
          (Route<dynamic> route) => false);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: _showAppBar
            ? AppBar(
                title: Row(children: [
                  Icon(Icons.account_circle),
                  SizedBox(
                    width: 5,
                  ),
                  Text(this.title)
                ]),
              )
            : null,
        backgroundColor: Commons.colorBodyBackgroud,
        body: Container(
          child: _isLoading
              ? Commons.loading("Checking Credentials...")
              : ListView(
                  children: <Widget>[
                    _showAppBar
                        ? SizedBox(
                            height: 0,
                          )
                        : Container(
                            padding: EdgeInsets.only(top: 50),
                            child: Icon(
                              Icons.account_circle,
                              color: Commons.colorTheme,
                              size: 150,
                            )),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: _showAppBar ? 140 : 80,
                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      alignment: Alignment.center,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20, top: 10),
                      child: Commons.input(Icon(Icons.account_circle),
                          "NAME or EMAIL", _nameController, false),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Commons.input(Icon(Icons.lock), "PASSWORD",
                          _passwordController, true),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        child: Commons.button(
                          "LOGIN",
                          Colors.white,
                          Commons.colorTheme,
                          Commons.colorTheme,
                          Colors.white,
                          onPressed: _loginUser,
                          fParams: context,
                        ),
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    Padding(
                      child: Container(
                        child: OutlineButton(
                          borderSide:
                              BorderSide(color: Commons.colorTheme, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          child: Text(
                            "REGISTER",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Commons.colorTheme,
                              fontSize: 20,
                            ),
                          ),
                          onPressed: () async {
                            _scaffoldKey.currentState
                                .showBottomSheet<void>((BuildContext context) {
                              return UserRegister();
                            });
                          },
                        ),
                        height: 50,
                      ),
                      padding: EdgeInsets.only(top: 10, left: 80, right: 80),
                    ),
                  ],
                ),
        ));
  }
}
