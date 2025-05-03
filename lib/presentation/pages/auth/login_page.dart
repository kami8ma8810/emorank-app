import 'package:emorank_app/presentation/controllers/auth_controller.dart';
import 'package:emorank_app/presentation/widgets/common/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ログイン画面
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// メールとパスワードでログイン
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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
        _errorMessage = 'ログインに失敗しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Googleでログイン
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.signInWithGoogle();
      
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
        _errorMessage = 'Googleログインに失敗しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// 匿名ログイン
  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);
      await authController.signInAnonymously();
      
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
        _errorMessage = 'ゲストログインに失敗しました: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ロゴ・タイトル部分
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              'E',
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'エモラン',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '感情ランキングゲーム',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
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
                  
                  // ログインフォーム
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                        
                        const SizedBox(height: 24),
                        
                        // ログインボタン
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signInWithEmail,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(),
                                  )
                                : const Text('ログイン'),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // アカウント作成ページへのリンク
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'アカウントをお持ちでないですか？',
                              style: textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                context.push('/signup');
                              },
                              child: const Text('新規登録'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 区切り線
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[400],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'または',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[400],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Googleでログイン
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: Image.network(
                            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                            width: 18,
                            height: 18,
                          ),
                          label: const Text('Googleでログイン'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // ゲストログイン
                        TextButton(
                          onPressed: _isLoading ? null : _signInAnonymously,
                          child: const Text('ゲストとして続ける'),
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
