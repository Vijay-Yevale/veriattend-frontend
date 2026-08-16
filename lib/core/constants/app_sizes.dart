class AppSizes {
  AppSizes._();

  // ─── Spacing ──────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double mm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ─── Border Radius ────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  // ─── Icon Sizes ───────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ─── Screen Padding ───────────────────────────────────
  static const double screenPaddingH = 24.0; // horizontal
  static const double screenPaddingV = 16.0; // vertical

  // ─── Card ─────────────────────────────────────────────
  static const double cardPadding = 16.0;
  static const double cardElevation = 2.0;

  // ─── Button ───────────────────────────────────────────
  static const double buttonHeight = 52.0;
  static const double buttonBorderRadius = 12.0;

  // ─── Input Field ──────────────────────────────────────
  static const double inputHeight = 56.0;
  static const double inputBorderRadius = 12.0;

  // ─── Bottom Nav ───────────────────────────────────────
  // Was 64 but every real usage (AppScaffold's NavigationBar) was
  // hardcoding 72 anyway — bumped the constant to match reality
  // instead of silently ignoring it.
  static const double bottomNavHeight = 72.0;
}
