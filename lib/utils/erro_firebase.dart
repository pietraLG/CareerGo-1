// Transforma o código de erro do Firebase em uma mensagem amigável
String mensagemDeErro(String codigo) {
  switch (codigo) {
    case 'email-already-in-use':
      return 'Este e-mail já está cadastrado';
    case 'invalid-email':
      return 'E-mail inválido';
    case 'weak-password':
      return 'Senha muito fraca. Use pelo menos 6 caracteres';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'E-mail ou senha incorretos';
    case 'too-many-requests':
      return 'Muitas tentativas. Espere um pouco e tente de novo';
    case 'network-request-failed':
      return 'Sem conexão com a internet';
    case 'operation-not-allowed':
      return 'Login por e-mail/senha não está ativado no Firebase';
    default:
      return 'Algo deu errado ($codigo)';
  }
}