// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // 主题里用到的几种颜色
  static const Color primaryColor = Color(0xFF6B4FFF); // 主色：按钮 / 标题
  static const Color accentColor  = Color(0xFFFF6F8F); // 点缀色：高亮
  static const Color softPink    = Color(0xFFFFF1F5); // 气泡背景的浅粉
  static const Color backgroundColor = Colors.white;

  /// 方便老代码使用的别名（你之前写过 primaryBlue / lightPink 等）
  static const Color primaryBlue = primaryColor;
  static const Color lightPink   = accentColor;
  static const Color palePink    = softPink;

  /// 整体 ThemeData
  static ThemeData get mainTheme {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: softPink,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: primaryColor, width: 1.4),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      textTheme: base.textTheme.copyWith(
        bodyMedium: const TextStyle(
          color: Colors.black87,
        ),
      ),
    );
  }
}
