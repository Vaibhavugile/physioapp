import 'package:flutter/material.dart';

class SpecializationChips extends StatefulWidget {
  final ValueChanged<String>? onSelected;

  const SpecializationChips({
    super.key,
    this.onSelected,
  });

  @override
  State<SpecializationChips> createState() =>
      _SpecializationChipsState();
}

class _SpecializationChipsState
    extends State<SpecializationChips> {
  int _selectedIndex = 0;

  final List<String> _items = const [
    'All',
    'Orthopedic',
    'Sports',
    'Neuro',
    'Post-Surgery',
    'Geriatric',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Specialization',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF121A3A),
            fontWeight: FontWeight.w800,
            letterSpacing: -.25,
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics:
                const BouncingScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected =
                  index == _selectedIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });

                  widget.onSelected?.call(
                    _items[index],
                  );
                },
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF5E68E8),
                              Color(0xFF5146D9),
                            ],
                          )
                        : null,
                    color: selected
                        ? null
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(13),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : const Color(0xFFE4E7EF),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  const Color(0xFF5146D9)
                                      .withOpacity(.16),
                              blurRadius: 10,
                              offset:
                                  const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _items[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(
                                0xFF69728D,
                              ),
                      ),
                    ),
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