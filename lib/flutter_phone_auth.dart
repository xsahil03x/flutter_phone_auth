import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class FlutterPhoneAuth extends StatefulWidget {
  @override
  _FlutterPhoneAuthState createState() => _FlutterPhoneAuthState();
}

class _FlutterPhoneAuthState extends State<FlutterPhoneAuth> {
  String _phoneNo;
  String _verificationId;

  /// You can change it as per your country.
  static final _countryCode = "+91";

  bool _isOtpFieldVisible = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _numberController = new TextEditingController();
  TextEditingController _otpController = new TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _onRegisterButtonClick() async {
    showProgressBar(context, "Requesting OTP...");
    this._phoneNo = _countryCode + _numberController.text;

    final PhoneVerificationCompleted verificationCompleted =
        (FirebaseUser user) {
      _navigateToHome();
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      Navigator.pop(context);
      switch (authException.code) {
        case 'invalidCredential':
          showSnackBar(_scaffoldKey, 'Incorrect phone number...');
          break;
        case 'quotaExceeded':
          showSnackBar(_scaffoldKey, 'Quota Exceeded for this number...');
          break;
      }
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this._verificationId = verificationId;
      Navigator.pop(context);
      setState(() {
        _isOtpFieldVisible = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print('timeout' + verificationId);
      this._verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNo,
        timeout: const Duration(seconds: 0),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future<void> _onOtpButtonClick() async {
    showProgressBar(context, "Verifying OTP, Please Wait!");
    String otp = _otpController.text.trim();

    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: otp,
    );

    await _auth.signInWithCredential(credential).then((user) {
      _navigateToHome();
    }).catchError((error) {
      Navigator.pop(context);
      switch (error.code) {
        case 'ERROR_INVALID_VERIFICATION_CODE':
          showSnackBar(_scaffoldKey, 'Invalid OTP...');
          break;
        case 'ERROR_SESSION_EXPIRED':
          showSnackBar(_scaffoldKey, 'OTP Expired...');
          break;
        case 'ERROR_INVALID_CREDENTIAL':
          showSnackBar(_scaffoldKey, 'Invalid Credentials...');
          break;
        case 'ERROR_USER_DISABLED':
          showSnackBar(_scaffoldKey, 'User Disabled...');
          break;
      }
    });
  }

  void _navigateToHome() async {
    /// To pop the Dialog
    Navigator.pop(context);

    await Future.delayed(
      Duration(milliseconds: 200),
    );

    showSnackBar(_scaffoldKey, "Login Successful");

    await Future.delayed(
      Duration(milliseconds: 700),
    );

    /// Navigate to the HomeScreen
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _numberController?.dispose();
    _otpController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Flutter Phone Auth'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 24.0),
              numberField(),
              _isOtpFieldVisible ? SizedBox(height: 24.0) : Container(),
              _isOtpFieldVisible ? otpField() : Container(),
              SizedBox(height: 24.0),
              registerOrSubmit(),
            ],
          ),
        ),
      ),
    );
  }

  Widget numberField() => TextField(
        controller: _numberController,
        keyboardType: TextInputType.phone,
        style: new TextStyle(color: Colors.black87, fontSize: 18.0),
        decoration: new InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(2.0),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
                right: 4.0,
              ),
              child: new Icon(Icons.phone),
            ),
            suffixStyle: TextStyle(color: Colors.grey[500], fontSize: 16.0),
            counterText: "",
            hintText: "Enter your number"),
        obscureText: false,
        maxLength: 10,
      );

  Widget otpField() => TextField(
        controller: _otpController,
        keyboardType: TextInputType.phone,
        style: new TextStyle(color: Colors.black87, fontSize: 18.0),
        decoration: new InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(2.0),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 4.0,
                right: 4.0,
              ),
              child: new Icon(Icons.phonelink_lock),
            ),
            suffixStyle: TextStyle(color: Colors.grey[500], fontSize: 16.0),
            counterText: "",
            hintText: "Enter OTP"),
        obscureText: false,
        maxLength: 6,
      );

  Widget registerOrSubmit() => RaisedButton(
        elevation: 2.0,
        color: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        textColor: Colors.white.withOpacity(0.9),
        onPressed:
            _isOtpFieldVisible ? _onOtpButtonClick : _onRegisterButtonClick,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          child: Text(
            _isOtpFieldVisible ? "Submit" : "Register",
            style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
          ),
        ),
      );

  static void showProgressBar(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => new Dialog(
            child: new Container(
              height: 80.0,
              padding: const EdgeInsets.all(20.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: new CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 1.0,
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: new Text(
                      text,
                      style: new TextStyle(
                          color: Colors.grey[700], fontSize: 14.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  static void showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: Text(text),
      duration: Duration(seconds: 2),
    ));
  }
}
