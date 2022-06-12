import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void main() {
  runApp(const MyApp());
}
int tempCount = 0;
int boxValue = 0;
int lowerLim = 0;
int rowCount = -1;
List<int> rows = [5, 10, 15, 20, 25, 30];
bool wordFound = false;
bool existingWord = true;
List<String> enteredLetters = [];
List<String> textRow1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
List<String> textRow2 = ['A', 'S', 'D', 'F', 'G', 'H',' J', 'K', 'L'];
List<String> textRow3 = ['↵', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'];
List<Color> colorRow1 = [Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30, Colors.white30];
List<Color> colorRow2 = [Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30];
List<Color> colorRow3 = [Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30,Colors.white30];
List<TextEditingController> _controller = List.generate(30, (i) => TextEditingController(text: ""));
List<Color> _colors = List.generate(30,(i) => Colors.transparent);
List<String> allWords = [];
var myWord = "WATER";
bool finished = false;
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black26,
      ),
      home: const MyHomePage(title: 'Wordle'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  getData() async {
    String response;
    response = await rootBundle.loadString('assets/words.txt');
    response = response.replaceAll(" ", "");
    List<String> stringList = response.split("\n");
    stringList.shuffle();
    allWords = stringList;
    myWord = stringList[0].toUpperCase();
  }

  Widget _buildPopupDialog(BuildContext context, String finishedWord, int win) {
    String finalWord = "";
    String result = "";

    for (int i=0; i < finishedWord.length; i++)
    {
      if(i == 0)
      {
        finalWord += finishedWord[i];
      }
      else
      {
        finalWord += finishedWord[i].toLowerCase();
      }
    }

    String titleText = 'The Word was ' + finalWord;

    if(win == 0)
    {
      result = "Congrats! You Guessed Correctly!";
    }
    else if(win == 3)
    {
      result = "Not in word list";
      titleText = "Try Again!";
    }
    else
    {
      result = "Sorry, You ran out of Tries";
    }
    return AlertDialog(
      title: Text(titleText),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  <Widget>[
          Text(result),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          //textColor: Theme.of(context).primaryColor,
          child: const Text('Close'),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    if(wordFound == false)
    {
      wordFound = true;
      getData();
      FocusScope.of(context).nextFocus();
    }
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (RawKeyEvent event)
          {
            if(event is RawKeyDownEvent && finished == false)
            {
              if(boxValue <= lowerLim)
              {
                boxValue = lowerLim;
              }

              if(event.logicalKey.keyLabel == "Backspace")
              {
                _controller[boxValue].text = "";
                boxValue -=1;
                //If Else Statement
                if(boxValue > rowCount)
                  {
                    tempCount = 1;
                  }
                else
                  {
                    tempCount = 0;
                  }

              }
              else if(event.logicalKey.keyLabel.length == 1 && rows.contains(boxValue) == false)
              {
                  if(tempCount != 0)
                  {
                    boxValue += tempCount;
                    tempCount = 0;
                  }
                  _controller[boxValue].text = event.logicalKey.keyLabel;
                  boxValue +=1;
              }
              else if(event.logicalKey.keyLabel == "Enter" && rows.contains(boxValue) == true)
                {
                  List<Color> realColors = List.generate(5,(i) => Colors.transparent);
                  String enteredWord = _controller[boxValue-5].text + _controller[boxValue-4].text + _controller[boxValue-3].text +_controller[boxValue-2].text + _controller[boxValue-1].text;

                  existingWord = false;
                  for(int i =0; i < allWords.length; i++)
                  {
                    if(allWords[i].substring(0,5) == enteredWord.toLowerCase())
                    {
                      existingWord = true;
                    }
                  }

                  //Checks that the word you entered is in the List.
                  if(existingWord == true)
                    {
                      //Win Message
                      if(enteredWord.toString() == myWord.toString().trim().replaceAll(RegExp(r'(\n){3,}'), "\n\n"))
                      {
                        finished = true;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => _buildPopupDialog(context, myWord, 0),
                        );
                      }
                      //Lose Message
                      else if(lowerLim == 25)
                        {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => _buildPopupDialog(context, myWord, 5),
                          );

                        }

                      for(int i = 0; i < 5; i++)
                      {
                        if(enteredWord[i] == myWord[i])
                        {
                          var row1Index = textRow1.indexOf(enteredWord[i]);
                          var row2Index = textRow2.indexOf(enteredWord[i]);
                          var row3Index = textRow3.indexOf(enteredWord[i]);
                          realColors[i] = Colors.green;
                          if(row1Index != -1)
                          {
                            colorRow1[row1Index] = Colors.green;
                          }
                          if(row2Index != -1)
                          {
                            colorRow2[row2Index] = Colors.green;
                          }
                          else if(row3Index != -1)
                          {
                            colorRow3[row3Index] = Colors.green;
                          }
                          enteredLetters.add(enteredWord[i]);

                        }
                        else if(myWord.contains(enteredWord[i]))
                        {
                          realColors[i] = Colors.amber[500]!;
                          var row1Index = textRow1.indexOf(enteredWord[i]);
                          var row2Index = textRow2.indexOf(enteredWord[i]);
                          var row3Index = textRow3.indexOf(enteredWord[i]);
                          if(row1Index != -1 && colorRow1[row1Index] != Colors.green)
                          {
                            colorRow1[row1Index] = Colors.amber[500]!;
                          }
                          if(row2Index != -1 && colorRow2[row2Index] != Colors.green)
                          {
                            colorRow2[row2Index] = Colors.amber[500]!;
                          }
                          else if(row3Index != -1 && colorRow3[row3Index] != Colors.green)
                          {
                            colorRow3[row3Index] = Colors.amber[500]!;
                          }
                          enteredLetters.add(enteredWord[i]);
                        }
                        else
                        {
                          realColors[i] = Colors.white30;
                          var row1Index = textRow1.indexOf(enteredWord[i]);
                          var row2Index = textRow2.indexOf(enteredWord[i]);
                          var row3Index = textRow3.indexOf(enteredWord[i]);
                          if(row1Index != -1 && colorRow1[row1Index] != Colors.green && colorRow1[row1Index] != Colors.amber[500]!)
                          {
                            colorRow1[row1Index] = Colors.white12;
                          }
                          if(row2Index != -1 && colorRow2[row2Index] != Colors.green && colorRow2[row2Index] != Colors.amber[500]!)
                          {
                            colorRow2[row2Index] = Colors.white12;
                          }
                          else if(row3Index != -1 && colorRow3[row3Index] != Colors.green && colorRow3[row3Index] != Colors.amber[500]!)
                          {
                            colorRow3[row3Index] = Colors.white12;
                          }
                          enteredLetters.add(enteredWord[i]);
                        }
                      }

                      setState(() {
                        for (int i = 0; i < 5; i++)
                        {
                          _colors[i+lowerLim] = realColors[i];
                        }
                      });

                      // Stuff to Take Care Of
                      rows.remove(lowerLim + 5);
                      boxValue =  lowerLim + 5;
                      lowerLim += 5;
                      rowCount += 5;
                    }
                  else if(existingWord == false)
                    {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => _buildPopupDialog(context, myWord, 3),
                      );
                    }
                }
            }
          },
        child:  Column(
          children: <Widget> [
            const SizedBox(height: 40),
            const Expanded(
                flex:0,
                //fit: FlexFit.tight,
                //alignment: Alignment.center,
                child:
                Text("Wordle",
                    style: TextStyle(
                      fontFamily: 'Sofiapro',
                      fontSize: 50,
                      color: Colors.white,
                    )
                )
            ),
            Flexible(
              flex:6,
              //alignment: Alignment.centerLeft,
              //fit: FlexFit.tight,
              child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 10/10,
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 2.7, right: MediaQuery.of(context).size.width / 2.7, top: 20, bottom:20),
                  crossAxisCount: 5,
                  crossAxisSpacing: 5.0,
                  children: List.generate(30, (index) {
                    return SizedBox(
                      child: TextField(
                          textInputAction: TextInputAction.next,
                          readOnly:finished,
                          maxLength: 1,
                          maxLines: 1,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                          ],
                          autofocus: false,
                          cursorHeight: 0.0,
                          cursorWidth: 0.0,
                          controller:  _controller[index],
                          style: const TextStyle(
                            fontSize: 25.0,
                            height:1.0,
                            fontFamily: 'Sofiapro',
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            fillColor: _colors[index],
                            filled: true,
                            //contentPadding: const EdgeInsets.all(10.0),
                            focusedBorder:  OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[800]!, width: 2.5),
                            ),
                            enabledBorder:  OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[800]!, width: 2.5),
                            ),
                            hintText: '',
                          ),
                        ),
                      );
                  }
                  )
              ),
            ),

            // Expanded(
            //     flex:0,
            //     //fit: FlexFit.tight,
            //     //alignment: Alignment.topCenter,
            //     child:
            //     TextButton(
            //       onPressed: () {
            //         setState(() {
            //           finished=false;
            //           enteredLetters = [];
            //           _colors = List.generate(25,(i) => Colors.transparent);
            //           _controller = List.generate(25, (i) => TextEditingController());
            //         });
            //       },
            //       child: const Text("Reset",
            //         style: TextStyle(
            //           fontFamily: 'Sofiapro',
            //           fontSize: 20,
            //           color: Colors.white,
            //         ),
            //       ),
            //     )
            // ),

            Flexible(
              flex:1,
              //fit: FlexFit.tight,
              child: GridView.count(
                childAspectRatio: 10/9,
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 3.3, right: MediaQuery.of(context).size.width / 3.3, top: 20),
                crossAxisCount: 10,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 5,
                children: List.generate(10, (index) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        if(boxValue <= lowerLim)
                        {
                            boxValue = lowerLim;
                        }

                        if(rows.contains(boxValue) == false)
                        {
                          if(tempCount != 0)
                          {
                            boxValue += tempCount;
                            tempCount = 0;
                          }
                          _controller[boxValue].text = textRow1[index];
                          boxValue +=1;
                        }
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(colorRow1[index]),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.white30),
                      shadowColor: MaterialStateProperty.all(Colors.white30),
                      animationDuration: const Duration(milliseconds: 10),
                    ),

                    child: Text(textRow1[index],
                      style: const TextStyle(
                        fontFamily: 'Sofiapro',
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                ),
              ),
            ),
            Flexible(
              flex:1,
              //fit: FlexFit.tight,
              child: GridView.count(
                childAspectRatio: 10/9,
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 3.1, right: MediaQuery.of(context).size.width / 3.5, top: 10),
                crossAxisCount: 10,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 5,
                children: List.generate(9, (index) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        if(boxValue <= lowerLim)
                        {
                          boxValue = lowerLim;
                        }

                        if(rows.contains(boxValue) == false)
                        {
                          if(tempCount != 0)
                          {
                            boxValue += tempCount;
                            tempCount = 0;
                          }
                          _controller[boxValue].text = textRow2[index];
                          boxValue +=1;
                        }
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(colorRow2[index]),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.white30),
                      shadowColor: MaterialStateProperty.all(Colors.white30),
                      animationDuration: const Duration(milliseconds: 10),
                    ),
                    child: Text(textRow2[index],
                      style: const TextStyle(
                        fontFamily: 'Sofiapro',
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                ),
              ),
            ),
            Flexible(
              flex:1,
              child: GridView.count(
                childAspectRatio: 10/8,
                padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/3.3, right: MediaQuery.of(context).size.width/3.88),
                crossAxisCount: 10,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 5,
                children: List.generate(9, (index) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        if(boxValue <= lowerLim)
                        {
                          boxValue = lowerLim;
                        }

                        //If it's a Normal Key, Act Normal!
                        if(textRow3[index] != '↵' && textRow3[index] != '⌫')
                        {
                            if(rows.contains(boxValue) == false)
                            {
                              if(tempCount != 0)
                              {
                                boxValue += tempCount;
                                tempCount = 0;
                              }
                              _controller[boxValue].text = textRow3[index];
                              boxValue +=1;
                            }
                        }
                        else if(textRow3[index] == '⌫')
                          {
                              _controller[boxValue].text = "";
                              boxValue -=1;
                              //If Else Statement
                              if(boxValue > rowCount)
                              {
                                tempCount = 1;
                              }
                              else
                              {
                                tempCount = 0;
                              }
                          }
                        else if(textRow3[index] == '↵' && rows.contains(boxValue) == true)
                        {
                          List<Color> realColors = List.generate(5,(i) => Colors.transparent);
                          String enteredWord = _controller[boxValue-5].text + _controller[boxValue-4].text + _controller[boxValue-3].text +_controller[boxValue-2].text + _controller[boxValue-1].text;

                          existingWord = false;
                          for(int i =0; i < allWords.length; i++)
                          {
                            if(allWords[i].substring(0,5) == enteredWord.toLowerCase())
                            {
                              existingWord = true;
                            }
                          }

                          //Checks that the word you entered is in the List.
                          if(existingWord == true)
                          {
                            //Win Message
                            if(enteredWord.toString() == myWord.toString().trim().replaceAll(RegExp(r'(\n){3,}'), "\n\n"))
                            {
                              finished = true;
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => _buildPopupDialog(context, myWord, 0),
                              );
                            }
                            //Lose Message
                            else if(lowerLim == 25)
                            {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => _buildPopupDialog(context, myWord, 5),
                              );

                            }

                            for(int i = 0; i < 5; i++)
                            {
                              if(enteredWord[i] == myWord[i])
                              {
                                var row1Index = textRow1.indexOf(enteredWord[i]);
                                var row2Index = textRow2.indexOf(enteredWord[i]);
                                var row3Index = textRow3.indexOf(enteredWord[i]);
                                realColors[i] = Colors.green;
                                if(row1Index != -1)
                                {
                                  colorRow1[row1Index] = Colors.green;
                                }
                                if(row2Index != -1)
                                {
                                  colorRow2[row2Index] = Colors.green;
                                }
                                else if(row3Index != -1)
                                {
                                  colorRow3[row3Index] = Colors.green;
                                }
                                enteredLetters.add(enteredWord[i]);

                              }
                              else if(myWord.contains(enteredWord[i]))
                              {
                                realColors[i] = Colors.amber[500]!;
                                var row1Index = textRow1.indexOf(enteredWord[i]);
                                var row2Index = textRow2.indexOf(enteredWord[i]);
                                var row3Index = textRow3.indexOf(enteredWord[i]);
                                if(row1Index != -1 && colorRow1[row1Index] != Colors.green)
                                {
                                  colorRow1[row1Index] = Colors.amber[500]!;
                                }
                                if(row2Index != -1 && colorRow2[row2Index] != Colors.green)
                                {
                                  colorRow2[row2Index] = Colors.amber[500]!;
                                }
                                else if(row3Index != -1 && colorRow3[row3Index] != Colors.green)
                                {
                                  colorRow3[row3Index] = Colors.amber[500]!;
                                }
                                enteredLetters.add(enteredWord[i]);
                              }
                              else
                              {
                                realColors[i] = Colors.white30;
                                var row1Index = textRow1.indexOf(enteredWord[i]);
                                var row2Index = textRow2.indexOf(enteredWord[i]);
                                var row3Index = textRow3.indexOf(enteredWord[i]);
                                if(row1Index != -1 && colorRow1[row1Index] != Colors.green && colorRow1[row1Index] != Colors.amber[500]!)
                                {
                                  colorRow1[row1Index] = Colors.white12;
                                }
                                if(row2Index != -1 && colorRow2[row2Index] != Colors.green && colorRow2[row2Index] != Colors.amber[500]!)
                                {
                                  colorRow2[row2Index] = Colors.white12;
                                }
                                else if(row3Index != -1 && colorRow3[row3Index] != Colors.green && colorRow3[row3Index] != Colors.amber[500]!)
                                {
                                  colorRow3[row3Index] = Colors.white12;
                                }
                                enteredLetters.add(enteredWord[i]);
                              }
                            }

                            setState(() {
                              for (int i = 0; i < 5; i++)
                              {
                                _colors[i+lowerLim] = realColors[i];
                              }
                            });

                            // Stuff to Take Care Of
                            rows.remove(lowerLim + 5);
                            boxValue =  lowerLim + 5;
                            lowerLim += 5;
                            rowCount += 5;
                          }
                          else if(existingWord == false)
                          {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => _buildPopupDialog(context, myWord, 3),
                            );
                          }
                        }
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(colorRow3[index]),
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateProperty.all(Colors.white30),
                      shadowColor: MaterialStateProperty.all(Colors.white30),
                      animationDuration: const Duration(milliseconds: 10),
                    ),

                    child: Text(textRow3[index],
                      style: const TextStyle(
                        fontFamily: 'Sofiapro',
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                ),
              ),
            ),

            //SizedBox(height: MediaQuery.of(context).size.height/15),
          ],
        ),

      )

    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

