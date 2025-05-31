// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:developer' as developer;


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _logScreenInitialization();
  }


  void _initializeAnimations() {
    try {
      
      _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );

      
      _slideController = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );

      
      _scaleController = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );

      _rotateController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 170),
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
      );

      _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
      );

      
      _fadeController.forward();
      _slideController.forward();

      developer.log('Animations initialized successfully', name: 'Home');
    } catch (e) {
      developer.log(
        'Error initializing animations: $e',
        name: 'Home',
        level: 1000,
      );
      _setError('Animation initialization failed');
    }
  }


  void _logScreenInitialization() {
    final size = MediaQuery.sizeOf(context);
    developer.log(
      'Home screen initialized - Size: ${size.width}x${size.height}',
      name: 'Home',
    );
  }


  Future<void> _handleCreateTemplate() async {
    try {
      developer.log('Create template button pressed', name: 'Home');

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });


      await Future.delayed(const Duration(milliseconds: 200));

      final size = MediaQuery.sizeOf(context);
      developer.log(
        'Template creation initiated - Screen: ${size.width}x${size.height}',
        name: 'Home',
      );

      Navigator.pushNamed(context, '/createTemplate');
    } catch (e) {
      developer.log(
        'Error in template creation: $e',
        name: 'Home',
        level: 1000,
      );
      _setError('Failed to create template');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  Future<void> _handleSendMessage() async {
    try {
      developer.log('Send message button pressed', name: 'Home');

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulate message sending logic
      await Future.delayed(const Duration(milliseconds: 200));

      final size = MediaQuery.sizeOf(context);
      developer.log(
        'Message sending initiated - Screen height: ${size.height}',
        name: 'Home',
      );

      Navigator.pushNamed(context, "/selectTemplate");
    } catch (e) {
      developer.log('Error in message sending: $e', name: 'Home', level: 1000);
      _setError('Failed to send message');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _setError(String message) {
    setState(() => _errorMessage = message);
    developer.log('Error set: $message', name: 'Home', level: 900);
  }


  void _dismissError() {
    setState(() => _errorMessage = null);
    developer.log('Error dismissed', name: 'Home');
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    developer.log('Home screen disposed', name: 'Home');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        leading: RotationTransition(
          turns: _rotateController,
          child: IconButton(
            color: colorScheme.inverseSurface,
            onPressed: () {
              _rotateController.forward().then((_) {
                _rotateController.reset();
                Navigator.pushNamed(context, "/settings");
              });
            },
            icon: Icon(Icons.settings, size: 40),
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceContainerLowest,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.1,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(theme, size),
                    const SizedBox(height: 48),
                    _buildActionButtons(theme, size),
                    const SizedBox(height: 24),
                    _buildErrorDisplay(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(ThemeData theme, Size size) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // App icon with subtle animation
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 0.1,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.text_snippet_rounded,
                    size: 40,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Templify',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Crea y administra tus plantillas de mensajes',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons(ThemeData theme, Size size) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          _buildAnimatedButton(
            onPressed: _handleCreateTemplate,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.add_circle_outline_rounded,
            label: 'Crear Plantilla',
            size: size,
            delay: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: 16),
          _buildAnimatedButton(
            onPressed: _handleSendMessage,
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: Icons.send_rounded,
            label: 'Enviar mensaje',
            size: size,
            delay: const Duration(milliseconds: 400),
          ),
        ],
      ),
    );
  }

 
  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
    required String label,
    required Size size,
    required Duration delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: size.width * 0.8,
          height: _getButtonHeight(size),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isLoading ? null : onPressed,
              onTapDown: (_) => _scaleController.forward(),
              onTapUp: (_) => _scaleController.reverse(),
              onTapCancel: () => _scaleController.reverse(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            foregroundColor,
                          ),
                        ),
                      )
                    else
                      Icon(icon, color: foregroundColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: _getButtonFontSize(size),
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

 
  Widget _buildErrorDisplay(ThemeData theme) {
    if (_errorMessage == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: _dismissError,
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onErrorContainer,
              size: 20,
            ),
            splashRadius: 16,
          ),
        ],
      ),
    );
  }

  /// Calculate responsive button height
  double _getButtonHeight(Size size) {
    if (size.height < 850) {
      return size.height * 0.08;
    } else {
      return size.height * 0.06;
    }
  }

  /// Calculate responsive button font size
  double _getButtonFontSize(Size size) {
    if (size.height < 850) {
      return 18;
    } else {
      return 16;
    }
  }
}
