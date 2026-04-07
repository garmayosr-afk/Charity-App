import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'screens/welcome/welcome_page.dart';

void main() {
  runApp(const SOSApp());
}

class SOSApp extends StatelessWidget {
  const SOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// ══════════════════════════════════════════════
//  SPLASH SCREEN
// ══════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Heart beat
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  // Stars twinkle
  late AnimationController _starController;

  // Fade + slide for text
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  // Progress bar
  late AnimationController _progressController;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    // ── Heart beat: 1.0 → 1.10 → 1.0, loop ──
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _heartScale = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    // ── Stars: each star reads its own phase offset from this controller ──
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // ── Text fade + slide in after 300ms ──
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideUp = Tween<double>(begin: 28, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });

    // ── Progress bar starts after 500ms ──
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _progress = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _progressController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    _starController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // ── Star positions: [leftRatio, topRatio, starSize, phaseOffset] ──
  static const _starData = [
    [0.10, 0.10, 14.0, 0.00],
    [0.82, 0.14, 10.0, 0.30],
    [0.88, 0.36, 8.0,  0.60],
    [0.07, 0.42, 9.0,  0.20],
    [0.76, 0.52, 7.0,  0.80],
    [0.18, 0.66, 6.0,  0.50],
    [0.91, 0.70, 11.0, 0.10],
    [0.04, 0.78, 8.0,  0.70],
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          // ── Ambient glow ──
          Positioned(
            top: screenSize.height * 0.14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.14),
                      blurRadius: 130,
                      spreadRadius: 70,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Twinkling stars ──
          for (final s in _starData)
            Positioned(
              left: screenSize.width * (s[0] as double),
              top: screenSize.height * (s[1] as double),
              child: AnimatedBuilder(
                animation: _starController,
                builder: (context, _) {
                  final phase =
                      (_starController.value + (s[3] as double)) % 1.0;
                  final opacity =
                  (0.15 + 0.85 * math.sin(phase * math.pi)).clamp(0.0, 1.0);
                  return Opacity(
                    opacity: opacity,
                    child: _SparkleWidget(size: s[2] as double),
                  );
                },
              ),
            ),

          // ── Main centered content ──
          Column(
            children: [
              const Spacer(flex: 2),

              // Beating heart
              ScaleTransition(
                scale: _heartScale,
                child: CustomPaint(
                  size: const Size(230, 210),
                  painter: _HeartChildPainter(),
                ),
              ),

              const SizedBox(height: 44),

              // Text block (fade + slide)
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) => Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    // SOS
                    const Text(
                      'SOS',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6B35),
                        letterSpacing: 10,
                      ),
                    ),

                    // Orange underline
                    Container(
                      width: 100,
                      height: 3,
                      margin: const EdgeInsets.only(top: 2, bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.50),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Subtitle
                    const Text(
                      'Ensemble pour les enfants',
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1.2,
                        color: Color(0xFFFFD8B8),
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Three dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                            (i) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF6B35)
                                .withOpacity(i == 1 ? 0.9 : 0.45),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom tagline
                    const Text(
                      'Chaque don change une vie',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: 0.6,
                        color: Color(0xFF8899AA),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 130),
                child: Column(
                  children: [
                  AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          // Track
                          Container(
                            height: 4,
                            color: const Color(0xFF1E2D3D),
                          ),
                          // Fill
                          FractionallySizedBox(
                            widthFactor: _progress.value,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35)
                                    .withOpacity(0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20) ,
                  const Text(
                    'Chargement...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF445566),
                      letterSpacing: 0.5,
                    ),
                  ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  4-POINT SPARKLE WIDGET
// ══════════════════════════════════════════════
class _SparkleWidget extends StatelessWidget {
  final double size;
  const _SparkleWidget({required this.size});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _SparklePainter());
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD166)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.35;
    final path = Path();

    for (int i = 0; i < 4; i++) {
      final outerAngle = (i * math.pi / 2) - math.pi / 2;
      final innerAngle1 = outerAngle - math.pi / 4;
      final innerAngle2 = outerAngle + math.pi / 4;

      final ox = cx + outer * math.cos(outerAngle);
      final oy = cy + outer * math.sin(outerAngle);
      final ix1 = cx + inner * math.cos(innerAngle1);
      final iy1 = cy + inner * math.sin(innerAngle1);
      final ix2 = cx + inner * math.cos(innerAngle2);
      final iy2 = cy + inner * math.sin(innerAngle2);

      if (i == 0) {
        path.moveTo(ix1, iy1);
      } else {
        path.lineTo(ix1, iy1);
      }
      path.lineTo(ox, oy);
      path.lineTo(ix2, iy2);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter _) => false;
}

// ══════════════════════════════════════════════
//  HEART + CHILD SILHOUETTE PAINTER
// ══════════════════════════════════════════════
class _HeartChildPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;

    // Outer heart
    _drawHeart(canvas, cx, cy, size.width * 0.92,
        const Color(0xFFFF6B35).withOpacity(0.93));

    // Inner glowing heart
    _drawHeart(canvas, cx, cy, size.width * 0.58,
        const Color(0xFFFF8C42).withOpacity(0.52));

    // ── Child silhouette ──
    final white = Paint()
      ..color = Colors.white.withOpacity(0.90)
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(cx, cy - 24), 15, white);

    // Body + legs
    final body = Path()
      ..moveTo(cx - 13, cy - 7)
      ..lineTo(cx + 13, cy - 7)
      ..lineTo(cx + 11, cy + 32)
      ..lineTo(cx + 5,  cy + 32)
      ..lineTo(cx + 5,  cy + 18)
      ..lineTo(cx - 5,  cy + 18)
      ..lineTo(cx - 5,  cy + 32)
      ..lineTo(cx - 11, cy + 32)
      ..close();
    canvas.drawPath(body, white);

    // Left arm
    final lArm = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    final leftArm = Path()
      ..moveTo(cx - 13, cy - 6)
      ..lineTo(cx - 30, cy + 0)
      ..lineTo(cx - 28, cy + 14)
      ..lineTo(cx - 13, cy + 10)
      ..close();
    canvas.drawPath(leftArm, lArm);

    // Right arm
    final rightArm = Path()
      ..moveTo(cx + 13, cy - 6)
      ..lineTo(cx + 30, cy + 0)
      ..lineTo(cx + 28, cy + 14)
      ..lineTo(cx + 13, cy + 10)
      ..close();
    canvas.drawPath(rightArm, lArm);
  }

  void _drawHeart(
      Canvas canvas, double cx, double cy, double width, Color color) {
    final h = width * 0.88;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(cx, cy + h * 0.40);
    // Left lobe
    path.cubicTo(
      cx - width * 0.05, cy + h * 0.18,
      cx - width * 0.52, cy + h * 0.08,
      cx - width * 0.50, cy - h * 0.18,
    );
    path.cubicTo(
      cx - width * 0.48, cy - h * 0.50,
      cx - width * 0.04, cy - h * 0.50,
      cx, cy - h * 0.14,
    );
    // Right lobe
    path.cubicTo(
      cx + width * 0.04, cy - h * 0.50,
      cx + width * 0.48, cy - h * 0.50,
      cx + width * 0.50, cy - h * 0.18,
    );
    path.cubicTo(
      cx + width * 0.52, cy + h * 0.08,
      cx + width * 0.05, cy + h * 0.18,
      cx, cy + h * 0.40,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartChildPainter _) => false;
}