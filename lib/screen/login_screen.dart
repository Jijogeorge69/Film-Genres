import 'package:flutter/material.dart';
import 'package:Films_List/views/film_list.dart';
import 'package:Films_List/views/film_welcome.dart';
import 'package:Films_List/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:Films_List/services/header_service.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  ProgressDialog dialog;

  _loginBtnClick() async {
    if (nameController.text.isEmpty) {
      showAlertDialog(context);
    } else {
      await dialog.show();
      _login();
    }
  }

  _moveToDisplay() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilmWelcome()),
    );
  }

  _login() async {
    final uri = Uri.http(BASE_URL, loginApi);

    var loginBody = {'username': nameController.text};

    final response = await http
        .post(uri,
            body: json.encode(loginBody),
            headers: ServiceHelper.getHeader(GlobalPasser.sessionToken))
        .timeout(Duration(seconds: requestTimeOut));

    var decodedResponse = json.decode(response.body.toString());
    print('jwt token $decodedResponse');
    await dialog.hide();

    if (decodedResponse != null) {
      if (decodedResponse['token'] != null) {
        GlobalPasser.session = decodedResponse['token'];
        _moveToDisplay();
      }
    }
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Alert!!!"),
      content: Text("Please enter username"),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    dialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      textDirection: TextDirection.rtl,
      isDismissible: true,
    );

    dialog.style(message: 'Please wait...');

    return Scaffold(
        appBar: AppBar(
          title: Text('Login Screen'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Film Genres',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User Name',
                    ),
                  ),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Login'),
                      onPressed: () {
                        _loginBtnClick();
                      },
                    )),
                FlatButton(
                  onPressed: () {
                    //forgot password screen
                  },
                  textColor: Colors.blue,
                  child: Text(''),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Display Films'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FilmList()),
                        );
                      },
                    )),
              ],
            )));
  }
}
