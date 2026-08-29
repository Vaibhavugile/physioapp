import 'package:flutter/material.dart';

class HomeSearch extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;

  const HomeSearch({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE9ECF4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF26345F)
                        .withOpacity(.045),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onTap: onTap,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF17203E),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 27,
                    color: Color(0xFF65719A),
                  ),
                  hintText:
                      'Search physiotherapists, services, conditions...',
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8992AF),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        _FilterButton(
          onTap: onFilterTap,
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _FilterButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE9ECF4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF26345F)
                    .withOpacity(.045),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.tune_rounded,
            size: 25,
            color: Color(0xFF1D2746),
          ),
        ),
      ),
    );
  }
}