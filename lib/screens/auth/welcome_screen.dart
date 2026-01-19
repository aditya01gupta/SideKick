import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                        _gradientController.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF8B5CF6),
                        const Color(0xFFA78BFA),
                        _gradientController.value,
                      )!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // Floating Particle Orbs
          ...List.generate(6, (index) => _buildFloatingOrb(index)),

          // Decorative Blur Circles
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          // Main Content - Wrapped in SafeArea and SingleChildScrollView
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),

                          // Animated Rocket Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.rocket_launch_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .moveY(
                                  begin: 0,
                                  end: -8,
                                  duration: 1500.ms,
                                  curve: Curves.easeInOut)
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideX(begin: -0.3, curve: Curves.easeOutCubic),

                          const SizedBox(height: 30),

                          // Main Title with Staggered Animation
                          const Text(
                            "Launch Your",
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 600.ms)
                              .slideX(
                                begin: -0.2,
                                curve: Curves.easeOutCubic,
                              ),

                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFFCD34D)],
                            ).createShader(bounds),
                            child: const Text(
                              "Side Hustle.",
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                letterSpacing: -1,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 600.ms)
                              .slideX(
                                begin: -0.2,
                                curve: Curves.easeOutCubic,
                              ),

                          const SizedBox(height: 16),

                          // Subtitle
                          Row(
                            children: [
                              _buildAnimatedDot(0),
                              const SizedBox(width: 8),
                              const Text(
                                "Connect",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildAnimatedDot(1),
                              const SizedBox(width: 8),
                              const Text(
                                "Work",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildAnimatedDot(2),
                              const SizedBox(width: 8),
                              const Text(
                                "Earn",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                        ],
                      ),

                      // Bottom Section - Buttons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),

                          // Role Selection Label
                          const Text(
                            "I want to...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

                          const SizedBox(height: 20),

                          // Student Button
                          _buildPremiumButton(
                            context: context,
                            title: "Find Work",
                            subtitle: "I'm a Student",
                            icon: Icons.school_rounded,
                            delay: 900,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) =>
                                    const AuthScreen(userType: 'student'),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Employer Button
                          _buildPremiumButton(
                            context: context,
                            title: "Hire Talent",
                            subtitle: "I'm an Employer",
                            icon: Icons.business_center_rounded,
                            delay: 1050,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) =>
                                    const AuthScreen(userType: 'employer'),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingOrb(int index) {
    final random = math.Random(index);
    final size = 40.0 + random.nextDouble() * 60;
    final startX = random.nextDouble() * 300;
    final startY = 200.0 + random.nextDouble() * 400;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final offset =
            math.sin(_particleController.value * 2 * math.pi + index) * 30;
        return Positioned(
          left: startX + offset,
          top: startY +
              math.cos(_particleController.value * 2 * math.pi + index * 0.5) *
                  20,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDot(int index) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFCD34D),
      ),
    ).animate(delay: (600 + index * 150).ms).scale(
          begin: const Offset(0, 0),
          duration: 400.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildPremiumButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required int delay,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, curve: Curves.easeOutCubic);
  }
}
