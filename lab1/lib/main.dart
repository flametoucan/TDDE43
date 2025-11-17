import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

const double TextFieldSpacingHorisontal = 20;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String selectedMonth = "Month";
  String selectedYear = "Year";
  TextEditingController cardNumberController = TextEditingController();
  String cardNumber = "";
  TextEditingController cardHolderController = TextEditingController();
  String cardHolder = "";
  TextEditingController cvvController = TextEditingController();
  String cvv = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 224, 241, 255),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Card(
                  clipBehavior: Clip.none,
                  elevation: 5,
                  color: Colors.black,
                  child: Container(
                    width: 570,
                    height: 557,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 220),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: TextFieldSpacingHorisontal,
                              ),
                              child: Text("Card Number"),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TextFieldSpacingHorisontal,
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 231, 231, 231),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                                controller: cardNumberController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(16),
                                  CardNumberInputFormatter(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    cardNumber = value;
                                  });
                                },
                              ),
                            ),

                            SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: TextFieldSpacingHorisontal,
                              ),
                              child: Text("Card Holders"),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TextFieldSpacingHorisontal,
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 231, 231, 231),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                                controller: cardHolderController,
                                onChanged: (value) {
                                  setState(() {
                                    cardHolder = value;
                                  });
                                },
                              ),
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: TextFieldSpacingHorisontal,
                                        ),
                                        child: Text("Expiration date"),
                                      ),
                                      SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              TextFieldSpacingHorisontal,
                                        ),
                                        child: SizedBox(
                                          height:
                                              50, // give the TextField a height
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              hoverColor: Colors.blue,
                                              canvasColor: Colors
                                                  .white, // dropdown background
                                            ),
                                            child: DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                              ),
                                              value: selectedMonth,
                                              items: [
                                                DropdownMenuItem(
                                                  value: "Month",
                                                  child: Text("Month"),
                                                  enabled:
                                                      false, // prevents selection
                                                ),
                                                DropdownMenuItem(
                                                  value: "01",
                                                  child: Text("January"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "02",
                                                  child: Text("February"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "03",
                                                  child: Text("March"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "04",
                                                  child: Text("April"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "05",
                                                  child: Text("May"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "06",
                                                  child: Text("June"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "07",
                                                  child: Text("July"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "08",
                                                  child: Text("August"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "09",
                                                  child: Text("September"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "10",
                                                  child: Text("October"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "11",
                                                  child: Text("November"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "12",
                                                  child: Text("December"),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != "Month") {
                                                  setState(() {
                                                    selectedMonth = value!;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
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
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: TextFieldSpacingHorisontal,
                                        ),
                                        child: Text(""),
                                      ),
                                      SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              TextFieldSpacingHorisontal,
                                        ),
                                        child: SizedBox(
                                          height: 50,
                                          child: Theme(
                                            data: Theme.of(context).copyWith(
                                              hoverColor: Colors.blue,
                                              canvasColor: Colors
                                                  .white, // dropdown background
                                            ),
                                            child: DropdownButtonFormField<String>(
                                              value: selectedYear,
                                              isExpanded:
                                                  true, // expand to full width
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                              ),
                                              items: [
                                                DropdownMenuItem(
                                                  value: "Year",
                                                  child: Text("Year"),
                                                  enabled:
                                                      false, // prevents selection
                                                ),
                                                DropdownMenuItem(
                                                  value: "2025",
                                                  child: Text("2025"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2026",
                                                  child: Text("2026"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2027",
                                                  child: Text("2027"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2028",
                                                  child: Text("2028"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2029",
                                                  child: Text("2029"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2030",
                                                  child: Text("2030"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2031",
                                                  child: Text("2031"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2032",
                                                  child: Text("2032"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2033",
                                                  child: Text("2033"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2034",
                                                  child: Text("2034"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2035",
                                                  child: Text("2035"),
                                                ),
                                                DropdownMenuItem(
                                                  value: "2036",
                                                  child: Text("2036"),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedYear = value!;
                                                });
                                              },
                                            ),
                                          ),
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
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: TextFieldSpacingHorisontal,
                                        ),
                                        child: Text("CVV"),
                                      ),
                                      SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              TextFieldSpacingHorisontal,
                                        ),
                                        child: SizedBox(
                                          height:
                                              50, // give the TextField a height
                                          child: TextField(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color.fromRGBO(
                                                    118,
                                                    118,
                                                    118,
                                                    1,
                                                  ),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                            controller: cvvController,
                                            keyboardType: TextInputType.number,
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
                                          ),
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
                                  width: 570 - 2 * TextFieldSpacingHorisontal,
                                  height: 50,

                                  child: FloatingActionButton(
                                    onPressed: () {
                                      print('Card submitted');
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),

                                    backgroundColor: const Color(0xFF2364D2),
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
                  child: Center(child: Frontsidecard()),
                  //BacksideCard(), har inte implementerat den än
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Frontsidecard extends StatefulWidget {
  const Frontsidecard({super.key});

  @override
  State<Frontsidecard> createState() => _FrontsidecardState();
}

class _FrontsidecardState extends State<Frontsidecard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      width: 430,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage("../images/6.jpeg"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class BacksideCard extends StatefulWidget {
  const BacksideCard({super.key});

  @override
  State<BacksideCard> createState() => _BacksideCardState();
}

class _BacksideCardState extends State<BacksideCard> {
  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(-1.0, 1.0), // flip horizontally
      child: Container(
        height: 270,
        width: 430,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage("../images/6.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

//Adds a space after every 4th int.
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Ta bort alla mellanslag först
    String digitsOnly = newValue.text.replaceAll(' ', '');

    // Dela upp i grupper om 4
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i + 1) % 4 == 0 && i != digitsOnly.length - 1) {
        buffer.write(' '); // lägg till mellanslag efter varje 4:e tecken
      }
    }

    // Behåll caret-positionen på rätt ställe
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
