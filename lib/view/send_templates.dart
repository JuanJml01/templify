import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:templify/model/template.dart';
import 'dart:developer' as developer;

/// Enhanced send templates screen with Material Design 3 principles
/// and comprehensive UX improvements
class SendTemplates extends StatefulWidget {
  const SendTemplates({super.key});

  @override
  State<SendTemplates> createState() => _SendTemplatesState();
}

class _SendTemplatesState extends State<SendTemplates>
    with TickerProviderStateMixin {
  // Controllers and state management
  late TextEditingController _previewController;
  late Template _template;
  late List<String> _fields;
  late List<TextEditingController> _inputControllers;
  late List<FocusNode> _focusNodes;

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State variables
  String _processedText = "";
  bool _isComplete = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Responsive design constants
  static const double _compactHeightThreshold = 850.0;
  static const double _defaultPadding = 16.0;
  static const double _compactPadding = 12.0;
  static const double _borderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _setupAnimations();
    _logScreenInitialization();
  }

  /// Initialize core components and controllers
  void _initializeComponents() {
    try {
      _previewController = TextEditingController();
      _isLoading = false;
      developer.log('SendTemplates components initialized successfully');
    } catch (e) {
      _handleError('Failed to initialize components', e);
    }
  }

  /// Setup animation controllers and animations
  void _setupAnimations() {
    try {
      _fadeAnimationController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );

      _slideAnimationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeAnimationController,
          curve: Curves.easeInOut,
        ),
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

      // Start animations
      _fadeAnimationController.forward();
      _slideAnimationController.forward();

      developer.log('Animations setup completed');
    } catch (e) {
      _handleError('Failed to setup animations', e);
    }
  }

  /// Initialize template-specific data after context is available
  void _initializeTemplateData() {
    try {
      _template = ModalRoute.of(context)!.settings.arguments as Template;
      _fields = _template.getFields();

      _inputControllers = List.generate(
        _fields.length,
        (index) => TextEditingController(),
      );

      _focusNodes = List.generate(_fields.length, (index) => FocusNode());

      if (_previewController.text.isEmpty) {
        _previewController.text = _template.text;
      }

      developer.log(
        'Template data initialized: ${_template.name}, '
        'Fields: ${_fields.length}',
      );
    } catch (e) {
      _handleError('Failed to initialize template data', e);
    }
  }

  /// Process template with user inputs and update preview
  void _processTemplate() {
    try {
      developer.log(
        'Processing template with ${_inputControllers.length} inputs',
      );

      bool allFieldsFilled = _validateAllFields();

      if (allFieldsFilled) {
        setState(() {
          final inputValues =
              _inputControllers
                  .map((controller) => controller.text.trim())
                  .toList();

          final fieldMap = Map.fromIterables(
            _fields.take(inputValues.length),
            inputValues.take(_fields.length),
          );

          _processedText = _template.replaceFields(fieldMap);
          _previewController.text = _processedText;
          _isComplete = true;

          developer.log('Template processed successfully');
        });
      } else {
        setState(() {
          _isComplete = false;
        });
      }
    } catch (e) {
      _handleError('Failed to process template', e);
    }
  }

  /// Validate that all required fields are filled
  bool _validateAllFields() {
    for (var controller in _inputControllers) {
      if (controller.text.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Share processed text via system share
  Future<void> _shareText() async {
    if (!_isComplete || _processedText.isEmpty) {
      _showSnackBar(
        'Por favor completa todos los campos primero',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SharePlus.instance.share(ShareParams(text: _processedText));

      developer.log('Text shared successfully');

      if (mounted) {
        _showSnackBar('¡Mensaje compartido exitosamente!');
        Navigator.pop(context);
      }
    } catch (e) {
      _handleError('Failed to share text', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle errors with logging and user feedback
  void _handleError(String message, dynamic error) {
    developer.log('Error: $message - $error', level: 1000);

    if (mounted) {
      setState(() {});

      _showSnackBar('Error: $message', isError: true);
    }
  }

  /// Show snackbar with customized styling
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius / 2),
        ),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  /// Log screen initialization for debugging
  void _logScreenInitialization() {
    developer.log('SendTemplates screen initialized', time: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    // Initialize template data only once
    if (!_isInitialized) {
      _initializeTemplateData();
      _isInitialized = true;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < _compactHeightThreshold;
    final padding = isCompact ? _compactPadding : _defaultPadding;

    developer.log(
      'Building UI - Screen size: ${size.width}x${size.height}, '
      'Compact mode: $isCompact',
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme, isCompact),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(theme, colorScheme, size, padding, isCompact),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  /// Build enhanced app bar with Material Design 3 styling
  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme, bool isCompact) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      title: Text(
        'Enviar mensaje',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isCompact ? 20 : 22,
          color: colorScheme.onSurface,
          letterSpacing: 0.15,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colorScheme.onSurface,
        ),
        tooltip: 'Volver',
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius / 2),
          ),
        ),
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

  /// Build main body with vertical layout (preview above inputs)
  Widget _buildBody(
    ThemeData theme,
    ColorScheme colorScheme,
    Size size,
    double padding,
    bool isCompact,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Template Header
          Padding(
            padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
            child: _buildTemplateHeader(colorScheme, padding),
          ),

          // Preview Section (fixed at top)
          Padding(
            padding: EdgeInsets.all(padding),
            child: _buildPreviewSection(colorScheme, padding),
          ),

          // Input Section (scrollable)
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
              child: _buildScrollableInputSection(colorScheme, padding),
            ),
          ),
        ],
      ),
    );
  }

  /// Build template header with name and description
  Widget _buildTemplateHeader(ColorScheme colorScheme, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Plantilla',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _template.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }

  /// Build scrollable input section to prevent FAB overlap
  Widget _buildScrollableInputSection(ColorScheme colorScheme, double padding) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Completar campos (${_fields.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.15,
                  ),
                ),
                const Spacer(),
                if (_isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Completo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),

          // Scrollable input fields
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  ...List.generate(_fields.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _fields.length - 1 ? padding : 0,
                      ),
                      child: _buildInputField(index, colorScheme),
                    );
                  }),
                  // Extra space to prevent FAB overlap
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual input field with enhanced styling
  Widget _buildInputField(int index, ColorScheme colorScheme) {
    final fieldName =
        _fields[index]; // Field names come without the "/" from getFields()

    return TextField(
      controller: _inputControllers[index],
      focusNode: _focusNodes[index],
      onChanged: (_) => _processTemplate(),
      onTapOutside: (_) => _focusNodes[index].unfocus(),
      maxLines: 1,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: fieldName.toUpperCase(),
        hintText: 'Ingresa $fieldName',
        prefixIcon: Icon(
          _getFieldIcon(fieldName),
          color: colorScheme.primary.withValues(alpha: 0.7),
          size: 20,
        ),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius / 2),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius / 2),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius / 2),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius / 2),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
      ),
    );
  }

  /// Build preview section with live updates
  Widget _buildPreviewSection(ColorScheme colorScheme, double padding) {
    return Container(
      height: 200, // Fixed height for preview
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: Row(
              children: [
                Icon(
                  Icons.preview_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vista previa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.15,
                  ),
                ),
                const Spacer(),
                if (_isComplete)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: SingleChildScrollView(
                child: TextField(
                  controller: _previewController,
                  enabled: false,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'La vista previa aparecerá aquí...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface,
                    height: 1.5,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button with enhanced styling
  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        onPressed: _isComplete && !_isLoading ? _shareText : null,
        backgroundColor:
            _isComplete
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
        foregroundColor:
            _isComplete
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.5),
        elevation: _isComplete ? 6 : 2,
        icon:
            _isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimary,
                    ),
                  ),
                )
                : Icon(Icons.send_rounded, size: 20),
        label: Text(
          _isLoading
              ? 'Enviando...'
              : _isComplete
              ? 'Enviar mensaje'
              : 'Completa los campos',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  /// Get appropriate icon for field type based on field name
  IconData _getFieldIcon(String fieldName) {
    final lowerName = fieldName.toLowerCase();

    if (lowerName.contains('nombre') || lowerName.contains('name')) {
      return Icons.person_outline;
    } else if (lowerName.contains('telefono') || lowerName.contains('phone')) {
      return Icons.phone_outlined;
    } else if (lowerName.contains('email') || lowerName.contains('correo')) {
      return Icons.email_outlined;
    } else if (lowerName.contains('direccion') ||
        lowerName.contains('address')) {
      return Icons.location_on_outlined;
    } else if (lowerName.contains('empresa') || lowerName.contains('company')) {
      return Icons.business_outlined;
    } else if (lowerName.contains('fecha') || lowerName.contains('date')) {
      return Icons.calendar_today_outlined;
    } else if (lowerName.contains('precio') ||
        lowerName.contains('price') ||
        lowerName.contains('monto') ||
        lowerName.contains('amount')) {
      return Icons.attach_money_outlined;
    } else {
      return Icons.edit_outlined;
    }
  }

  @override
  void dispose() {
    try {
      _previewController.dispose();

      for (var controller in _inputControllers) {
        controller.dispose();
      }

      for (var node in _focusNodes) {
        node.dispose();
      }

      _fadeAnimationController.dispose();
      _slideAnimationController.dispose();

      developer.log('SendTemplates resources disposed successfully');
    } catch (e) {
      developer.log('Error during disposal: $e', level: 1000);
    }

    super.dispose();
  }
}
