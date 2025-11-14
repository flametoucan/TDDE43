import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 224, 241, 255),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Card(
                elevation: 5,
                color: Colors.black,
                child: Container(
                  width: 490,
                  height: 557,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment(0, -1),
                child: Frontsidecard(),
                //BacksideCard(), har inte implementerat den än
              ),
            ],
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
