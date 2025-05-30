import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:templify/presenters/user_presenter.dart';

/// Enhanced template selection screen with modern UI and smooth animations
/// Follows Google Material Design principles with responsive layout
class SelectTemplate extends StatefulWidget {
  const SelectTemplate({super.key});

  @override
  State<SelectTemplate> createState() => _SelectTemplateState();
}

class _SelectTemplateState extends State<SelectTemplate>
    with TickerProviderStateMixin {
  static const String _logTag = 'SelectTemplate';
  late AnimationController _fadeAnimationController;
  late AnimationController _staggerAnimationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;
  
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  List<dynamic> _filteredTemplates = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTemplates();
    debugPrint('$_logTag: Screen initialized');
  }

  void _initializeAnimations() {
    try {
      _fadeAnimationController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      
      _staggerAnimationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ));

      _fadeAnimationController.forward();
      _staggerAnimationController.forward();
      
      debugPrint('$_logTag: Animations initialized successfully');
    } catch (e) {
      debugPrint('$_logTag: Error initializing animations: $e');
    }
  }

  void _initializeTemplates() {
    try {
      final templates = context.read<UserPresenter>().templates;
      _filteredTemplates = List.from(templates);
      _initializeSlideAnimations(templates.length);
      debugPrint('$_logTag: ${templates.length} templates loaded');
    } catch (e) {
      debugPrint('$_logTag: Error loading templates: $e');
      _filteredTemplates = [];
    }
  }

  void _initializeSlideAnimations(int count) {
    _slideAnimations = List.generate(count, (index) {
      return Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerAnimationController,
        curve: Interval(
          index * 0.1,
          0.8 + (index * 0.05),
          curve: Curves.easeOutCubic,
        ),
      ));
    });
  }

  void _filterTemplates(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTemplates = List.from(context.read<UserPresenter>().templates);
      } else {
        _filteredTemplates = context
            .read<UserPresenter>()
            .templates
            .where((template) =>
                template.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
    debugPrint('$_logTag: Filtered ${_filteredTemplates.length} templates for query: "$query"');
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _filterTemplates('');
      }
    });
    debugPrint('$_logTag: Search visibility toggled: $_isSearchVisible');
  }

  void _navigateToSendTemplate(dynamic template) {
    try {
      HapticFeedback.lightImpact();
      Navigator.pushNamed(
        context,
        '/sendTemplate',
        arguments: template,
      );
      debugPrint('$_logTag: Navigating to sendTemplate with: ${template.name}');
    } catch (e) {
      debugPrint('$_logTag: Navigation error: $e');
      _showErrorSnackBar('Error al abrir la plantilla');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _staggerAnimationController.dispose();
    _searchController.dispose();
    debugPrint('$_logTag: Resources disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isCompactHeight = size.height < 850;
    
    debugPrint('$_logTag: Building UI - Screen size: ${size.width}x${size.height}, Compact: $isCompactHeight');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme, isCompactHeight),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            if (_isSearchVisible) _buildSearchBar(colorScheme, isCompactHeight),
            _buildTemplateCount(colorScheme, isCompactHeight),
            Expanded(
              child: _buildTemplateList(colorScheme, size, isCompactHeight),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme, bool isCompactHeight) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      toolbarHeight: isCompactHeight ? 56 : 64,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          'Seleccionar Plantilla',
          key: const ValueKey('title'),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isCompactHeight ? 20 : 22,
            color: colorScheme.onSurface,
            letterSpacing: 0.15,
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: colorScheme.onSurface,
          size: isCompactHeight ? 22 : 24,
        ),
        tooltip: 'Volver',
      ),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
              key: ValueKey(_isSearchVisible),
              color: colorScheme.onSurface,
              size: isCompactHeight ? 22 : 24,
            ),
          ),
          tooltip: _isSearchVisible ? 'Cerrar búsqueda' : 'Buscar plantillas',
        ),
        SizedBox(width: isCompactHeight ? 8 : 16),
      ],
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, bool isCompactHeight) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.all(isCompactHeight ? 12 : 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(28),
        color: colorScheme.surfaceContainerHighest,
        child: TextField(
          controller: _searchController,
          onChanged: _filterTemplates,
          autofocus: true,
          style: TextStyle(
            fontSize: isCompactHeight ? 14 : 16,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar plantillas...',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: isCompactHeight ? 14 : 16,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurfaceVariant,
              size: isCompactHeight ? 20 : 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _filterTemplates('');
                    },
                    icon: Icon(
                      Icons.clear_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: isCompactHeight ? 18 : 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isCompactHeight ? 12 : 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCount(ColorScheme colorScheme, bool isCompactHeight) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCompactHeight ? 16 : 20,
        vertical: isCompactHeight ? 4 : 8,
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: isCompactHeight ? 16 : 18,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: isCompactHeight ? 6 : 8),
          Text(
            '${_filteredTemplates.length} plantilla${_filteredTemplates.length != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: isCompactHeight ? 12 : 14,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList(ColorScheme colorScheme, Size size, bool isCompactHeight) {
    if (_filteredTemplates.isEmpty) {
      return _buildEmptyState(colorScheme, isCompactHeight);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isCompactHeight ? 12 : 16,
        vertical: isCompactHeight ? 8 : 12,
      ),
      itemCount: _filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = _filteredTemplates[index];
        final animationIndex = index < _slideAnimations.length ? index : _slideAnimations.length - 1;
        
        return SlideTransition(
          position: _slideAnimations[animationIndex],
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.only(bottom: isCompactHeight ? 8 : 12),
            child: _buildTemplateCard(template, colorScheme, size, isCompactHeight, index),
          ),
        );
      },
    );
  }

  Widget _buildTemplateCard(dynamic template, ColorScheme colorScheme, Size size, bool isCompactHeight, int index) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: () => _navigateToSendTemplate(template),
        borderRadius: BorderRadius.circular(16),
        splashColor: colorScheme.primary.withValues(alpha:  0.1),
        highlightColor: colorScheme.primary.withValues(alpha:  0.05),
        child: Container(
          width: size.width,
          padding: EdgeInsets.all(isCompactHeight ? 16 : 20),
          child: Row(
            children: [
              Hero(
                tag: 'template_icon_${template.name}_$index',
                child: Container(
                  padding: EdgeInsets.all(isCompactHeight ? 10 : 12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    size: isCompactHeight ? 20 : 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(width: isCompactHeight ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontSize: isCompactHeight ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isCompactHeight) SizedBox(height: 4),
                    Text(
                      '${template.getFields().length} campo${template.getFields().length != 1 ? 's' : ''} personalizable${template.getFields().length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: isCompactHeight ? 12 : 14,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: isCompactHeight ? 16 : 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, bool isCompactHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.inventory_2_outlined,
            size: isCompactHeight ? 64 : 72,
            color: colorScheme.onSurfaceVariant.withValues(alpha:  0.6),
          ),
          SizedBox(height: isCompactHeight ? 16 : 24),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No se encontraron plantillas'
                : 'No hay plantillas disponibles',
            style: TextStyle(
              fontSize: isCompactHeight ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: isCompactHeight ? 8 : 12),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Intenta con otros términos de búsqueda'
                : 'Crea tu primera plantilla para comenzar',
            style: TextStyle(
              fontSize: isCompactHeight ? 14 : 16,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}