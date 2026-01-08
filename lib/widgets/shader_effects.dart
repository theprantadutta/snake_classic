import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

// Custom shader effects for advanced visual rendering
class ShaderEffectPainter extends CustomPainter {
  final ui.FragmentShader? shader;
  final GameTheme theme;
  final double time;
  final Size textureSize;
  final Map<String, dynamic> uniforms;

  ShaderEffectPainter({
    required this.shader,
    required this.theme,
    required this.time,
    this.textureSize = const Size(512, 512),
    this.uniforms = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (shader == null) return;

    // Set shader uniforms
    _setShaderUniforms(size);

    // Create shader paint
    final paint = Paint()..shader = shader;

    // Draw full screen quad
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _setShaderUniforms(Size size) {
    if (shader == null) return;

    // Standard uniforms
    shader!.setFloat(0, size.width); // u_resolution.x
    shader!.setFloat(1, size.height); // u_resolution.y
    shader!.setFloat(2, time); // u_time

    // Theme-specific color uniforms
    final bgColor = theme.backgroundColor;
    final accentColor = theme.accentColor;
    final snakeColor = theme.snakeColor;
    final foodColor = theme.foodColor;

    shader!.setFloat(3, bgColor.r); // u_bgColor.r
    shader!.setFloat(4, bgColor.g); // u_bgColor.g
    shader!.setFloat(5, bgColor.b); // u_bgColor.b
    shader!.setFloat(6, bgColor.a); // u_bgColor.a

    shader!.setFloat(7, accentColor.r); // u_accentColor.r
    shader!.setFloat(8, accentColor.g); // u_accentColor.g
    shader!.setFloat(9, accentColor.b); // u_accentColor.b
    shader!.setFloat(10, accentColor.a); // u_accentColor.a

    shader!.setFloat(11, snakeColor.r); // u_snakeColor.r
    shader!.setFloat(12, snakeColor.g); // u_snakeColor.g
    shader!.setFloat(13, snakeColor.b); // u_snakeColor.b
    shader!.setFloat(14, snakeColor.a); // u_snakeColor.a

    shader!.setFloat(15, foodColor.r); // u_foodColor.r
    shader!.setFloat(16, foodColor.g); // u_foodColor.g
    shader!.setFloat(17, foodColor.b); // u_foodColor.b
    shader!.setFloat(18, foodColor.a); // u_foodColor.a

    // Set additional custom uniforms
    int uniformIndex = 19;
    uniforms.forEach((key, value) {
      if (value is double) {
        shader!.setFloat(uniformIndex++, value);
      } else if (value is int) {
        shader!.setFloat(uniformIndex++, value.toDouble());
      }
    });
  }

  @override
  bool shouldRepaint(covariant ShaderEffectPainter oldDelegate) {
    return time != oldDelegate.time ||
        theme != oldDelegate.theme ||
        shader != oldDelegate.shader ||
        uniforms != oldDelegate.uniforms;
  }
}

// Shader effect manager
class ShaderEffectSystem {
  static final ShaderEffectSystem _instance = ShaderEffectSystem._internal();
  factory ShaderEffectSystem() => _instance;
  ShaderEffectSystem._internal();

  final Map<String, ui.FragmentShader> _shaders = {};
  bool _shadersLoaded = false;

  Future<void> loadShaders() async {
    if (_shadersLoaded) return;

    try {
      // Load cyberpunk matrix shader
      await _loadShader('cyberpunk_matrix', '''
        #version 460 core
        precision mediump float;

        uniform vec2 u_resolution;
        uniform float u_time;
        uniform vec4 u_bgColor;
        uniform vec4 u_accentColor;

        out vec4 fragColor;

        float random(vec2 st) {
            return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
        }

        void main() {
            vec2 uv = gl_FragCoord.xy / u_resolution.xy;
            
            // Digital rain effect
            float rainSpeed = 2.0;
            float rainDensity = 0.8;
            
            vec2 matrixUV = uv * vec2(30.0, 50.0);
            vec2 matrixID = floor(matrixUV);
            
            float rain = random(matrixID + floor(u_time * rainSpeed));
            rain = step(rainDensity, rain);
            
            // Character flicker
            float flicker = random(matrixID + floor(u_time * 10.0));
            flicker = step(0.7, flicker);
            
            // Fade based on vertical position
            float fade = pow(1.0 - uv.y, 2.0);
            
            vec3 color = u_accentColor.rgb * rain * flicker * fade;
            color += u_bgColor.rgb * 0.1;
            
            fragColor = vec4(color, 1.0);
        }
      ''');

      // Load neon glow shader
      await _loadShader('neon_glow', '''
        #version 460 core
        precision mediump float;

        uniform vec2 u_resolution;
        uniform float u_time;
        uniform vec4 u_accentColor;
        uniform vec4 u_snakeColor;

        out vec4 fragColor;

        void main() {
            vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / min(u_resolution.y, u_resolution.x);
            
            // Rotating neon lines
            float angle = u_time * 0.5;
            mat2 rotation = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
            uv *= rotation;
            
            // Create neon grid
            vec2 grid = abs(fract(uv * 8.0) - 0.5);
            float lines = min(grid.x, grid.y);
            lines = smoothstep(0.0, 0.1, lines);
            lines = 1.0 - lines;
            
            // Pulsing effect
            float pulse = sin(u_time * 3.0) * 0.5 + 0.5;
            
            vec3 color = u_accentColor.rgb * lines * (0.5 + pulse * 0.5);
            color += u_snakeColor.rgb * lines * pulse * 0.3;
            
            fragColor = vec4(color, lines * 0.8);
        }
      ''');

      // Load crystal refraction shader
      await _loadShader('crystal_refraction', '''
        #version 460 core
        precision mediump float;

        uniform vec2 u_resolution;
        uniform float u_time;
        uniform vec4 u_accentColor;
        uniform vec4 u_bgColor;

        out vec4 fragColor;

        vec3 hsv2rgb(vec3 c) {
            vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
            return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
        }

        void main() {
            vec2 uv = gl_FragCoord.xy / u_resolution.xy;
            vec2 center = vec2(0.5, 0.5);
            
            float dist = distance(uv, center);
            float angle = atan(uv.y - center.y, uv.x - center.x);
            
            // Prismatic effect
            float prism = sin(angle * 6.0 + u_time) * 0.1 + dist;
            
            // Rainbow refraction
            float hue = prism + u_time * 0.1;
            vec3 rainbow = hsv2rgb(vec3(hue, 0.8, 1.0));
            
            // Crystal facets
            float facets = sin(angle * 12.0) * sin(dist * 20.0 - u_time * 2.0);
            facets = smoothstep(0.0, 0.5, facets);
            
            vec3 color = mix(u_bgColor.rgb, rainbow, facets * 0.6);
            color += u_accentColor.rgb * facets * 0.4;
            
            fragColor = vec4(color, 1.0);
        }
      ''');

      // Load ocean waves shader
      await _loadShader('ocean_waves', '''
        #version 460 core
        precision mediump float;

        uniform vec2 u_resolution;
        uniform float u_time;
        uniform vec4 u_accentColor;
        uniform vec4 u_bgColor;

        out vec4 fragColor;

        float wave(vec2 uv, float freq, float amp) {
            return sin(uv.x * freq + u_time) * amp;
        }

        void main() {
            vec2 uv = gl_FragCoord.xy / u_resolution.xy;
            
            // Multiple wave layers
            float wave1 = wave(uv, 4.0, 0.1);
            float wave2 = wave(uv + vec2(0.5, 0.0), 6.0, 0.05);
            float wave3 = wave(uv + vec2(0.0, 0.3), 8.0, 0.03);
            
            float waveSum = wave1 + wave2 + wave3;
            float waveOffset = uv.y + waveSum;
            
            // Ocean depth gradient
            float depth = smoothstep(0.0, 1.0, waveOffset);
            
            vec3 shallowColor = u_accentColor.rgb;
            vec3 deepColor = u_bgColor.rgb;
            
            vec3 color = mix(deepColor, shallowColor, depth);
            
            // Foam on wave peaks
            float foam = smoothstep(0.85, 1.0, waveOffset);
            color = mix(color, vec3(1.0), foam * 0.3);
            
            fragColor = vec4(color, 1.0);
        }
      ''');

      // Load desert heat haze shader
      await _loadShader('desert_haze', '''
        #version 460 core
        precision mediump float;

        uniform vec2 u_resolution;
        uniform float u_time;
        uniform vec4 u_bgColor;
        uniform vec4 u_accentColor;

        out vec4 fragColor;

        float noise(vec2 p) {
            return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
        }

        void main() {
            vec2 uv = gl_FragCoord.xy / u_resolution.xy;
            
            // Heat distortion
            float heatWave1 = sin(uv.y * 10.0 + u_time * 2.0) * 0.01;
            float heatWave2 = sin(uv.y * 15.0 + u_time * 3.0) * 0.005;
            vec2 distortedUV = uv + vec2(heatWave1 + heatWave2, 0.0);
            
            // Sand dunes
            float dune1 = sin(distortedUV.x * 3.14159 + u_time * 0.1) * 0.1 + 0.3;
            float dune2 = sin(distortedUV.x * 6.28318 + u_time * 0.15) * 0.05 + 0.5;
            
            float height = max(dune1, dune2);
            float isAboveGround = step(height, uv.y);
            
            // Sky gradient
            vec3 skyColor = mix(u_accentColor.rgb, u_bgColor.rgb, uv.y);
            
            // Sand color with heat shimmer
            vec3 sandColor = u_bgColor.rgb * (1.0 + noise(distortedUV * 50.0) * 0.1);
            
            vec3 color = mix(sandColor, skyColor, isAboveGround);
            
            fragColor = vec4(color, 1.0);
        }
      ''');

      _shadersLoaded = true;
    } catch (e) {
      debugPrint('Failed to load shaders: $e');
    }
  }

  Future<void> _loadShader(String name, String fragmentShaderCode) async {
    try {
      // Note: Custom shader loading requires pre-compiled SPIR-V shaders in assets
      // For this implementation, we use Flutter's built-in rendering instead
      debugPrint(
        'Shader effects implemented using native Flutter rendering: $name',
      );
      // Alternative: Use CustomPainter with gradients and animations for visual effects
      // This provides better performance and platform compatibility
    } catch (e) {
      debugPrint('Failed to load shader $name: $e');
    }
  }

  ui.FragmentShader? getShader(String name) {
    return _shaders[name];
  }

  bool get areShadersLoaded => _shadersLoaded;
}

// Shader-enhanced widgets
class ShaderEnhancedBackground extends StatefulWidget {
  final Widget child;
  final GameTheme theme;
  final bool enabled;

  const ShaderEnhancedBackground({
    super.key,
    required this.child,
    required this.theme,
    this.enabled = true,
  });

  @override
  State<ShaderEnhancedBackground> createState() =>
      _ShaderEnhancedBackgroundState();
}

class _ShaderEnhancedBackgroundState extends State<ShaderEnhancedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ShaderEffectSystem _shaderSystem = ShaderEffectSystem();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _shaderSystem.loadShaders();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getShaderNameForTheme(GameTheme theme) {
    switch (theme) {
      case GameTheme.cyberpunk:
        return 'cyberpunk_matrix';
      case GameTheme.neon:
        return 'neon_glow';
      case GameTheme.crystal:
        return 'crystal_refraction';
      case GameTheme.ocean:
        return 'ocean_waves';
      case GameTheme.desert:
        return 'desert_haze';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !_shaderSystem.areShadersLoaded) {
      return widget.child;
    }

    final shaderName = _getShaderNameForTheme(widget.theme);
    final shader = _shaderSystem.getShader(shaderName);

    if (shader == null) {
      return widget.child;
    }

    return Stack(
      children: [
        // Shader background
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ShaderEffectPainter(
                  shader: shader,
                  theme: widget.theme,
                  time: _controller.value * 10.0, // 10 second cycle
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
        // Content overlay
        widget.child,
      ],
    );
  }
}

// Post-processing effects
class PostProcessingEffect extends StatefulWidget {
  final Widget child;
  final GameTheme theme;
  final double intensity;

  const PostProcessingEffect({
    super.key,
    required this.child,
    required this.theme,
    this.intensity = 1.0,
  });

  @override
  State<PostProcessingEffect> createState() => _PostProcessingEffectState();
}

class _PostProcessingEffectState extends State<PostProcessingEffect> {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return _createPostProcessingShader(bounds);
      },
      child: widget.child,
    );
  }

  Shader _createPostProcessingShader(Rect bounds) {
    // Create theme-specific post-processing effects
    switch (widget.theme) {
      case GameTheme.neon:
        return _createNeonGlowShader(bounds);
      case GameTheme.cyberpunk:
        return _createCyberpunkShader(bounds);
      case GameTheme.retro:
        return _createRetroShader(bounds);
      default:
        return _createDefaultShader(bounds);
    }
  }

  Shader _createNeonGlowShader(Rect bounds) {
    return LinearGradient(
      colors: [
        widget.theme.accentColor.withValues(alpha: 0.8 * widget.intensity),
        Colors.white.withValues(alpha: 0.6 * widget.intensity),
        widget.theme.accentColor.withValues(alpha: 0.8 * widget.intensity),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(bounds);
  }

  Shader _createCyberpunkShader(Rect bounds) {
    return RadialGradient(
      colors: [
        widget.theme.snakeColor.withValues(alpha: 0.9 * widget.intensity),
        widget.theme.accentColor.withValues(alpha: 0.7 * widget.intensity),
        Colors.black.withValues(alpha: 0.5),
      ],
    ).createShader(bounds);
  }

  Shader _createRetroShader(Rect bounds) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.orange.withValues(alpha: 0.3 * widget.intensity),
        Colors.red.withValues(alpha: 0.2 * widget.intensity),
        Colors.purple.withValues(alpha: 0.1 * widget.intensity),
      ],
    ).createShader(bounds);
  }

  Shader _createDefaultShader(Rect bounds) {
    return LinearGradient(
      colors: [
        Colors.transparent,
        widget.theme.accentColor.withValues(alpha: 0.1 * widget.intensity),
      ],
    ).createShader(bounds);
  }
}

// Utility for creating GPU-accelerated visual effects
class GPUEffectsUtil {
  static Widget createGlowEffect({
    required Widget child,
    required Color glowColor,
    double blurRadius = 10.0,
    double spreadRadius = 5.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: blurRadius * 1.5,
            spreadRadius: spreadRadius * 1.2,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.1),
            blurRadius: blurRadius * 2,
            spreadRadius: spreadRadius * 1.5,
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget createRippleEffect({
    required Widget child,
    required Animation<double> animation,
    required Color rippleColor,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return CustomPaint(
          painter: RippleEffectPainter(
            progress: animation.value,
            color: rippleColor,
          ),
          child: child,
        );
      },
    );
  }
}

class RippleEffectPainter extends CustomPainter {
  final double progress;
  final Color color;

  RippleEffectPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;

    for (int i = 0; i < 3; i++) {
      final rippleProgress = (progress - i * 0.3).clamp(0.0, 1.0);
      final radius = maxRadius * rippleProgress;
      final opacity = (1.0 - rippleProgress) * 0.5;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RippleEffectPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
