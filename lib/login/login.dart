import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetPhoneNumberWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    var controller = new TextEditingController();
    return new Scaffold(
      body: SafeArea(
        child: new Container(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Введите мобильник',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Введите мобильник';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (_formKey.currentState.validate()) {
                        var auth2 = FirebaseAuth.instance;
                        await auth2.verifyPhoneNumber(
                          phoneNumber: controller.value.text,
                          verificationCompleted: (PhoneAuthCredential credential) async {
                            print('Login autocompleted');
                            await auth2.signInWithCredential(credential);
                            Navigator.of(context).pop();
                          },
                          verificationFailed: (FirebaseAuthException e) {
                            ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: new Text('Шота пошло не так с вашей смс')));
                          },
                          codeSent: (String verificationId, int resendToken) {
                            print('code sent');
                            Navigator.of(context).push(new SmsRoute(verificationId, resendToken));
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                      }
                    },
                    child: Text('Проверить мобилку'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmsRoute extends MaterialPageRoute {
  String verificationId;
  int resendToken;

  SmsRoute(this.verificationId, this.resendToken)
      : super(builder: (BuildContext context) {
          final _formKey = GlobalKey<FormState>();
          var controller = new TextEditingController();
          return new Scaffold(
            body: SafeArea(
              child: new Container(
                alignment: Alignment.center,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'Смс код',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Смс код';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formKey.currentState.validate()) {
                              PhoneAuthCredential phoneAuthCredential =
                                  PhoneAuthProvider.credential(verificationId: verificationId, smsCode: controller.value.text);

                              // Sign the user in (or link) with the credential
                              await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text('Проверить смску'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
}
