import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  String cardNumber = '';
  String cardHolder = '';
  String cvv = '';
  String selectedMonth = 'MM';
  String selectedYear = 'YY';
  int minCardYear = DateTime.now().year;
  bool isCardFlipped = false;
  int currentCardBackground = Random().nextInt(25) + 1;
  String cardType = 'mastercard';
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  Rect? focusRect;
  bool isInputFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void flipCard(bool status) {
    setState(() {
      isCardFlipped = status;
      if (status) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  String detectCardType(String number) {
    if (RegExp(r'^4').hasMatch(number)) return 'visa';
    if (RegExp(r'^(34|37)').hasMatch(number)) return 'amex';
    if (RegExp(r'^5[1-5]').hasMatch(number)) return 'mastercard';
    if (RegExp(r'^6011').hasMatch(number)) return 'discover';
    if (RegExp(r'^9792').hasMatch(number)) return 'troy';
    return 'mastercard';
  }

  String formatCardNumber(String input) {
    String digits = input.replaceAll(' ', '');
    if (cardType == 'amex') {
      return digits
          .replaceAllMapped(
            RegExp(r'(.{4})(.{6})(.{0,5})'),
            (m) => '${m[1]}  ${m[2]}  ${m[3]}',
          )
          .trim();
    } else {
      return digits
          .replaceAllMapped(RegExp(r'(.{4})'), (m) => '${m[1]}    ')
          .trim();
    }
  }

  String _buildCardNumberDisplay(String input) {
    String digits = input.replaceAll(' ', '');
    String placeholder = '################'; // 16 tecken
    String combined = digits + placeholder.substring(digits.length);

    // Maskera mitten 8 siffror
    List<String> chars = combined.split('');
    for (int i = 4; i < 12; i++) {
      if (chars[i] != '#') {
        chars[i] = '*';
      }
    }

    return chars
        .join()
        .replaceAllMapped(RegExp(r'(.{4})'), (m) => '${m[1]}    ')
        .trim();
  }

  void updateFocus(
    BuildContext context,
    GlobalKey key, {
    bool flipBack = false,
  }) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      setState(() {
        focusRect = Rect.fromLTWH(
          position.dx,
          position.dy,
          renderBox.size.width,
          renderBox.size.height,
        );
        isInputFocused = true;
        if (flipBack && isCardFlipped) flipCard(false);
      });
    }
  }

  void clearFocus() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (!isInputFocused) {
        setState(() {
          focusRect = null;
        });
      }
    });
    isInputFocused = false;
  }

  final cardNumberKey = GlobalKey();
  final cardHolderKey = GlobalKey();
  final cvvKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'OpenSans'),
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 224, 241, 255),
        body: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              left: focusRect?.left ?? -1000,
              top: focusRect?.top ?? -1000,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: focusRect?.width ?? 0,
                height: focusRect?.height ?? 0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Card(
                      elevation: 5,
                      color: Colors.white,
                      child: Container(
                        width: 570,
                        height: 557,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 5,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 220),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text("Card Number"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: TextField(
                                    key: cardNumberKey,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                        cardType == 'amex' ? 15 : 16,
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        cardType = detectCardType(value);
                                        cardNumber = formatCardNumber(value);
                                      });
                                    },
                                    onTap: () => updateFocus(
                                      context,
                                      cardNumberKey,
                                      flipBack: true,
                                    ),
                                    onEditingComplete: clearFocus,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text("Card Holder"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: TextField(
                                    key: cardHolderKey,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        cardHolder = value.toUpperCase();
                                      });
                                    },
                                    onTap: () => updateFocus(
                                      context,
                                      cardHolderKey,
                                      flipBack: true,
                                    ),
                                    onEditingComplete: clearFocus,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text("Expiration date"),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child:
                                                DropdownButtonFormField<String>(
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                        ),
                                                  ),
                                                  value: selectedMonth,
                                                  items: [
                                                    DropdownMenuItem(
                                                      value: "MM",
                                                      child: Text("Month"),
                                                      enabled: false,
                                                    ),
                                                    ...List.generate(12, (
                                                      index,
                                                    ) {
                                                      String val = (index + 1)
                                                          .toString()
                                                          .padLeft(2, '0');
                                                      return DropdownMenuItem(
                                                        value: val,
                                                        child: Text(val),
                                                      );
                                                    }),
                                                  ],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedMonth = value!;
                                                      if (isCardFlipped)
                                                        flipCard(false);
                                                    });
                                                  },
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text(""),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child:
                                                DropdownButtonFormField<String>(
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                        ),
                                                  ),
                                                  value: selectedYear,
                                                  items: [
                                                    DropdownMenuItem(
                                                      value: "YY",
                                                      child: Text("Year"),
                                                      enabled: false,
                                                    ),
                                                    ...List.generate(12, (
                                                      index,
                                                    ) {
                                                      String val =
                                                          (minCardYear + index)
                                                              .toString()
                                                              .substring(2);
                                                      return DropdownMenuItem(
                                                        value: val,
                                                        child: Text(val),
                                                      );
                                                    }),
                                                  ],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedYear = value!;
                                                      if (isCardFlipped)
                                                        flipCard(false);
                                                    });
                                                  },
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: Text("CVV"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: TextField(
                                              key: cvvKey,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                  4,
                                                ),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  cvv = value;
                                                });
                                              },
                                              onTap: () {
                                                updateFocus(context, cvvKey);
                                                flipCard(true);
                                              },
                                              onEditingComplete: () {
                                                clearFocus();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10.0,
                                      top: 20,
                                    ),
                                    child: SizedBox(
                                      width: 570 - 2 * 20,
                                      height: 50,
                                      child: FloatingActionButton(
                                        onPressed: () {},
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFF2364D2,
                                        ),
                                        child: Text(
                                          "Submit",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            bool showBack = _flipAnimation.value > pi / 2;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..rotateY(_flipAnimation.value),
                              child: AnimatedOpacity(
                                opacity: 1,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  height: 270,
                                  width: 430,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: AssetImage(
                                        "../images/${currentCardBackground}.jpeg",
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Mörk overlay
                                      Container(
                                        height: 270,
                                        width: 430,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(
                                            0.4,
                                          ), // justera opacitet
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),

                                      // Innehåll (front/back)
                                      if (showBack)
                                        Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.identity()
                                            ..rotateY(pi),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 30,
                                                ),
                                                child: Container(
                                                  height: 45,
                                                  width: 500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 30),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 30,
                                                      ),
                                                  child: Text(
                                                    "CVV",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 1),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: Container(
                                                  width: 400,
                                                  height: 40,
                                                  alignment:
                                                      Alignment.centerRight,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    cvv.isEmpty
                                                        ? "***"
                                                        : "*" * cvv.length,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 35,
                                                  right: 20,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Image.asset(
                                                    "../images/CardCompanyLogos/${cardType}.png",
                                                    height: 40,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Image.asset(
                                                    "../images/chip.png",
                                                    height: 40,
                                                  ),
                                                  Image.asset(
                                                    "../images/CardCompanyLogos/${cardType}.png",
                                                    height: 40,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 70),
                                              Text(
                                                _buildCardNumberDisplay(
                                                  cardNumber,
                                                ),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                              SizedBox(height: 40),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'CARD HOLDER',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                        255,
                                                        230,
                                                        229,
                                                        229,
                                                      ),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Expires',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                        255,
                                                        230,
                                                        229,
                                                        229,
                                                      ),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    cardHolder.isEmpty
                                                        ? 'CARD HOLDER'
                                                        : cardHolder,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${selectedMonth}/${selectedYear}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
