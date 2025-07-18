import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:for_u_partners/ui/common/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:for_u_partners/ui/common/app_text_component.dart';

class TextInputField extends StatefulWidget {
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? label;
  final String? bigLabel;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool obscureText;
  final bool isEmail;
  final Function(String?)? onSaved;
  final Function(String?)? onChanged;
  final String? hintText;
  final String? errorText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? suffixText;
  final bool enabled;
  final AutovalidateMode autovalidate;
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final double contentVert;
  final double contentHoriz;
  final double hintSize;
  final Function()? onTap;

  const TextInputField({
    super.key,
    this.label,
    this.bigLabel,
    this.controller,
    this.validator,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.obscureText = false,
    this.isEmail = false,
    this.onSaved,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.suffixText,
    this.autovalidate = AutovalidateMode.onUserInteraction,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.maxLines = 1,
    this.contentVert = 16.0,
    this.contentHoriz = 12.0,
    this.hintSize = 12.0,
    this.errorText,
  });

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  late FocusNode focusNode;

  @override
  void initState() {
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(
        color: greybutton,
        width: 1.5,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: const BorderSide(
        color: greybutton,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.bigLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextComponent(
              widget.bigLabel!,
              fontsize: 16,
            ),
          ),
        TextFormField(
          cursorColor: primaryColor,
          maxLines: widget.maxLines,
          focusNode: focusNode,
          readOnly: widget.readOnly,
          initialValue: widget.initialValue,
          autofocus: widget.autofocus,
          autovalidateMode: widget.autovalidate,
          obscureText: widget.obscureText,
          inputFormatters: widget.inputFormatters,
          textAlign: widget.height == 75 ? TextAlign.center : TextAlign.start,
          decoration: InputDecoration(
            errorText: widget.errorText,
            border: inputBorder,
            focusedBorder: focusedBorder,
            enabledBorder: inputBorder,
            labelText: widget.label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: widget.hintText ?? (widget.enabled ? null : 'N/A'),
            hintStyle: TextStyle(
              color: textinputcolor.withValues(alpha: 0.5),
              fontSize: widget.hintSize,
            ),
            floatingLabelStyle:
                const TextStyle(color: textinputcolor, fontSize: 17
                    //fontSize: widget.hintSize,
                    ),
            suffixIcon: widget.suffixIcon,
            prefixIcon: widget.prefixIcon,
            suffixIconColor: greybutton,
            contentPadding: EdgeInsets.symmetric(
                vertical: widget.contentVert, horizontal: widget.contentHoriz),
            enabled: widget.enabled,
          ),
          style: TextStyle(
            color: widget.enabled ? Colors.black : Colors.black87,
            fontSize: 13,
          ),
          controller: widget.controller,
          validator: widget.enabled ? widget.validator : null,
          onSaved: widget.onSaved,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
        ),
      ],
    );
  }
}

class CountryPhoneSelector extends StatefulWidget {
  /// Contrôleur pour le champ de texte du numéro de téléphone
  final TextEditingController? controller;

  /// Fonction appelée lorsque la valeur du champ change
  final Function(String)? onChanged;

  /// Fonction appelée lorsqu'un pays est sélectionné
  final Function(CountryInfo)? onCountrySelected;

  /// Texte indicatif du champ
  final String hintText;

  /// Pays initialement sélectionné (code indicatif)
  final String? initialCountryCode;

  /// Permet de personnaliser la largeur maximale du composant
  final double? maxWidth;

  const CountryPhoneSelector({
    super.key,
    this.controller,
    this.onChanged,
    this.onCountrySelected,
    this.hintText = 'Numéro de téléphone',
    this.initialCountryCode,
    this.maxWidth,
  });

  @override
  State<CountryPhoneSelector> createState() => _CountryPhoneSelectorState();
}

