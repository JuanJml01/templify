import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:templify/presenters/user_presenter.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with TickerProviderStateMixin {
  // Controllers and Focus Nodes
  late TextEditingController _apiController;
  late FocusNode _apiFocusNode;

  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeControllers() {
    debugPrint('Settings: Initializing controllers');
    _apiController = TextEditingController();
    _apiFocusNode = FocusNode();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _initializeAnimations() {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _loadInitialData() {
    try {
      debugPrint('Settings: Loading initial data');
      final userPresenter = context.read<UserPresenter>();
      _apiController.text = userPresenter.apiGeminis;

      // Start animations
      _slideController.forward();
      _fadeController.forward();
      _scaleController.forward();

      debugPrint('Settings: Initial data loaded successfully');
    } catch (e) {
      debugPrint('Settings: Error loading initial data: $e');
      _setError('Error al cargar la configuración');
    }
  }

  void _setError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });

    // Clear error after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = '';
        });
      }
    });
  }

  void _showSavedFeedback() {
    setState(() => _isSaved = true);

    // Hide saved feedback after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSaved = false);
      }
    });
  }

  Future<void> _saveApiKey(String value) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('Settings: Saving API key (length: ${value.length})');

      await context.read<UserPresenter>().setApiGeminis(value);

      debugPrint('Settings: API key saved successfully');
      _showSavedFeedback();
    } catch (e) {
      debugPrint('Settings: Error saving API key: $e');
      _setError('Error al guardar la configuración');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildHeader(ColorScheme colorScheme, Size size) {
    final isCompact = size.height < 850;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isCompact ? 16 : 32,
          ),
          child: Column(
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha:  0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 36,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 16 : 24),
              Text(
                'Configuración',
                style: TextStyle(
                  fontSize: isCompact ? 24 : 28,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: isCompact ? 8 : 12),
              Text(
                'Personaliza tu experiencia con Templify',
                style: TextStyle(
                  fontSize: isCompact ? 14 : 16,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeySection(ColorScheme colorScheme, Size size) {
    final isCompact = size.height < 850;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isCompact ? 8 : 16,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha:  0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha:  0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.key_rounded,
                      size: 18,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Key de Gemini',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Opcional - Para funciones avanzadas',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isSaved)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Guardado',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apiController,
                focusNode: _apiFocusNode,
                enabled: !_isLoading,
                obscureText: false,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu API key (opcional)',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha:  0.6),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha:  0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.error, width: 2),
                  ),
                  prefixIcon: Icon(
                    Icons.vpn_key_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon:
                      _isLoading
                          ? Container(
                            width: 20,
                            height: 20,
                            padding: const EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                            ),
                          )
                          : null,
                ),
                onChanged: (value) {
                  debugPrint('Settings: API key input changed');
                  // Debounced save
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_apiController.text == value) {
                      _saveApiKey(value);
                    }
                  });
                },
                onTapOutside: (event) {
                  debugPrint('Settings: TextField tap outside detected');
                  _apiFocusNode.unfocus();
                  _saveApiKey(_apiController.text);
                },
              ),
              if (_hasError) ...[
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme, Size size) {
    final isCompact = size.height < 850;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isCompact ? 8 : 16,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha:  0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha:  0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'La API key es opcional. Sin ella, algunas funciones avanzadas podrían no estar disponibles.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 850;

    debugPrint(
      'Settings: Building UI (isCompact: $isCompact, size: ${size.width}x${size.height})',
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 18 : 20,
            color: colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            debugPrint('Settings: Navigation back pressed');
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
          ),
          tooltip: 'Volver',
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              colorScheme.brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: isCompact ? 8 : 16),
              _buildHeader(colorScheme, size),
              _buildApiKeySection(colorScheme, size),
              _buildInfoCard(colorScheme, size),
              SizedBox(height: isCompact ? 16 : 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('Settings: Disposing resources');

    _apiController.dispose();
    _apiFocusNode.dispose();

    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();

    super.dispose();
  }
}
