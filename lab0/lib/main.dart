import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Example 1", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
        body: Column(
          children: [
<<<<<<< HEAD
            Image.asset('images/BILD.png'),
=======
            Image.asset(
              'images/Imagelab0TDDE43.png',
            ),

>>>>>>> 27af92312f387b40028b014053a36e69ed94aa39
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.2,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 80,
                  childAspectRatio: 4,
                  crossAxisCount: 2,
                  mainAxisSpacing: 30,
                ),
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, index) {
                  return FloatingActionButton(
                    onPressed: () {
                      print('pressed');
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    backgroundColor: Colors.grey,
                    child: Text(
                      "BUTTON",
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 150),
                  child: Text("Email", style: TextStyle(color: Colors.black)),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: Expanded(
                    child: TextField(
                      cursorColor: Colors.red,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      );
  }
}
