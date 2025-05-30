import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:templify/model/template.dart';
import 'package:templify/presenters/user_presenter.dart';

/// Enhanced Create Template screen with Google Material Design principles
/// Implements animations, responsive design, and improved UX
class CreateTemplate extends StatefulWidget {
  const CreateTemplate({super.key});

  @override
  State<CreateTemplate> createState() => _CreateTemplateState();
}

class _CreateTemplateState extends State<CreateTemplate>
    with TickerProviderStateMixin {
  // Controllers and Focus Nodes
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;
  late final FocusNode _nameFocus;
  late final FocusNode _contentFocus;
  late final FocusNode _addFocus;
  late final WidgetStatesController _contentStates;

  // Animation Controllers
  late final AnimationController _slideAnimationController;
  late final AnimationController _scaleAnimationController;
  late final AnimationController _fadeAnimationController;
  late final AnimationController _fabAnimationController;

  // Animations
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _fabScaleAnimation;

  // State variables
  bool _contentEmpty = false;
  bool _nameEmpty = false;
  bool _isFill = false;
  bool _createTemplate = false;
  bool _loadingTemplate = false;
  bool _showValidationErrors = false;

  // Constants for responsive design
  static const double _maxContentWidth = 600.0;
  static const double _compactHeightThreshold = 850.0;
  static const double _standardSpacing = 24.0;
  static const double _compactSpacing = 16.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _startEntryAnimations();
  }

  /// Initialize all controllers and focus nodes
  void _initializeControllers() {
    _nameController = TextEditingController();
    _contentController = TextEditingController();
    _nameFocus = FocusNode();
    _contentFocus = FocusNode();
    _addFocus = FocusNode();
    _contentStates = WidgetStatesController();

    // Add listeners for real-time validation
    _nameController.addListener(_validateInputs);
    _contentController.addListener(_validateInputs);
  }

  /// Initialize all animation controllers and animations
  void _initializeAnimations() {
    // Slide animation for entrance
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Scale animation for interactive elements
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Fade animation for content transitions
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // FAB animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  /// Start entrance animations
  void _startEntryAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _slideAnimationController.forward();
        _scaleAnimationController.forward();
        _fadeAnimationController.forward();
        _fabAnimationController.forward();
      }
    });
  }

  /// Validate inputs in real-time
  void _validateInputs() {
    if (!_showValidationErrors) return;

    setState(() {
      _nameEmpty = _nameController.text.trim().isEmpty;
      _contentEmpty = _contentController.text.trim().isEmpty;
    });
  }

  /// Handle template submission with proper error handling
  Future<void> _handleSubmit() async {
    try {
      debugPrint('CreateTemplate: Starting template submission');

      setState(() {
        _showValidationErrors = true;
        _nameEmpty = _nameController.text.trim().isEmpty;
        _contentEmpty = _contentController.text.trim().isEmpty;
      });

      if (_nameEmpty) {
        _showErrorSnackBar('El nombre de la plantilla es requerido');
        _nameFocus.requestFocus();
        return;
      }

      if (_contentEmpty) {
        _showErrorSnackBar('El contenido de la plantilla es requerido');
        _contentFocus.requestFocus();
        return;
      }

      setState(() {
        _isFill = true;
        _loadingTemplate = true;
      });

      // Haptic feedback for better UX
      HapticFeedback.lightImpact();

      final template = Template(
        _nameController.text.trim(),
        _contentController.text.trim(),
      );

      debugPrint(
        'CreateTemplate: Creating template with name: ${template.name}',
      );

      await context.read<UserPresenter>().addTemplate(template);

      debugPrint('CreateTemplate: Template created successfully');

      if (mounted) {
        _showSuccessSnackBar('Plantilla creada exitosamente');
        Navigator.pop(context);
      }
    } catch (error, stackTrace) {
      debugPrint('CreateTemplate: Error creating template: $error');
      debugPrint('CreateTemplate: Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isFill = false;
          _loadingTemplate = false;
        });
        _showErrorSnackBar('Error al crear la plantilla. Inténtalo de nuevo.');
      }
    }
  }

  /// Show error snack bar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  /// Show success snack bar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _nameFocus.dispose();
    _contentFocus.dispose();
    _addFocus.dispose();
    _contentStates.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _fadeAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isCompactHeight = size.height < _compactHeightThreshold;
    final spacing = isCompactHeight ? _compactSpacing : _standardSpacing;

    debugPrint(
      'CreateTemplate: Building UI with size: ${size.width}x${size.height}',
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme),
      body: _buildBody(size, colorScheme, spacing, isCompactHeight),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Build app bar with enhanced styling
  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      title: Text(
        'Crear Plantilla',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: colorScheme.onSurface,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
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
    );
  }

  /// Build main body content
  Widget _buildBody(
    Size size,
    ColorScheme colorScheme,
    double spacing,
    bool isCompactHeight,
  ) {
    return SafeArea(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: _calculateHorizontalPadding(size.width),
              vertical: spacing,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _maxContentWidth,
                minHeight: size.height - 200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isCompactHeight) ...[
                    _buildExplanationCard(colorScheme, size),
                    SizedBox(height: spacing * 1.5),
                  ],
                  _buildNameInput(colorScheme, size),
                  SizedBox(height: spacing),
                  _buildContentInput(colorScheme, size, isCompactHeight),
                  SizedBox(height: spacing * 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate responsive horizontal padding
  double _calculateHorizontalPadding(double width) {
    if (width > 600) return (width - _maxContentWidth) / 2;
    return 20.0;
  }

  /// Build explanation card with enhanced styling
  Widget _buildExplanationCard(ColorScheme colorScheme, Size size) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.secondaryContainer.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
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
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cómo crear tu plantilla',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ejemplo de plantilla personalizada:',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Text(
                '"Hola, buenas tardes señor /nombre"',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.primary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Las palabras después de "/" son campos editables que puedes personalizar al usar la plantilla.',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build name input field with enhanced styling
  Widget _buildNameInput(ColorScheme colorScheme, Size size) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nombre de la plantilla',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onTapOutside: (event) => _nameFocus.unfocus(),
            controller: _nameController,
            focusNode: _nameFocus,
            enabled: !_isFill,
            maxLength: 50,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Ej: Saludo formal',
              counterText: '',
              errorText:
                  _nameEmpty && _showValidationErrors
                      ? 'El nombre es requerido'
                      : null,
              prefixIcon: Icon(
                Icons.label_outline_rounded,
                color:
                    _nameEmpty && _showValidationErrors
                        ? colorScheme.error
                        : colorScheme.primary,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
            ),
            onSubmitted: (_) => _contentFocus.requestFocus(),
          ),
        ],
      ),
    );
  }

  /// Build content input field with enhanced styling
  Widget _buildContentInput(
    ColorScheme colorScheme,
    Size size,
    bool isCompactHeight,
  ) {
    final minLines = isCompactHeight ? 8 : 12;
    final maxLines = isCompactHeight ? 15 : 20;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color:
                    _contentEmpty && _showValidationErrors
                        ? colorScheme.error
                        : colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Contenido de la plantilla',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            onTapOutside: (event) => _contentFocus.unfocus(),
            controller: _contentController,
            focusNode: _contentFocus,
            statesController: _contentStates,
            enabled: !_isFill,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText:
                  'Escribe tu plantilla aquí...\nUsa /campo para crear campos editables',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
                height: 1.4,
              ),
              counterStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
              errorText:
                  _contentEmpty && _showValidationErrors
                      ? 'El contenido es requerido'
                      : null,
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
            ),
            onSubmitted: (_) => _handleSubmit(),
          ),
        ],
      ),
    );
  }


  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            _loadingTemplate
                ? FloatingActionButton.extended(
                  key: const ValueKey('loading'),
                  heroTag: 'create_template_loading', // Agregado heroTag único
                  onPressed: null,
                  backgroundColor: colorScheme.primary.withOpacity(0.7),
                  icon: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  label: Text(
                    'Creando...',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                : FloatingActionButton.extended(
                  key: const ValueKey('create'),
                  heroTag: 'create_template_create', // Agregado heroTag único
                  onPressed: _handleSubmit,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 6,
                  focusElevation: 8,
                  hoverElevation: 8,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    'Crear Plantilla',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
      ),
    );
  }
}
