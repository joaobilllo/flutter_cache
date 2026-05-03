import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final DateTime? cachedAt;

  const OfflineBanner({super.key, this.cachedAt});

  String _ageLabel() {
    if (cachedAt == null) {
      return 'Sem conexao - exibindo dados salvos.';
    }
    final diff = DateTime.now().difference(cachedAt!);
    if (diff.inMinutes < 1) {
      return 'Modo offline - dados de menos de 1 min atras.';
    }
    if (diff.inMinutes < 60) {
      return 'Modo offline - dados de ${diff.inMinutes} min atras.';
    }
    if (diff.inHours < 24) {
      return 'Modo offline - dados de ${diff.inHours} h atras.';
    }
    return 'Modo offline - dados de ${diff.inDays} dia(s) atras.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: Colors.amber.shade900),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _ageLabel(),
              style: TextStyle(color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }
}
