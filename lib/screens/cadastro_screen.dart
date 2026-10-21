import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/botao_degrade.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/erro_firebase.dart';
import 'home_screen.dart';  

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _ocultarSenha = true;
  bool _ocultarConfirmar = true;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  // Confere os dados antes de cadastrar
    Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text;
    final confirmar = _confirmarController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmar.isEmpty) {
      _mostrarAviso('Preencha todos os campos');
      return;
    }
    if (!email.contains('@')) {
      _mostrarAviso('Digite um e-mail válido');
      return;
    }
    if (senha.length < 6) {
      _mostrarAviso('A senha precisa ter pelo menos 6 caracteres');
      return;
    }
    if (senha != confirmar) {
      _mostrarAviso('As senhas não são iguais');
      return;
    }

    setState(() => _carregando = true);
    try {
      final credencial =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      // Guarda o nome na conta para usar no "Olá, Fulano!"
      await credencial.user?.updateDisplayName(nome);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (rota) => false,
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
      appBar: AppBar(backgroundColor: AppColors.superficie),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texto,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Preencha os dados abaixo para se cadastrar',
                    style: TextStyle(color: AppColors.textoSuave),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _nomeController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: 'Nome completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'E-mail',
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmarController,
                    obscureText: _ocultarConfirmar,
                    decoration: InputDecoration(
                      hintText: 'Confirmar senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarConfirmar
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(
                              () => _ocultarConfirmar = !_ocultarConfirmar);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  BotaoDegrade(
                    texto: _carregando ? 'Cadastrando...' : 'Cadastrar',
                    onPressed: _carregando ? () {} : _cadastrar,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Já tem uma conta?',
                          style: TextStyle(color: AppColors.textoSuave),
                        ),
                        TextButton(
                          // volta para a tela de login
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Entrar'),
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