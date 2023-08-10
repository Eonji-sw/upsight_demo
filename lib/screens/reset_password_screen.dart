import 'package:flutter/material.dart';
import '../models/model_reset_password.dart';
import '../screens/login_secure.dart';
import 'package:provider/provider.dart';
import '../models/model_register.dart';

class ResetPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordFieldModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("비밀번호 초기화 화면"),
        ),
        body: Column(
          children: [
            EmailInput(),
            ResetPasswordButton(),
          ],
        ),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final resetPasswordField =
    Provider.of<ResetPasswordFieldModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        onChanged: (email) {
          resetPasswordField.setEmail(email);
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: '이메일',
          helperText: '',
        ),
      ),
    );
  }
}

class ResetPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authClient =
    Provider.of<FirebaseAuthProvider>(context, listen: false);
    final registerField =
    Provider.of<ResetPasswordFieldModel>(context, listen: false);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: () async {
          await authClient
              .sendPasswordResetEmail(registerField.email)
              .then((resetStatus) {
            if (resetStatus == AuthStatus.resetSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('비밀번호를 초기화하였습니다. 등록한 이메일에서 확인해주세요')),
                );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('비밀번호 초기화를 실패하였습니다. 다시 시도해주세요.')),
                );
            }
          });
        },
        child: Text('비밀번호 초기화'),
      ),
    );
  }
}