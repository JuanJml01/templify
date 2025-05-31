import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:templify/model/template.dart';
import 'package:templify/presenters/user_presenter.dart';

class CreateTemplate extends StatefulWidget {
  const CreateTemplate({super.key});

  @override
  State<CreateTemplate> createState() => _CreateTemplateState();
}

class _CreateTemplateState extends State<CreateTemplate>
    with TickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;
  late final TextEditingController _inputGeminisController;
  late final FocusNode _geminisFocus;
  late final FocusNode _nameFocus;
  late final FocusNode _contentFocus;
  late final FocusNode _addFocus;
  late final WidgetStatesController _contentStates;

  late final AnimationController _slideAnimationController;
  late final AnimationController _scaleAnimationController;
  late final AnimationController _fadeAnimationController;
  late final AnimationController _fabAnimationController;
  late final AnimationController _geminiTitleAnimationController;
  late final AnimationController _geminiSuccessAnimationController;
  late final AnimationController _geminiErrorAnimationController;

  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _fabScaleAnimation;
  late final Animation<double> _geminiTitleAnimation;
  late final Animation<double> _geminiSuccessAnimation;
  late final Animation<double> _geminiErrorAnimation;

  bool _contentEmpty = false;
  bool _nameEmpty = false;
  bool _isFill = false;
  bool _loadingTemplate = false;
  bool _showValidationErrors = false;
  bool _isSubmittingGemini = false;
  bool _geminiSubmissionSuccess = false;
  String? _geminiSubmissionError;

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

  void _initializeControllers() {
    _inputGeminisController = TextEditingController();
    _nameController = TextEditingController();
    _contentController = TextEditingController();
    _nameFocus = FocusNode();
    _contentFocus = FocusNode();
    _addFocus = FocusNode();
    _geminisFocus = FocusNode();
    _contentStates = WidgetStatesController();

    _nameController.addListener(_validateInputs);
    _contentController.addListener(_validateInputs);
  }

  void _initializeAnimations() {
    _geminiTitleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _geminiTitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _geminiTitleAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _geminiSuccessAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _geminiSuccessAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _geminiSuccessAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _geminiErrorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _geminiErrorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _geminiErrorAnimationController,
        curve: Curves.elasticIn,
      ),
    );

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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showGeminiPrompt() {
    debugPrint('GeminiPromptSheet: opening');

    setState(() {
      _isSubmittingGemini = false;
      _geminiSubmissionError = null;
      _geminiSubmissionSuccess = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: !_isSubmittingGemini,
      enableDrag: !_isSubmittingGemini,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final size = MediaQuery.sizeOf(context);

            // Start title animation
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _geminiTitleAnimationController.forward();
            });

            return GestureDetector(
              onTap: () {
                if (!_isSubmittingGemini) {
                  _geminisFocus.unfocus();
                }
              },
              child: Container(
                height: size.height * 0.75,
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).viewInsets.top + 50,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      offset: const Offset(0, -4),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _calculateGeminiHorizontalPadding(size.width),
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGeminiTitle(colorScheme, size),
                        const SizedBox(height: 24),
                        Expanded(
                          child: _buildGeminiInputField(
                            colorScheme,
                            size,
                            setModalState,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_geminiSubmissionError != null)
                          _buildGeminiErrorMessage(colorScheme),
                        const SizedBox(height: 16),
                        _buildGeminiButtons(colorScheme, size, setModalState),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        _isSubmittingGemini = false;
        _geminiSubmissionError = null;
        _geminiSubmissionSuccess = false;
      });
      _inputGeminisController.clear();
      _geminiTitleAnimationController.reset();
      _geminiSuccessAnimationController.reset();
      _geminiErrorAnimationController.reset();
    });
  }

  double _calculateGeminiHorizontalPadding(double width) {
    const double sheetMaxWidth = 600.0;
    if (width > sheetMaxWidth) {
      return (width - sheetMaxWidth) / 2;
    }
    return 20.0;
  }

  Widget _buildGeminiTitle(ColorScheme colorScheme, Size size) {
    return FadeTransition(
      opacity: _geminiTitleAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).animate(_geminiTitleAnimation),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Crea con geminis',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeminiInputField(
    ColorScheme colorScheme,
    Size size,
    StateSetter setModalState,
  ) {
    return TextField(
      onTapOutside: (evt) => _geminisFocus.unfocus(),
      controller: _inputGeminisController,
      focusNode: _geminisFocus,
      enabled: !_isSubmittingGemini,
      maxLines: size.height < 700 ? 8 : 12,
      minLines: size.height < 700 ? 6 : 8,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(fontSize: 16, height: 1.4, color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Escriba lo que quieras crear',
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 16,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
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
        counterStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 12,
        ),
      ),
      onChanged: (value) {
        if (_geminiSubmissionError != null) {
          setModalState(() {
            _geminiSubmissionError = null;
          });
          _geminiErrorAnimationController.reset();
        }
      },
    );
  }

  Widget _buildGeminiErrorMessage(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _geminiErrorAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _geminiErrorAnimation.value *
                4 *
                ((_geminiErrorAnimation.value * 10).floor() % 2 == 0 ? 1 : -1),
            0,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _geminiSubmissionError!,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeminiButtons(
    ColorScheme colorScheme,
    Size size,
    StateSetter setModalState,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed:
                _isSubmittingGemini
                    ? null
                    : () {
                      debugPrint('GeminiPromptSheet: canceled');
                      Navigator.of(context).pop();
                    },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSubmissionState(colorScheme, size, setModalState),
        ),
      ],
    );
  }

  Widget _buildSubmissionState(
    ColorScheme colorScheme,
    Size size,
    StateSetter setModalState,
  ) {
    if (_geminiSubmissionSuccess) {
      return ScaleTransition(
        scale: _geminiSuccessAnimation,
        child: ElevatedButton.icon(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
          ),
          icon: const Icon(Icons.check_rounded, size: 20),
          label: const Text(
            'Hecho',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    if (_isSubmittingGemini) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.7),
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Enviando...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _submitGeminiPrompt(setModalState),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 2,
      ),
      child: const Text(
        'Crear',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _submitGeminiPrompt(StateSetter setModalState) async {
    try {
      final input = _inputGeminisController.text.trim();

      if (input.isEmpty) {
        debugPrint('GeminiPromptSheet: validation failed - empty input');
        setModalState(() {
          _geminiSubmissionError =
              'Por favor, introduzca algún texto antes de enviar.';
        });
        _geminiErrorAnimationController.forward();
        return;
      }

      debugPrint(
        'GeminiPromptSheet: sending request with input: "${input.substring(0, input.length > 50 ? 50 : input.length)}${input.length > 50 ? '...' : ''}"',
      );

      setModalState(() {
        _isSubmittingGemini = true;
        _geminiSubmissionError = null;
      });

      try {
        final apiKey = context.read<UserPresenter>().apiGeminis;
        if (apiKey.isEmpty || apiKey == "") {
          throw Exception('API key de Gemini no configurada');
        }

        debugPrint('GeminiPromptSheet: initializing Gemini API');
        Gemini.init(apiKey: apiKey);
      } catch (initError) {
        debugPrint(
          'GeminiPromptSheet: Gemini initialization failed - $initError',
        );
        throw Exception('Error al inicializar Gemini: $initError');
      }

      debugPrint('GeminiPromptSheet: sending prompt to Gemini API');

      final promptText =
          '''Actúa como uno de los siguientes profesionales, según el enfoque más adecuado para la descripción proporcionada:

Redactor corporativo – Especializado en comunicaciones empresariales claras y formales.

Consultor legal – Enfocado en lenguaje técnico y estructuras jurídicas precisas.

Asistente de recursos humanos – Profesional empático, orientado a procesos internos y gestión de personal.

Coordinador académico – Redacta con enfoque institucional, informativo y educativo.

Agente de atención al cliente – Comunicación cordial, directa y resolutiva.

Ejecutivo de ventas – Estilo persuasivo, profesional y centrado en resultados.

Especialista en marketing – Redacción atractiva, clara y orientada a objetivos comerciales.

Analista financiero – Comunicación técnica, objetiva y basada en datos.

Coordinador de proyectos – Redacción estructurada, clara y enfocada en planificación y ejecución.

Abogado corporativo – Lenguaje formal, preciso y alineado con la normativa legal.

Psicólogo organizacional – Estilo reflexivo y profesional con atención al factor humano.

Mentor profesional – Comunicación inspiradora, clara y orientada al desarrollo.

Asesor de imagen – Redacción estratégica, elegante y convincente.

Comunicador institucional – Lenguaje diplomático, profesional y accesible al público.

Redactor técnico – Precisión terminológica y estructura funcional.

Funcionario público – Redacción administrativa, clara y conforme a protocolos oficiales.

Gestor de innovación – Estilo proactivo, flexible y profesional.

Coordinador de eventos – Comunicación organizada, detallada y práctica.

Experto en protocolo – Lenguaje ceremonioso, formal y respetuoso.

Traductor profesional – Redacción neutra, correcta y adaptable a múltiples contextos.

Tu tarea es crear una plantilla de texto profesional reutilizable basada en la siguiente descripción: "$input".

Instrucciones detalladas:

Piensa paso a paso cómo transformar la descripción en una plantilla clara, profesional y reutilizable.

Usa únicamente el formato /campo para los espacios variables dentro del texto.
Cada campo debe comenzar con una sola barra inclinada (/) seguida del nombre del campo, sin espacios, sin símbolos adicionales y sin barras al final.

Ejemplos correctos:

/nombre

/empresa

/fecha_de_envío

Ejemplos incorrectos (no usar):

/nombre/

{nombre}

[nombre]

<nombre>
/ nombre

/Nombre (no uses mayúsculas ni acentos en el nombre del campo)

Los campos deben integrarse de forma natural dentro del texto, como parte de frases completas, y deben ser claros y descriptivos para facilitar su comprensión y reutilización.

No modifiques innecesariamente el formato del texto original.

Evita el uso de markdown, listas automáticas, sangrías exageradas o estructuras de código.

Mantén el texto como si fuera escrito directamente en un correo, carta o documento profesional.

Usa un tono y estilo adecuados según el perfil profesional elegido. El tono debe reflejar profesionalismo, claridad y coherencia.

La plantilla debe ser funcional y reutilizable, adecuada para contextos similares al descrito.

El texto no debe superar las 300 palabras.

Responde únicamente con la plantilla final. No añadas explicaciones, introducciones, notas o comentarios adicionales.''';

      debugPrint('GeminiPromptSheet: sending prompt to Gemini API');

      // Cambiar de promptStream a prompt para evitar el error HTTP 400
      final response = await Gemini.instance.prompt(
        parts: [Part.text(promptText)],
      );

      if (response?.output == null || response!.output!.isEmpty) {
        debugPrint('GeminiPromptSheet: empty response from Gemini');
        throw Exception(
          'Gemini no generó contenido. Inténtalo con una descripción diferente.',
        );
      }

      String generatedContent = response.output!.trim();
      debugPrint(
        'GeminiPromptSheet: received complete response (${generatedContent.length} chars)',
      );

      if (generatedContent.length > 1000) {
        debugPrint('GeminiPromptSheet: response too long, truncating');
        generatedContent = '${generatedContent.substring(0, 1000)}...';
      }

      debugPrint(
        'GeminiPromptSheet: submission succeeded, updating content field',
      );

      // Aquí deberías asignar el contenido generado a donde corresponda
      // Por ejemplo: _contentController.text = generatedContent;
      _contentController.text = generatedContent;

      if (_nameController.text.trim().isEmpty) {
        String suggestedName = _generateTemplateName(input);
        _nameController.text = suggestedName;
        debugPrint(
          'GeminiPromptSheet: generated suggested name: "$suggestedName"',
        );
      }

      setModalState(() {
        _isSubmittingGemini = false;
        _geminiSubmissionSuccess = true;
      });

      _geminiSuccessAnimationController.forward();

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Plantilla generada exitosamente con Gemini'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      debugPrint('GeminiPromptSheet: submission failed - $error');

      String userFriendlyError;
      if (error.toString().contains('API key')) {
        userFriendlyError =
            'API key de Gemini no válida. Verifica tu configuración.';
      } else if (error.toString().contains('network') ||
          error.toString().contains('connection')) {
        userFriendlyError =
            'Error de conexión. Verifica tu internet e inténtalo de nuevo.';
      } else if (error.toString().contains('timeout') ||
          error.toString().contains('Tiempo de espera')) {
        userFriendlyError = 'Tiempo de espera agotado. Inténtalo de nuevo.';
      } else if (error.toString().contains('quota') ||
          error.toString().contains('limit')) {
        userFriendlyError = 'Límite de API alcanzado. Inténtalo más tarde.';
      } else if (error.toString().contains('400')) {
        userFriendlyError =
            'Error en la solicitud. Verifica la configuración de la API.';
      } else {
        userFriendlyError = 'Error al generar contenido. Inténtalo de nuevo.';
      }

      setModalState(() {
        _isSubmittingGemini = false;
        _geminiSubmissionError = userFriendlyError;
      });
      _geminiErrorAnimationController.forward();
    }
  }

  String _generateTemplateName(String description) {
    // Limpiar y limitar la descripción
    String cleanDescription = description.trim().toLowerCase();

    // Palabras clave para diferentes tipos de plantillas
    final Map<String, String> keywords = {
      'saludo': 'Plantilla de Saludo',
      'despedida': 'Plantilla de Despedida',
      'presentacion': 'Plantilla de Presentación',
      'email': 'Plantilla de Email',
      'carta': 'Plantilla de Carta',
      'invitacion': 'Plantilla de Invitación',
      'agradecimiento': 'Plantilla de Agradecimiento',
      'disculpa': 'Plantilla de Disculpa',
      'propuesta': 'Plantilla de Propuesta',
      'cotizacion': 'Plantilla de Cotización',
    };

    // Buscar palabras clave en la descripción
    for (String keyword in keywords.keys) {
      if (cleanDescription.contains(keyword)) {
        return keywords[keyword]!;
      }
    }

    // Si no encuentra palabras clave, usar las primeras palabras de la descripción
    List<String> words = cleanDescription.split(' ').take(3).toList();
    String baseName = words.join(' ');

    // Capitalizar primera letra de cada palabra
    baseName = baseName
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');

    return 'Plantilla de $baseName';
  }

  @override
  void dispose() {
    _inputGeminisController.dispose();
    _geminisFocus.dispose();
    _geminiTitleAnimationController.dispose();
    _geminiSuccessAnimationController.dispose();
    _geminiErrorAnimationController.dispose();
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
              colorScheme.primaryContainer.withValues(alpha: 0.1),
              colorScheme.secondaryContainer.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
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
                    color: colorScheme.primary.withValues(alpha: 0.1),
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
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '"Hola, buenas tardes señor, /nombre"',
                style: TextStyle(
                  fontSize: 12,
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
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
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
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.4,
              ),
              counterStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              errorText:
                  _contentEmpty && _showValidationErrors
                      ? 'El contenido es requerido'
                      : null,
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
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
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            context.read<UserPresenter>().apiGeminis != "" ||
                    context.read<UserPresenter>().apiGeminis.isNotEmpty
                ? FloatingActionButton.small(
                  onPressed: () {
                    _showGeminiPrompt();
                  },
                  foregroundColor: colorScheme.onSecondary,
                  backgroundColor: colorScheme.secondary,
                  child: Icon(Icons.auto_awesome),
                )
                : SizedBox(height: 0),
            _loadingTemplate
                ? FloatingActionButton.extended(
                  key: const ValueKey('loading'),
                  heroTag: 'create_template_loading', // Agregado heroTag único
                  onPressed: null,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.7),
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
          ],
        ),
      ),
    );
  }
}
