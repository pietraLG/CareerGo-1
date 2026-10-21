import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/botao_degrade.dart';
import '../widgets/logo_careergo.dart';
import '../widgets/onda_fundo.dart';
import 'cadastro_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/erro_firebase.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _ocultarSenha = true;
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

    Future<void> _entrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      _mostrarAviso('Digite e-mail e senha');
      return;
    }

    setState(() => _carregando = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _mostrarAviso(mensagemDeErro(e.code));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.superficie,
      body: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: OndaFundo(altura: 180),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  // no computador, a coluna não passa de 420 de largura
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LogoCareerGo(),
                      const SizedBox(height: 48),
                      const Text(
                        'Bem-vindo de volta!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.texto,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Faça login para continuar',
                        style: TextStyle(color: AppColors.textoSuave),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'E-mail ou usuário',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _senhaController,
                        obscureText: _ocultarSenha,
                        decoration: InputDecoration(
                          hintText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarSenha
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() => _ocultarSenha = !_ocultarSenha);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                     BotaoDegrade(
                        texto: _carregando ? 'Entrando...' : 'Entrar',
                        onPressed: _carregando ? () {} : _entrar,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () =>
                              _mostrarAviso('Recuperar senha: em breve'),
                          child: const Text('Esqueceu sua senha?'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ou',
                              style: TextStyle(color: AppColors.textoSuave),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                                                onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CadastroScreen()),
                        ),
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Criar conta'),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEDEBFF),
                          foregroundColor: AppColors.texto,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}