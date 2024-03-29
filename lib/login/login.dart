import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highfive/home/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:highfive/home/home_event.dart';


class SetPhoneNumberWidget extends StatelessWidget {
  SetPhoneNumberWidget();

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    var controller = new TextEditingController();
    HomeBloc homebloc = context.read();
    return new Scaffold(
      body: SafeArea(
        child: new Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          decoration: new BoxDecoration(boxShadow: [new BoxShadow(color: Colors.grey)], color: Colors.white),
          alignment: Alignment.center,
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
                          },
                          verificationFailed: (FirebaseAuthException e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: new Text('Шота пошло не так с вашей смс')));
                            homebloc.add(SmsHasNotReceived());
                          },
                          codeSent: (String verificationId, int resendToken) {
                            print('code sent');
                            homebloc.add(SmsSentEvent(verificationId));
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {
                            ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: new Text('Смска потерялась. Давай еще.')));
                            homebloc.add(SmsHasNotReceived());
                          },
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

class SetSmsWidget extends StatelessWidget {
  String verificationId;
  int resendToken;

  SetSmsWidget(this.verificationId, {this.resendToken});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    var controller = new TextEditingController();
    return new Scaffold(
      body: SafeArea(
        child: new Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          decoration: new BoxDecoration(boxShadow: [new BoxShadow(color: Colors.grey)], color: Colors.white),
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
  }
}
