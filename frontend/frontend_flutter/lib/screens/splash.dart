/*  lib/screens/splash.dart
    – boot-sequence splash for the CYBER-NOTES terminal  */

import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../styles/app_styles.dart';
import 'notes_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: .4,
      upperBound: 1,
    )..repeat(reverse: true);

    // ── fake-boot delay ──
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NotesHome()),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.background,
      body: Stack(
        children: [
          /* ---- faint vertical scan lines ---- */
          Positioned.fill(child: CustomPaint(painter: _ScanlinePainter())),

          /* ---- main neon intro ---- */
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedTextKit(
                  repeatForever: false,
                  totalRepeatCount: 1,
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'CYBER // NOTES',
                      textStyle: GoogleFonts.orbitron(
                        color: AppStyle.accentGreen,
                        fontSize: 32,
                        letterSpacing: 3,
                      ),
                      speed: const Duration(milliseconds: 90),
                      cursor: '_',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ═══════════════════════════════════════════════════════  */
/*  very subtle horizontal scan-lines                      */
class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppStyle.surface.withOpacity(.05)
          ..strokeWidth = 1;
    const step = 4.0;
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
