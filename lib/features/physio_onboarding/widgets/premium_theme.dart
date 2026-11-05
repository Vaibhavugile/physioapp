import 'package:flutter/material.dart';

/// PhysioAtHome premium design tokens + shared widgets (2026 light theme).
class PX {
  static const bg = Color(0xFFF3F6F4);
  static const ink = Color(0xFF0E2B28);
  static const muted = Color(0xFF55706B);
  static const teal = Color(0xFF0B7A70);
  static const deep = Color(0xFF0C3B37);
  static const mint = Color(0xFF3FE0C5);
  static const soft = Color(0xFFE6F4F0);
  static const line = Color(0xFFE3EBE8);
  static const field = Color(0xFFF3F8F6);
  static const danger = Color(0xFFC0392B);

  static const cardShadow = [
    BoxShadow(color: Color(0x0F0E2B28), blurRadius: 30, offset: Offset(0, 10)),
  ];

  static TextStyle display(double size, {Color color = ink}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -size * 0.03,
        color: color,
      );

  static BoxDecoration card({bool selected = false}) => BoxDecoration(
        color: selected ? soft : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: selected ? teal : line, width: selected ? 2 : 1),
        boxShadow: selected ? const [] : cardShadow,
      );

  static ThemeData theme(ThemeData base) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: c, width: w),
        );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: teal,
        secondary: mint,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: bg,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? teal : const Color(0xFFCBD8D4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: const TextStyle(color: muted, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: Color(0xFF5F7B76)),
        border: b(line),
        enabledBorder: b(line),
        focusedBorder: b(teal, 1.8),
        errorBorder: b(danger),
        focusedErrorBorder: b(danger, 1.8),
      ),
    );
  }
}

/// Chapters group the 9 onboarding steps so the flow feels short.
class PXChapter {
  final String name;
  final int start, count;
  const PXChapter(this.name, this.start, this.count);
}

class PXChapters {
  static const all = [
    PXChapter('You', 0, 2), // Basic info, Title
    PXChapter('Credentials', 2, 3), // Education, Specializations, Experience
    PXChapter('Practice', 5, 2), // Location, Availability
    PXChapter('Finish', 7, 2), // Verification, Review
  ];

  static int indexOf(int step) =>
      all.lastIndexWhere((c) => step >= c.start).clamp(0, all.length - 1);
  static PXChapter of(int step) => all[indexOf(step)];
}

/// Four-segment chapter progress bar with animated fill.
class PXSegmentedProgress extends StatelessWidget {
  final int current; // zero-based step
  const PXSegmentedProgress({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < PXChapters.all.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: _segment(PXChapters.all[i])),
        ],
      ],
    );
  }

  Widget _segment(PXChapter c) {
    final done = (current - c.start + 1).clamp(0, c.count) / c.count;
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 5,
        color: const Color(0xFFD8E3DF),
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: done),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => FractionallySizedBox(
            widthFactor: v,
            child: Container(color: teal),
          ),
        ),
      ),
    );
  }

  static const teal = PX.teal;
}

/// Dark pill call-to-action with a mint arrow.
class PXPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const PXPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null && !loading ? .5 : 1,
      child: Material(
        color: PX.deep,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: loading ? null : onPressed,
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(color: PX.mint, shape: BoxShape.circle),
                    child: loading
                        ? const Padding(
                            padding: EdgeInsets.all(11),
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: PX.deep),
                          )
                        : const Icon(Icons.arrow_forward_rounded, color: PX.deep, size: 22),
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

/// Selectable card used for single-choice grids.
class PXChoiceCard extends StatelessWidget {
  final String label;
  final String? caption;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  const PXChoiceCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.caption,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: PX.card(selected: selected),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null)
                      Icon(icon, size: 22, color: selected ? PX.teal : PX.muted),
                    const Spacer(),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? PX.teal : Colors.transparent,
                        border: Border.all(
                          color: selected ? PX.teal : const Color(0xFFC3D2CE),
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(label, style: PX.display(15).copyWith(height: 1.2)),
                if (caption != null) ...[
                  const SizedBox(height: 3),
                  Text(caption!, style: const TextStyle(fontSize: 12, color: PX.muted)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
