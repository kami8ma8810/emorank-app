import 'package:emorank_app/presentation/controllers/auth_controller.dart';
import 'package:emorank_app/presentation/widgets/common/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 新規登録画面
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// メールとパスワードで新規登録
  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
      );
      
      if (!mounted) return;
      
      final authState = ref.read(authControllerProvider);
      if (authState.status == AuthStatus.error) {
        setState(() {
          _errorMessage = authState.errorMessage;
          _isLoading = false;
        });
      } else if (authState.status == AuthStatus.authenticated) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'アカウント作成に失敗しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント作成'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'エモランへようこそ！',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'アカウントを作成して始めましょう',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // エラーメッセージ
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // 登録フォーム
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InputField(
                          label: 'ニックネーム',
                          hintText: 'あなたの表示名',
                          controller: _displayNameController,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ニックネームを入力してください';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        InputField(
                          label: 'メールアドレス',
                          hintText: 'example@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'メールアドレスを入力してください';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return '有効なメールアドレスを入力してください';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        PasswordInputField(
                          label: 'パスワード',
                          hintText: '********',
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'パスワードを入力してください';
                            }
                            if (value.length < 6) {
                              return 'パスワードは6文字以上で入力してください';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        PasswordInputField(
                          label: 'パスワード（確認）',
                          hintText: '********',
                          controller: _confirmPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'パスワードを再入力してください';
                            }
                            if (value != _passwordController.text) {
                              return 'パスワードが一致しません';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // アカウント作成ボタン
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signUpWithEmail,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(),
                                  )
                                : const Text('アカウント作成'),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // ログインページへのリンク
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'すでにアカウントをお持ちですか？',
                              style: textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text('ログイン'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
