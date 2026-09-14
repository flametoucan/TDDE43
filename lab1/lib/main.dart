import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'OpenSans', useMaterial3: true),
      home: const CreditCardFormScreen(),
    );
  }
}

class CreditCardFormScreen extends StatefulWidget {
  const CreditCardFormScreen({super.key});

  @override
  State<CreditCardFormScreen> createState() => _CreditCardFormScreenState();
}

/// Automatically adds a space after every 4th digit in the input field
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip non-digit characters
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      final nonZeroIndex = i + 1;
      // Append a space every 4 digits, unless it's the end of the text
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != newText.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _CreditCardFormScreenState extends State<CreditCardFormScreen>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // CONTROLLERS & KEYS
  // ---------------------------------------------------------------------------
  // Controllers manage text state cleanly without requiring manually synchronized strings.
  final _numberController = TextEditingController();
  final _holderController = TextEditingController();
  final _cvvController = TextEditingController();

  // GlobalKeys are used to locate the rendered bounding boxes of specific input
  // fields so we can draw the dynamic blue focus border around them.
  final _numberKey = GlobalKey();
  final _holderKey = GlobalKey();
  final _cvvKey = GlobalKey();

  // ---------------------------------------------------------------------------
  // CARD DATA STATE
  // ---------------------------------------------------------------------------
  String _cardNumber = '';
  String _cardHolder = '';
  String _cvv = '';
  String _selectedMonth = 'MM';
  String _selectedYear = 'YY';
  String _cardType = 'mastercard'; // Default card network brand
  final int _minCardYear = DateTime.now().year;

  // ---------------------------------------------------------------------------
  // ANIMATION & VISUAL STATE
  // ---------------------------------------------------------------------------
  bool _isCardFlipped = false;
  late final int _bgIndex; // Stores random background image selection
  Rect? _focusRect;       // Holds exact pixel coordinates of active focus box

  late final AnimationController _controller;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    // Select a random card background index between 1 and 25 upon initialization
    _bgIndex = Random().nextInt(25) + 1;

    // Set up 3D card rotation controller (500ms duration)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Map animation progression from 0 to Pi radians (0 to 180 degrees rotation)
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // Always dispose controllers when the widget unmounts to prevent memory leaks
    _numberController.dispose();
    _holderController.dispose();
    _cvvController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOGIC & HELPER METHODS
  // ---------------------------------------------------------------------------

  /// Triggers the 3D flip animation between front and back views
  void _flipCard(bool showBack) {
    if (_isCardFlipped == showBack) return; // Prevent unnecessary duplicate triggers
    setState(() => _isCardFlipped = showBack);
    showBack ? _controller.forward() : _controller.reverse();
  }

  /// Identifies card provider based on standard prefix numbers (IIN/BIN numbers)
  String _detectCardType(String number) {
    if (RegExp(r'^4').hasMatch(number)) return 'visa';
    if (RegExp(r'^(34|37)').hasMatch(number)) return 'amex';
    if (RegExp(r'^5[1-5]').hasMatch(number)) return 'mastercard';
    if (RegExp(r'^6011').hasMatch(number)) return 'discover';
    if (RegExp(r'^9792').hasMatch(number)) return 'troy';
    return 'mastercard';
  }

  /// Formats raw numerical digits into spaced card groups depending on card type
  String _formatCardNumber(String input) {
    final digits = input.replaceAll(' ', '');
    
    // American Express uses a 4-6-5 digit grouping structure
    if (_cardType == 'amex') {
      return digits.replaceAllMapped(
        RegExp(r'(.{4})(.{6})?(.{0,5})?'),
        (m) => [m[1], m[2], m[3]].where((s) => s != null).join('  '),
      ).trim();
    }
    
    // Standard cards use 4-4-4-4 digit grouping
    return digits.replaceAllMapped(
      RegExp(r'(.{4})'),
      (m) => '${m[1]}    ',
    ).trim();
  }

  /// Formats card digits onto the visual preview card with mask asterisks (*)
  String _buildCardNumberDisplay(String input) {
    final digits = input.replaceAll(' ', '');
    const defaultMask = '################';
    
    // Safe substring calculation to prevent StringIndexOutOfBoundsException
    final padded = (digits + defaultMask).substring(0, max(16, digits.length));
    final chars = padded.split('');

    // Mask digits 5 through 12 with '*' for security standard visualization
    for (int i = 4; i < min(12, chars.length); i++) {
      if (chars[i] != '#') chars[i] = '*';
    }

    // Return masked card number split into 4-character visual blocks
    return chars.join().replaceAllMapped(
      RegExp(r'(.{4})'),
      (m) => '${m[1]}   ',
    ).trim();
  }

  /// Calculates the target field's location on screen after layout completion
  void _updateFocus(GlobalKey key, {bool flipBack = false}) {
    // PostFrameCallback ensures render boxes have updated sizes before reading positions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        setState(() {
          _focusRect = Rect.fromLTWH(
            position.dx,
            position.dy,
            renderBox.size.width,
            renderBox.size.height,
          );
        });
        if (flipBack) _flipCard(false);
      }
    });
  }

  /// Clears active field selection outline
  void _clearFocus() {
    setState(() => _focusRect = null);
  }

  

  // ---------------------------------------------------------------------------
  // MAIN UI BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F1FF),
      body: Stack(
        children: [
          // Dynamic animated border highlight that slides to focused input
          _buildFocusHighlight(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 120, bottom: 40),
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  _buildFormCard(),
                  Positioned(
                    top: -100, // Positions card so it overlays top portion of form container
                    child: _buildAnimatedCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders animated border box following active field state
  Widget _buildFocusHighlight() {
    if (_focusRect == null) return const SizedBox.shrink();
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _focusRect!.left,
      top: _focusRect!.top,
      width: _focusRect!.width,
      height: _focusRect!.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Main white background card containing user input form fields
  Widget _buildFormCard() {
    return Container(
      width: 570,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(24, 180, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(
  label: "Card Number",
  key: _numberKey,
  controller: _numberController,
  keyboardType: TextInputType.number,
  formatters: [
    FilteringTextInputFormatter.digitsOnly,
    CardNumberInputFormatter(), // <-- Added custom space formatter
    LengthLimitingTextInputFormatter(_cardType == 'amex' ? 18 : 19), // Account for spaces
  ],
  onChanged: (val) {
    setState(() {
      _cardType = _detectCardType(val);
      _cardNumber = _formatCardNumber(val);
    });
  },
  onTap: () => _updateFocus(_numberKey, flipBack: true),
),
          const SizedBox(height: 12),
          _buildTextField(
            label: "Card Holder",
            key: _holderKey,
            controller: _holderController,
            onChanged: (val) => setState(() => _cardHolder = val.toUpperCase()),
            onTap: () => _updateFocus(_holderKey, flipBack: true),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildDateDropdowns()),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildTextField(
                  label: "CVV",
                  key: _cvvKey,
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (val) => setState(() => _cvv = val),
                  onTap: () {
                    _updateFocus(_cvvKey);
                    _flipCard(true); // Automatically flip card to reveal back when typing CVV
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2364D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds row containing Month and Year expiration selection dropdowns
  Widget _buildDateDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Expiration Date", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: _selectedMonth,
                items: [
                  const DropdownMenuItem(value: "MM", enabled: false, child: Text("Month")),
                  ...List.generate(12, (i) {
                    final val = (i + 1).toString().padLeft(2, '0');
                    return DropdownMenuItem(value: val, child: Text(val));
                  }),
                ],
                onChanged: (val) {
                  setState(() => _selectedMonth = val!);
                  _flipCard(false);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDropdown(
                value: _selectedYear,
                items: [
                  const DropdownMenuItem(value: "YY", enabled: false, child: Text("Year")),
                  ...List.generate(12, (i) {
                    final val = (_minCardYear + i).toString().substring(2);
                    return DropdownMenuItem(value: val, child: Text(val));
                  }),
                ],
                onChanged: (val) {
                  setState(() => _selectedYear = val!);
                  _flipCard(false);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Reusable UI builder for stylized text input fields
  Widget _buildTextField({
    required String label,
    required GlobalKey key,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    required ValueChanged<String> onChanged,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          key: key,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          onChanged: onChanged,
          onTap: onTap,
          onEditingComplete: _clearFocus,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  /// Reusable UI builder for dropdown input controls
  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CREDIT CARD VISUAL PREVIEW WIDGETS
  // ---------------------------------------------------------------------------

  /// Handles 3D animation perspective transformation and image background rendering
  Widget _buildAnimatedCard() {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        // Halfway through rotation angle (> 90 degrees / Pi/2), switch between front/back layout
        final isBackVisible = _flipAnimation.value > (pi / 2);
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Adds realistic perspective depth to the 3D flip effect
            ..rotateY(_flipAnimation.value),
          child: Container(
            height: 250,
            width: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
              image: DecorationImage(
                image: AssetImage("../images/$_bgIndex.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              // Dark overlay tint for visual contrast over dynamic background images
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(15),
              ),
              child: isBackVisible ? _buildCardBack() : _buildCardFront(),
            ),
          ),
        );
      },
    );
  }

  /// Layout for front side of visual credit card
  Widget _buildCardFront() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset("../images/chip.png", height: 36, errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, color: Colors.white)),
              Image.asset("../images/CardCompanyLogos/$_cardType.png", height: 36, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ],
          ),
          Text(
            _buildCardNumberDisplay(_cardNumber),
            style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2, fontFamily: 'monospace'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardLabelValue("CARD HOLDER", _cardHolder.isEmpty ? "FULL NAME" : _cardHolder),
              _buildCardLabelValue("EXPIRES", "$_selectedMonth/$_selectedYear"),
            ],
          ),
        ],
      ),
    );
  }

  /// Layout for back side of visual credit card (includes magnetic strip and CVV display)
  Widget _buildCardBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi), // Re-mirrors content so text is readable upright
      child: Column(
        children: [
          const SizedBox(height: 25),
          Container(height: 40, color: Colors.black), // Black magnetic stripe
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("CVV", style: TextStyle(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 38,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    _cvv.isEmpty ? "***" : "*" * _cvv.length,
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Image.asset("../images/CardCompanyLogos/$_cardType.png", height: 36, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable helper for card text blocks (e.g. Card Holder and Expiration labels/values)
  Widget _buildCardLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
