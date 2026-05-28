import 'package:flutter/material.dart';

class ButtonsCards extends StatelessWidget {
  final int totalTramo;
  final int totalNivel;
  final int totalFrentes;
  final int totalSecuencia;
  final int totalSinHueco;
  final int selectedIndex;
  final bool showSecuencia;
  final bool showSinHuecos;
  final ValueChanged<int> onSelected;

  const ButtonsCards({
    super.key,
    required this.totalTramo,
    required this.totalNivel,
    required this.totalFrentes,
    required this.totalSecuencia,
    required this.totalSinHueco,
    required this.selectedIndex,
    required this.showSecuencia,
    required this.showSinHuecos,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos las 6 categorías con sus datos
    final allCategories = [
      {
        'id': 0,
        'label': 'Tramo',
        'count': totalTramo,
        'icon': Icons.now_widgets_outlined
      },
      {
        'id': 1,
        'label': 'Nivel',
        'count': totalNivel,
        'icon': Icons.blinds_closed
      },
      {
        'id': 2,
        'label': 'Frentes',
        'count': totalFrentes,
        'icon': Icons.category
      },
      if (showSecuencia)
        {
          'id': 3,
          'label': 'Secuencia',
          'count': totalSecuencia,
          'icon': Icons.format_list_numbered_rounded
        },
      if (showSinHuecos)
        {
          'id': 4,
          'label': 'Sin Hueco',
          'count': totalSinHueco,
          'icon': Icons.grid_on_rounded
        },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: allCategories.map((cat) {
            final int id = cat['id'] as int;
            final bool isSelected = selectedIndex == id;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _ElegantChip(
                label: cat['label'] as String,
                count: cat['count'] as int,
                icon: cat['icon'] as IconData,
                isSelected: isSelected,
                onTap: () => onSelected(id),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ElegantChip extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ElegantChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xff4f46e5); // _kIndigo
    final inactiveColor = Colors.grey.shade200;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            if (count >= 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
