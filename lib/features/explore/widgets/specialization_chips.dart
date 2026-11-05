import 'package:flutter/material.dart';

class SpecializationChips extends StatefulWidget {
  final ValueChanged<String>? onSelected;
  const SpecializationChips({super.key, this.onSelected});

  @override
  State<SpecializationChips> createState() => _SpecializationChipsState();
}

class _SpecializationChipsState extends State<SpecializationChips> {
  int _selectedIndex = 0;
  static const List<String> _items = ['All', 'Orthopedic', 'Sports', 'Neuro', 'Post-Surgery', 'Geriatric'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Specialization', style: TextStyle(fontSize: 15, color: Color(0xFF121A3A), fontWeight: FontWeight.w900, letterSpacing: -.3)),
        const SizedBox(height: 11),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = index == _selectedIndex;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    widget.onSelected?.call(_items[index]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      gradient: selected ? const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF6D63E8), Color(0xFF5146D9)],
                      ) : null,
                      color: selected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: selected ? Colors.transparent : const Color(0xFFE5E8F0)),
                      boxShadow: selected ? [
                        BoxShadow(color: const Color(0xFF5146D9).withOpacity(.18), blurRadius: 12, offset: const Offset(0, 5)),
                      ] : null,
                    ),
                    child: Center(child: Text(_items[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: selected ? Colors.white : const Color(0xFF68728D)))),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
