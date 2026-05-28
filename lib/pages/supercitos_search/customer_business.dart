import 'package:flutter/material.dart';

class CustomBusinessCard extends StatelessWidget {
  
  final String fechaMon;
  
  final int monitoreo;
  final int faltantes;
  final int cumplimiento;

  final int porCajas;
  final int porsinCajas;
  final VoidCallback onTap;

  const CustomBusinessCard({
    Key? key,
    required this.fechaMon,
    required this.monitoreo,
    required this.faltantes,
    required this.onTap, required this.porCajas, required this.porsinCajas, required this.cumplimiento,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)],
          ),
          padding: const EdgeInsets.all(16),
     child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Center(
        child: Text(
          '$fechaMon',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  
    
    const SizedBox(height: 8),

     Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoContainer(
          label: 'Monitoreados',
        value: '$monitoreo',
          color: Colors.green.shade100,
        ),
        const SizedBox(width: 8),
        _buildInfoContainer(
          label: 'Faltantes',
        value: '$faltantes',
          color: Colors.orange.shade100,
        ),
        const SizedBox(width: 8),
        _buildInfoContainer(
          label: 'Cumplimiento',
        value: '$cumplimiento',
          color: Colors.purple.shade100,
        ),
      ],
    ),
  
    const SizedBox(height: 8),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildInfoContainer(
          label: '% con caja',
          value: '$porCajas',
          color: Colors.blue.shade100,
        ),
        const SizedBox(width: 10),
        _buildInfoContainer(
          label: '% sin caja',
          value: '$porsinCajas',
          color: Colors.red.shade100,
        ),
      ],
    ),
   ],
),

     ),
      ),
    );
  }

  Widget _buildInfoContainer({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
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

  Widget _buildLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
