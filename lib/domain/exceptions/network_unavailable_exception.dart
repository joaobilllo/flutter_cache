class NetworkUnavailableException implements Exception {
  final String message;

  const NetworkUnavailableException([
    this.message = 'Sem conexao e sem dados salvos.',
  ]);

  @override
  String toString() => message;
}