class _CountryPhoneSelectorState extends State<CountryPhoneSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final FocusNode _focusNode = FocusNode();
  bool _isDropdownOpen = false;

  // Liste des pays disponibles
  final List<CountryInfo> _countries = [
    CountryInfo(
      name: 'Benin',
      code: '+229',
      flagUrl:
          'https://cdnjs.cloudflare.com/ajax/libs/flag-icon-css/3.5.0/flags/4x3/bj.svg',
    ),
    CountryInfo(
      name: 'Côte d\'Ivoire',
      code: '+225',
      flagUrl:
          'https://cdnjs.cloudflare.com/ajax/libs/flag-icon-css/3.5.0/flags/4x3/ci.svg',
    ),
    CountryInfo(
      name: 'Togo',
      code: '+228',
      flagUrl:
          'https://cdnjs.cloudflare.com/ajax/libs/flag-icon-css/3.5.0/flags/4x3/tg.svg',
    ),
  ];

  late CountryInfo _selectedCountry;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    // Initialisation du contrôleur de texte
    _textController = widget.controller ?? TextEditingController();

    // Sélection du pays initial
    if (widget.initialCountryCode != null) {
      _selectedCountry = _countries.firstWhere(
        (country) => country.code == widget.initialCountryCode,
        orElse: () => _countries[0],
      );
    } else {
      _selectedCountry = _countries[0];
    }

    // Configuration de l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Écouter le changement de focus pour fermer le dropdown
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _isDropdownOpen) {
        _toggleDropdown();
      }
    });
  }

  @override
  void dispose() {
    // Ne pas disposer du contrôleur s'il a été fourni par le widget parent
    if (widget.controller == null) {
      _textController.dispose();
    }
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Gérer l'ouverture/fermeture du dropdown
  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
      if (_isDropdownOpen) {
        _animationController.forward();
        _focusNode.unfocus(); // Masquer le clavier si visible
      } else {
        _animationController.reverse();
      }
    });
  }

  // Sélectionner un pays
  void _selectCountry(CountryInfo country) {
    setState(() {
      _selectedCountry = country;
      _toggleDropdown();

      // Notifier le parent du changement
      if (widget.onCountrySelected != null) {
        widget.onCountrySelected!(country);
      }

      // Focus sur le champ de texte après sélection
      Future.microtask(() => FocusScope.of(context).requestFocus(_focusNode));
    });
  }

  // Widget pour afficher un drapeau avec gestion de SVG
  Widget _buildFlagWidget(String url) {
    // Utilisation d'un widget de repli uniforme
    Widget fallbackWidget = Container(
      width: 24,
      height: 18,
      decoration: BoxDecoration(
        // color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Icon(Icons.flag, size: 14, color: Colors.grey),
    );

    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        width: 24,
        height: 18,
        placeholderBuilder: (BuildContext context) => fallbackWidget,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        width: 24,
        height: 18,
        fit: BoxFit.cover,
        placeholder: (context, url) => fallbackWidget,
        errorWidget: (context, url, error) => fallbackWidget,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextComponent(
            "Numéro de téléphone",
            fontsize: 16,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxWidth: widget.maxWidth ?? 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Champ de saisie avec sélecteur de pays
                Container(
                  height: 62,
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: greybutton),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.05),
                    //     blurRadius: 8,
                    //     offset: const Offset(0, 2),
                    //   ),
                    // ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Sélecteur de pays
                      InkWell(
                        onTap: _toggleDropdown,
                        child: Container(
                          width: 80,
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: const BoxDecoration(
                            // color: white,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(28),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Drapeau du pays sélectionné
                              _buildFlagWidget(_selectedCountry.flagUrl),
                              const SizedBox(width: 8),
                              // Icône de chevron
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _animation.value * 3.14159,
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Champ de texte pour numéro de téléphone
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: TextField(
                            cursorColor: primaryColor,
                            controller: _textController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.phone,
                            onChanged: widget.onChanged,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: widget.hintText,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              hintStyle: TextStyle(
                                color: textinputcolor.withAlpha(128),
                                fontSize: 14,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: textinputcolor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Liste déroulante des pays
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height:
                          _isDropdownOpen ? 180 : 0, // Hauteur fixe plus courte
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isDropdownOpen
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _animation.value,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _countries.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final country = _countries[index];
                              return CountryListItem(
                                country: country,
                                onTap: () => _selectCountry(country),
                                isSelected:
                                    country.code == _selectedCountry.code,
                                buildFlagWidget: _buildFlagWidget,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Élément de la liste déroulante des pays
class CountryListItem extends StatelessWidget {
  final CountryInfo country;
  final VoidCallback onTap;
  final bool isSelected;
  final Widget Function(String) buildFlagWidget;

  const CountryListItem({
    super.key,
    required this.country,
    required this.onTap,
    required this.buildFlagWidget,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: isSelected ? const Color(0xFFF5F7FF) : Colors.transparent,
        child: Row(
          children: [
            // Drapeau du pays
            buildFlagWidget(country.flagUrl),
            const SizedBox(width: 16),
            // Nom du pays
            Expanded(
              child: Text(
                country.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            // Code indicatif du pays
            Text(
              country.code,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Classe pour stocker les informations des pays
class CountryInfo {
  final String name;
  final String code;
  final String flagUrl;

  CountryInfo({
    required this.name,
    required this.code,
    required this.flagUrl,
  });
}
