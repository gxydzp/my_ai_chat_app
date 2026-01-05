// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // -------- 统一配色（黑底 + 紫粉光感） --------

  /// 主色：浅紫，用于强调元素（标题、小图形、选中状态等）
  static const Color primaryColor = Color(0xFFBE94FF); // be94ff

  /// 次级强调：偏粉的按钮色
  static const Color accentColor = Color(0xFFFFABF7); // ffabf7

  /// 浅粉：输入框 / 气泡背景（在深色底上）
  static const Color softPink = Color(0x33FFABF7); // 半透明粉，做柔和底

  /// 全局背景：深色，接近黑色的夜空
  static const Color backgroundColor = Color(0xFF05040B);

  /// 文字颜色：深色主题下用浅色字
  static const Color textMain = Color(0xFFF5F5F7);
  static const Color textSub = Color(0xFFB3B3C0);

  /// 兼容老代码的别名
  static const Color primaryBlue = primaryColor;
  static const Color lightPink = accentColor;
  static const Color palePink = softPink;

  /// 整体主背景渐变：黑底上有一点紫粉光晕
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF05040B), // 顶部接近纯黑
      Color(0xFF0B0715), // 深紫黑
      Color(0xFF15102A), // 底部偏紫
      Color(0x33000000), // 最后一点淡淡的透明黑，拉开层次
    ],
    stops: [0.0, 0.4, 0.8, 1.0],
  );

  /// 底部导航 / 浮层用的轻微渐变（从深到浅一点）
  static const LinearGradient bottomBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF090814),
      Color(0xFF120F23),
    ],
  );

  // -------- 整体 ThemeData（深色 + 光感） --------

  static ThemeData get mainTheme {
    final base = ThemeData.dark();

    return base.copyWith(
      // 让真正的底色交给外层 Container 的渐变去画
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,

      // 深色色板
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primaryColor,
        secondary: accentColor,
        surface: const Color(0xFF12101F),
      ),

      // 顶部 AppBar：透明 + 浅色文字
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
      ),

      // 主要按钮：胶囊形、粉色，稍微一点光感阴影
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 6,
          shadowColor: accentColor.withOpacity(0.4),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 次按钮：描边按钮
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: primaryColor.withOpacity(0.7),
            width: 1.2,
          ),
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 输入框：柔和浅粉底 + 圆角，聚焦时用主色描边
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: softPink,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(color: primaryColor, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // 卡片：深色卡片 + 彩色光感阴影
      cardTheme: CardThemeData(
        color: const Color(0xFF141323),
        elevation: 10,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        shadowColor: primaryColor.withOpacity(0.35),
      ),

      // 底部导航：图标浅色，背景透明，由外层渐变负责
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: accentColor,
        unselectedItemColor: textSub,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      // TabBar：选中项用发光竖胶囊覆盖文字
      tabBarTheme: const TabBarThemeData(
        indicator: _GlowingTabIndicator(),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: textMain,
        unselectedLabelColor: textSub,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        // 关键：去掉底部那条横线
        dividerColor: Colors.transparent,
      ),

      // 全局文字
      textTheme: base.textTheme
          .apply(
            bodyColor: textMain,
            displayColor: textMain,
          )
          .copyWith(
            titleLarge: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textMain,
            ),
            bodyMedium: const TextStyle(
              fontSize: 14,
              color: textSub,
            ),
          ),

      dividerColor: Colors.white.withOpacity(0.06),
    );
  }

  /// 一个辅助方法，方便你在页面上套主背景渐变
  static Widget withMainBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: mainBackgroundGradient,
      ),
      child: child,
    );
  }
}

/// TabBar 选中项的发光竖胶囊指示器
class _GlowingTabIndicator extends Decoration {
  const _GlowingTabIndicator();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GlowingTabIndicatorPainter();
  }
}

class _GlowingTabIndicatorPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (configuration.size == null) return;

    final Rect rect = offset & configuration.size!;
    final Size size = rect.size;

    // 以文字区域中心为基准，画一根竖向胶囊
    final Offset center = rect.center;

    final double pillWidth = size.width * 0.45; // 胶囊相对文字宽度
    final double pillHeight = size.height * 0.9; // 略高于文字，形成「覆盖」
    final RRect pill = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: pillWidth,
        height: pillHeight,
      ),
      const Radius.circular(999),
    );

    // 外部光晕
    final Paint glowPaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    // 内部渐变填充
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFFFFF).withOpacity(0.95),
        const Color(0xFFFFE3FF).withOpacity(0.95),
      ],
    );

    final Paint fillPaint = Paint()
      ..shader = gradient.createShader(pill.outerRect);

    // 画光晕 + 胶囊本体
    canvas.save();
    canvas.drawRRect(pill.inflate(10), glowPaint);
    canvas.drawRRect(pill, fillPaint);
    canvas.restore();
  }
}
