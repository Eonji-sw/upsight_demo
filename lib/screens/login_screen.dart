import 'package:flutter/material.dart';
import 'package:board_project/screens/login_secure.dart';
import 'package:provider/provider.dart';
import 'package:board_project/models/model_login.dart';
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginFieldModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("로그인 화면"),
        ),
        body: Column(
          children: [
            EmailInput(),
            PasswordInput(),
            LoginButton(),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 1),
            ),
          AccountButtons(),
          ],
        ),
      ),
    );
  }
}

//하단 회원가입 및 비번 변경 버튼 부분
class AccountButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: RegisterButton(),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ResetPasswordButton(),
          ),
        ),
      ],
    );
  }
}

//이메일 입력칸
class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginField = Provider.of<LoginFieldModel>(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        onChanged: (email) {
          loginField.setEmail(email);
        },
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: '이메일',
        ),
      ),
    );
  }
}

//비번 입력칸
class PasswordInput extends StatelessWidget {
  const PasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    final loginField = Provider.of<LoginFieldModel>(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      child: TextField(
        onChanged: (password) {
          loginField.setPassword(password);
        },
        obscureText: true,
        decoration: const InputDecoration(
          labelText: '비밀번호',
        ),
      ),
    );
  }
}

//로그인 버튼
class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authClient =
    Provider.of<FirebaseAuthProvider>(context, listen: false);
    final loginField = Provider.of<LoginFieldModel>(context, listen: false);
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
              .signIn(loginField.email, loginField.password)
              .then((loginStatus) {
            if (loginStatus == AuthStatus.loginSuccess) {
              logger.d("로그인 성공");
              logger.d(authClient.authClient.currentUser!.email);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(authClient.authClient.currentUser!.email! + '님 환영합니다!')), // 닉네임 가져온느거로 수정해야함
                );
              Navigator.pushReplacementNamed(context, '/tab');
            } else {
              logger.d(loginField.email);
              logger.d(loginField.password);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
                );
            }
          });
        },
        child: Text('로그인'),
      ),
    );
  }
}

//회원가입 버튼
class RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/register');
      },
      child: Text(
        '회원가입',
        style: TextStyle(color: theme.primaryColor),
      ),
    );
  }
}

//비번 초기화 버튼
class ResetPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/reset_password');
      },
      child: Text(
        '비밀번호를 잊으셨나요?',
        style: TextStyle(color: theme.primaryColor),
      ),
    );
  }
}