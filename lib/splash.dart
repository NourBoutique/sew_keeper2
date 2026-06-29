import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _threadCtrl;
  late AnimationController _dotsCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _threadProgress;
  late Animation<double> _dotsOpacity;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _threadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoScale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5)),
    );

    _textSlide = Tween<double>(
      begin: 20,
      end: 0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _textOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _threadProgress = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _threadCtrl, curve: Curves.easeInOut));

    _dotsOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _dotsCtrl, curve: Curves.easeIn));

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _threadCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _textCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _dotsCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _threadCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff6c63ff),
      body: Stack(
        children: [
          // Background circles
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xff7b73ff),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xff5a52e0),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _threadProgress,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(80, 80),
                              painter: _NeedleThreadPainter(
                                progress: _threadProgress.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App name
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Opacity(
                        opacity: _textOpacity.value,
                        child: const Text(
                          'Sew Keeper',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Tagline
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: const Text(
                    'TAILOR ORDER MANAGER',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Loading dots
                FadeTransition(
                  opacity: _dotsOpacity,
                  child: const _LoadingDots(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Needle + Thread Painter ──────────────────────────────────────────────────

class _NeedleThreadPainter extends CustomPainter {
  final double progress;
  _NeedleThreadPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Needle body
    final needleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.45,
        size.height * 0.08,
        size.width * 0.1,
        size.height * 0.58,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(needleRect, paint);

    // Needle top dome
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.08),
      size.width * 0.05,
      paint,
    );

    // Needle eye
    final eyePaint = Paint()
      ..color = const Color(0xff6c63ff)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.22),
        width: size.width * 0.06,
        height: size.height * 0.08,
      ),
      eyePaint,
    );

    // Thread — drawn progressively
    if (progress > 0) {
      final threadPath = Path()
        ..moveTo(size.width * 0.5, size.height * 0.68)
        ..quadraticBezierTo(
          size.width * 0.28,
          size.height * 0.78,
          size.width * 0.24,
          size.height * 0.65,
        )
        ..quadraticBezierTo(
          size.width * 0.20,
          size.height * 0.52,
          size.width * 0.30,
          size.height * 0.44,
        )
        ..quadraticBezierTo(
          size.width * 0.42,
          size.height * 0.36,
          size.width * 0.56,
          size.height * 0.44,
        )
        ..quadraticBezierTo(
          size.width * 0.70,
          size.height * 0.52,
          size.width * 0.62,
          size.height * 0.66,
        )
        ..quadraticBezierTo(
          size.width * 0.54,
          size.height * 0.80,
          size.width * 0.40,
          size.height * 0.78,
        )
        ..quadraticBezierTo(
          size.width * 0.28,
          size.height * 0.76,
          size.width * 0.26,
          size.height * 0.88,
        );

      // Extract partial path based on progress
      final metrics = threadPath.computeMetrics().first;
      final partialPath = metrics.extractPath(0, metrics.length * progress);

      canvas.drawPath(partialPath, strokePaint);

      // Knot dot at end when complete
      if (progress >= 0.98) {
        canvas.drawCircle(
          Offset(size.width * 0.26, size.height * 0.88),
          size.width * 0.04,
          paint..color = Colors.white.withOpacity(0.8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_NeedleThreadPainter old) => old.progress != progress;
}

// ── Loading Dots ─────────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true),
    );

    _animations = List.generate(
      3,
      (i) => Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut),
      ),
    );

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_animations[i].value),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
