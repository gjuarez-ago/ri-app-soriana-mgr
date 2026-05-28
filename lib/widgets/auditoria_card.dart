import 'package:flutter/material.dart';

class AuditoriaCard extends StatelessWidget {
  final String titulo;
  final bool audito;
  final double faltantes;
  final double cumplimiento;
  final bool badgePrioritario;
  final bool faltanteMayor;
  final VoidCallback? onTap; // Nueva propiedad para manejar el click
  final int grupo;

  const AuditoriaCard({
    Key? key,
    required this.titulo,
    required this.audito,
    required this.faltantes,
    required this.cumplimiento,
    required this.badgePrioritario,
    required this.faltanteMayor,
    this.onTap,
    required this.grupo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Manejador del evento tap
      borderRadius: BorderRadius.circular(12), // Mismo radio que la Card
      child: Card(
        color:
            faltanteMayor ? Color.fromARGB(255, 253, 231, 229) : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: audito ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título + Prioridad + Auditado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: badgePrioritario
                              ? Color.fromARGB(255, 184, 156, 1)
                              : Color.fromARGB(255, 108, 108, 108),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        width: 160,
                        child: Text(
                          titulo,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          audito ? 'Auditado' : 'No auditado',
                          style: TextStyle(
                              color: audito ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Indicadores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIndicator(
                      'Faltantes', '${faltantes} %', Colors.orange.shade100),
                  _buildIndicator('Cumplimiento', '${cumplimiento} %',
                      Colors.green.shade100),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
