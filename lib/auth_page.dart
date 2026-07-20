import 'package:flutter/material.dart';
import 'package:liaoleme/user_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final systemUserId = await UserService.getSystemUserId();

      if (_isLogin) {
        await UserService.login(
          userId: _emailController.text,
          nickname: _emailController.text.split('@')[0],
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        await UserService.login(
          userId: _emailController.text,
          nickname: _nicknameController.text.isNotEmpty
              ? _nicknameController.text
              : _emailController.text.split('@')[0],
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? '登录' : '注册',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '邮箱'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码'),
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '昵称'),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(_isLogin ? '登录' : '注册'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin
                  ? '没有账号？去注册'
                  : '已有账号？去登录'),
            ),
            const SizedBox(height: 32),
            const Text('当前为模拟登录，实际将调用后端接口'),
          ],
        ),
      ),
    );
  }
}
