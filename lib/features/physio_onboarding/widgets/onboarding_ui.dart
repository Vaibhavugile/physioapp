import 'package:flutter/material.dart';

/// PhysioCare onboarding design system (2026 refresh).
///
/// One calm canvas, one deep-pine action colour, one mint highlight that is
/// only ever used to show progress and selection. Everything else is ink and
/// hairlines. Steps should compose these tokens instead of hard-coding colours.
class OB {
  OB._();

  // ---- Colour ---------------------------------------------------------
  static const Color canvas = Color(0xFFF4F6F5);
  static const Color surface = Colors.white;
  static const Color ink = Color(0xFF0E1F1D);
  static const Color pine = Color(0xFF0F4C47); // primary action
  static const Color pineDeep = Color(0xFF0A3A36);
  static const Color mint = Color(0xFF2FD5B3); // progress + selection accent
  static const Color tint = Color(0xFFE7F5F1); // selected fill
  static const Color tintSoft = Color(0xFFF0F7F5);
  static const Color line = Color(0xFFE3E9E7); // hairlines
  static const Color lineStrong = Color(0xFFCFD9D6);
  static const Color muted = Color(0xFF63746F);
  static const Color faint = Color(0xFF9AA9A5);
  static const Color danger = Color(0xFFD64545);
  static const Color amber = Color(0xFFB7791F);
  static const Color amberTint = Color(0xFFFFF6E5);

  // ---- Shape ----------------------------------------------------------
  static const double rField = 14;
  static const double rCard = 20;
  static const double rSheet = 28;

  // ---- Type -----------------------------------------------------------
  // Swap [fontFamily] for a licensed brand face (e.g. via google_fonts) and
  // the whole flow updates. System font is used by default so nothing breaks.
  static const String? fontFamily = null;

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.1,
    color: ink,
  );
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -.3,
    color: ink,
  );
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: muted,
  );
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: ink,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  // ---- Shadow ---------------------------------------------------------
  static const List<BoxShadow> lift = [
    BoxShadow(color: Color(0x0A0E1F1D), blurRadius: 24, offset: Offset(0, 10)),
  ];

  // ---- Theme applied to the whole onboarding flow --------------------
  static ThemeData theme(BuildContext context) {
    final base = Theme.of(context);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(rField),
          borderSide: BorderSide(color: c, width: w),
        );

    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: base.colorScheme.copyWith(
        primary: pine,
        onPrimary: Colors.white,
        secondary: mint,
        surface: surface,
        onSurface: ink,
        error: danger,
      ),
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 1),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: pine,
        selectionHandleColor: pine,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: muted, fontWeight: FontWeight.w600),
        floatingLabelStyle:
            const TextStyle(color: pine, fontWeight: FontWeight.w700),
        hintStyle: const TextStyle(
            color: faint, fontSize: 14, fontWeight: FontWeight.w500),
        helperStyle: caption,
        errorStyle: const TextStyle(
            color: danger, fontSize: 11.5, fontWeight: FontWeight.w600),
        prefixIconColor: faint,
        suffixIconColor: faint,
        border: border(line),
        enabledBorder: border(line),
        disabledBorder: border(line),
        focusedBorder: border(ink, 1.5),
        errorBorder: border(danger),
        focusedErrorBorder: border(danger, 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? pine : lineStrong,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: lineStrong, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? pine : Colors.transparent,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surface,
        selectedColor: tint,
        side: const BorderSide(color: line),
        shape: const StadiumBorder(),
        labelStyle: label,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: surface,
        dialHandColor: pine,
        hourMinuteShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(rSheet)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: pine,
        linearTrackColor: line,
      ),
    );
  }
}

/// A flat, hairline-bordered surface. Use sparingly: group related fields,
/// never nest one inside another.
class ObSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final bool lifted;

  const ObSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.borderColor,
    this.radius = OB.rCard,
    this.lifted = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? OB.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor ?? OB.line),
          boxShadow: lifted ? OB.lift : const [],
        ),
        child: child,
      );
}

/// Field label with optional helper. Sentence case, no shouting.
class ObLabel extends StatelessWidget {
  final String text;
  final bool required;
  final String? helper;

  const ObLabel(this.text, {super.key, this.required = false, this.helper});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(text, style: OB.label),
            if (required)
              const Text(' *',
                  style: TextStyle(
                      color: OB.danger,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            if (helper != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(helper!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: OB.faint,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ],
        ),
      );
}

/// Small group title used between clusters of fields inside one step.
class ObGroupTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const ObGroupTitle(this.title, {super.key, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: OB.title),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: OB.caption),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

/// Selectable tile (single or multi select). Selection = ink outline + mint
/// check. Replaces the old gradient icon cards.
class ObChoiceTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const ObChoiceTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: title,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(OB.rCard - 2),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                  horizontal: 14, vertical: compact ? 12 : 15),
              decoration: BoxDecoration(
                color: selected ? OB.tint : OB.surface,
                borderRadius: BorderRadius.circular(OB.rCard - 2),
                border: Border.all(
                  color: selected ? OB.ink : OB.line,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: selected ? OB.pine : OB.faint),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: OB.label.copyWith(
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!, style: OB.caption),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ObCheckDot(selected: selected),
                ],
              ),
            ),
          ),
        ),
      );
}

class ObCheckDot extends StatelessWidget {
  final bool selected;
  final double size;
  const ObCheckDot({super.key, required this.selected, this.size = 22});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? OB.ink : Colors.transparent,
          border: Border.all(
              color: selected ? OB.ink : OB.lineStrong, width: 1.5),
        ),
        child: selected
            ? Icon(Icons.check_rounded, size: size * .64, color: OB.mint)
            : null,
      );
}

/// Pill used for days, languages, quick filters.
class ObPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double minWidth;

  const ObPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.minWidth = 0,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: BoxConstraints(minWidth: minWidth, minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? OB.ink : OB.surface,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: selected ? OB.ink : OB.line),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : OB.muted,
              ),
            ),
          ),
        ),
      );
}

/// Switch row with title + caption.
class ObSwitchRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ObSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: OB.label),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: OB.caption),
                ],
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      );
}

/// Quiet inline note (info / privacy). Replaces tinted hero banners.
class ObNote extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool warning;

  const ObNote(this.text,
      {super.key, this.icon = Icons.lock_outline_rounded, this.warning = false});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: warning ? OB.amber : OB.faint),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: OB.caption)),
        ],
      );
}
