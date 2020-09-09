import 'package:calculator/constants.dart';
import 'package:flutter/material.dart';
import 'package:catex/catex.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:function_tree/function_tree.dart';
import 'dart:math';

enum Mode { original, equation }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => MainPage(),
      },
    );
  }
}

class DrawerButton extends StatelessWidget {
  DrawerButton({this.onPressed, this.text});
  final String text;
  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      focusColor: grey,
      highlightedBorderColor: grey,
      borderSide: BorderSide(
        color: Colors.white,
      ),
      color: orange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle.copyWith(color: Colors.white, fontSize: 15),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Mode mode = Mode.original;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: Text(
          "Calculator",
          style: textStyle.copyWith(color: white),
        ),
      ),
      body: Container(
        color: grey,
        child: Row(
          children: [
            Container(
              color: orange,
              width: 150,
              child: ListView(
                padding: EdgeInsets.all(15),
                children: [
                  DrawerButton(
                    text: "Original",
                    onPressed: () {
                      setState(() {
                        mode = Mode.original;
                      });
                    },
                  ),
                  // DrawerButton(
                  //   text: "Equation",
                  //   onPressed: () {
                  //     setState(() {
                  //       mode = Mode.equation;
                  //     });
                  //   },
                  // )
                ],
              ),
            ),
            Calculator(mode: mode),
          ],
        ),
      ),
    );
  }
}

class Calculator extends StatelessWidget {
  Calculator({this.mode});
  final Mode mode;

  @override
  Widget build(BuildContext context) {
    if (mode == Mode.original) {
      return OriginalCalculator();
    } else if (mode == Mode.equation) {
      return EquationCalculator();
    } else {
      return Container();
    }
  }
}

class CalculatorDisplay extends StatelessWidget {
  CalculatorDisplay({@required this.text, @required this.index});
  final String text;
  final int index;
  @override
  Widget build(BuildContext context) {
    RegExp exp = RegExp(
      r'\^\(\S*\)',
      caseSensitive: false,
    );
    RegExp exp2 = RegExp(
      r'sqrt\(\S*\)',
      caseSensitive: false,
    );
    String toDisplay = text;
    if (toDisplay.endsWith("^")) {
      toDisplay = toDisplay.substring(0, toDisplay.length - 1);
    }
    toDisplay += " ";
    if (toDisplay.contains(
      exp,
    )) {
      toDisplay = toDisplay.replaceAllMapped(exp, (match) {
        print(match.input + "  - regex");
        String newString;
        newString = "^{" +
            match.input.substring(
                match.input.indexOf("(") + 1, match.input.length - 2) +
            "}";
        print(newString + "  - new");
        return newString;
      });
    }
    if (toDisplay.contains(
      exp2,
    )) {
      toDisplay = toDisplay.replaceAllMapped(exp2, (match) {
        // print(match.input + "  - regex");
        String newString;
        newString =
            "\\sqrt{" + match.input.substring(5, match.input.length - 2) + "}";
        // print(newString + "  - new");
        return newString;
      });
    }
    toDisplay = StringUtils.addCharAtPosition(toDisplay, r'|', index);
    // print(toDisplay);
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: white),
      ),
      child: Stack(
        children: [
          Center(
            child: DefaultTextStyle.merge(
                child: CaTeX(
                  "$toDisplay",
                ),
                style: textStyle.copyWith(fontSize: 25, color: white)),
          ),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text(
                      text,
                      style: textStyle.copyWith(color: white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OriginalCalculator extends StatefulWidget {
  @override
  _OriginalCalculatorState createState() => _OriginalCalculatorState();
}

class _OriginalCalculatorState extends State<OriginalCalculator> {
  String state = "";
  Parser parser = Parser();
  ContextModel cm = ContextModel();
  bool justAnswered = false;
  int index = 0;
  void buttonPress(String x) {
    if (justAnswered) {
      // print("1");
      if ([
        "+",
        "-",
        "*",
        "/",
        "^",
      ].contains(x)) {
        // print("2");
        setState(() {
          state += x;
          index = state.length;
        });
      } else {
        // print("3");
        setState(() {
          state = x;
          index = state.length;
        });
      }

      justAnswered = false;
    } else {
      if (index == state.length) {
        // print("4");
        setState(() {
          state += x;
        });
      } else {
        setState(() {
          state = StringUtils.addCharAtPosition(state, x, index);
        });
      }
      setState(() {
        index++;
      });
    }
  }

  void calculate() {
    RegExp exp2 = RegExp(
      r'sqrt\(\S*\)',
      caseSensitive: false,
    );
    if (state.contains(
      exp2,
    )) {
      state = state.replaceAllMapped(exp2, (match) {
        // print(match.input + "  - regex");
        String newString;
        // print(match.input.substring(5, match.input.length - 1));
        try {
          newString = "(" +
              sqrt(double.parse(
                      match.input.substring(5, match.input.length - 1)))
                  .toString() +
              ")";
        } catch (e) {
          newString = "(" +
              sqrt(int.parse(match.input.substring(5, match.input.length - 1)))
                  .toString() +
              ")";
        }
        // print(newString + "  - new");
        return newString;
      });
    }
    for (var x = 0; x < state.length; x++) {
      try {
        if (!["*", "+", "-", "/", "^"].contains(state[x]) &&
            state[x + 1] == "(") {
          state = state.replaceFirst('${state[x]}(', '${state[x]}*(');
        }
      } catch (e) {}
    }
    if (state.contains("π")) {
      state = state.replaceAll("π", "(pi)");
    }
    setState(() {
      state = state.interpret().toString();
      index = state.length;
      justAnswered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 150,
      // child: RawKeyboardListener(
      //   onKey: (key) {
      //     print(key.toString());
      //     if (["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
      //         .contains(key.character)) {
      //       buttonPress(key.character);
      //     }
      //   },
      //   focusNode: FocusNode(
      //       canRequestFocus: true,
      //       onKey: (key, event) {
      //         print("hi");
      //         return true;
      //       }),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        child: Column(
          children: [
            CalculatorDisplay(
              index: index,
              text: state,
            ),
            SizedBox(
              height: 35,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Text("1"),
                        callback: () {
                          buttonPress("1");
                        },
                      ),
                      CalcButton(
                        child: Text("4"),
                        callback: () {
                          buttonPress("4");
                        },
                      ),
                      CalcButton(
                        child: Text("7"),
                        callback: () {
                          buttonPress("7");
                        },
                      ),
                      CalcButton(
                        child: Text("0"),
                        callback: () {
                          buttonPress("0");
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Text("2"),
                        callback: () {
                          buttonPress("2");
                        },
                      ),
                      CalcButton(
                        child: Text("5"),
                        callback: () {
                          buttonPress("5");
                        },
                      ),
                      CalcButton(
                        child: Text("8"),
                        callback: () {
                          buttonPress("8");
                        },
                      ),
                      CalcButton(
                        child: Text("."),
                        callback: () {
                          buttonPress(".");
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Text("3"),
                        callback: () {
                          buttonPress("3");
                        },
                      ),
                      CalcButton(
                        child: Text("6"),
                        callback: () {
                          buttonPress("6");
                        },
                      ),
                      CalcButton(
                        child: Text("9"),
                        callback: () {
                          buttonPress("9");
                        },
                      ),
                      CalcButton(
                        child: Text("C"),
                        callback: () {
                          setState(() {
                            state = "";
                            index = 0;
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Text("+"),
                        callback: () {
                          buttonPress("+");
                        },
                      ),
                      CalcButton(
                        child: Text("-"),
                        callback: () {
                          buttonPress("-");
                        },
                      ),
                      CalcButton(
                        child: Text("x"),
                        callback: () {
                          buttonPress("*");
                        },
                      ),
                      CalcButton(
                        child: Text("÷"),
                        callback: () {
                          buttonPress("/");
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Icon(
                          Icons.backspace,
                          color: white,
                        ),
                        callback: () {
                          if (index != 0) {
                            setState(() {
                              state = state.substring(0, state.length - 1);
                              index--;
                            });
                          }
                        },
                      ),
                      // CalcButton(
                      //   child: CaTeX("y^x"),
                      //   callback: () {},
                      // ),
                      CalcButton(
                        child: Text("("),
                        callback: () {
                          buttonPress("(");
                        },
                      ),
                      CalcButton(
                        child: Text(")"),
                        callback: () {
                          buttonPress(")");
                        },
                      ),
                      CalcButton(
                        child: Text("="),
                        callback: () {
                          calculate();
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CalcButton(
                        child: Icon(Icons.arrow_right, color: white),
                        callback: () {
                          setState(() {
                            if (index < state.length) {
                              index++;
                            }
                          });
                        },
                      ),
                      CalcButton(
                        child: Icon(Icons.arrow_left, color: white),
                        callback: () {
                          setState(() {
                            if (index > 0) {
                              index--;
                            }
                          });
                        },
                      ),
                      CalcButton(
                        callback: () {
                          buttonPress("^()");
                          setState(() {
                            index++;
                          });
                        },
                        child: Text("^"),
                      ),
                      CalcButton(
                        callback: () {
                          buttonPress("π");
                        },
                        child: Text("π"),
                      ),
                      // CalcButton(
                      //   callback: () {
                      //     buttonPress("sqrt()");
                      //     setState(() {
                      //       index += 4;
                      //     });
                      //   },
                      //   child: CaTeX("\\sqrt{x}"),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalcButton extends StatelessWidget {
  CalcButton({
    @required this.callback,
    @required this.child,
  });

  final Function() callback;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: callback,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: DefaultTextStyle(
          child: child,
          style: textStyle.copyWith(color: white, fontSize: 30),
        ),
      ),
      color: orange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}

class EquationCalculator extends StatefulWidget {
  @override
  _EquationCalculatorState createState() => _EquationCalculatorState();
}

class _EquationCalculatorState extends State<EquationCalculator> {
  String state = "";
  Parser parser = Parser();
  ContextModel cm = ContextModel();
  bool justAnswered = false;
  int index = 0;
  void buttonPress(String x) {
    if (justAnswered) {
      // print("1");
      if ([
        "+",
        "-",
        "*",
        "/",
      ].contains(x)) {
        // print("2");
        setState(() {
          state += x;
          index = state.length - 1;
        });
      } else {
        // print("3");
        setState(() {
          state = x;
          index = state.length - 1;
        });
      }

      justAnswered = false;
    } else {
      if (index == state.length) {
        // print("4");
        setState(() {
          state += x;
        });
      } else {
        setState(() {
          state = StringUtils.addCharAtPosition(state, x, index);
        });
      }
      setState(() {
        index++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 150,
      // child: RawKeyboardListener(
      //   onKey: (key) {
      //     print(key.toString());
      //     if (["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
      //         .contains(key.character)) {
      //       buttonPress(key.character);
      //     }
      //   },
      //   focusNode: FocusNode(
      //       canRequestFocus: true,
      //       onKey: (key, event) {
      //         print("hi");
      //         return true;
      //       }),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
        child: Column(
          children: [
            CalculatorDisplay(
              index: index,
              text: state,
            ),
            SizedBox(
              height: 35,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Text("1"),
                        callback: () {
                          buttonPress("1");
                        },
                      ),
                      CalcButton(
                        child: Text("4"),
                        callback: () {
                          buttonPress("4");
                        },
                      ),
                      CalcButton(
                        child: Text("7"),
                        callback: () {
                          buttonPress("7");
                        },
                      ),
                      CalcButton(
                        child: Text("0"),
                        callback: () {
                          buttonPress("0");
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Text("2"),
                        callback: () {
                          buttonPress("2");
                        },
                      ),
                      CalcButton(
                        child: Text("5"),
                        callback: () {
                          buttonPress("5");
                        },
                      ),
                      CalcButton(
                        child: Text("8"),
                        callback: () {
                          buttonPress("8");
                        },
                      ),
                      CalcButton(
                        child: Text("."),
                        callback: () {
                          buttonPress(".");
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Text("3"),
                        callback: () {
                          buttonPress("3");
                        },
                      ),
                      CalcButton(
                        child: Text("6"),
                        callback: () {
                          buttonPress("6");
                        },
                      ),
                      CalcButton(
                        child: Text("9"),
                        callback: () {
                          buttonPress("9");
                        },
                      ),
                      CalcButton(
                        child: Text("C"),
                        callback: () {
                          setState(() {
                            state = "";
                            index = 0;
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Text("+"),
                        callback: () {
                          buttonPress("+");
                        },
                      ),
                      CalcButton(
                        child: Text("-"),
                        callback: () {
                          buttonPress("-");
                        },
                      ),
                      CalcButton(
                        child: Text("*"),
                        callback: () {
                          buttonPress("*");
                        },
                      ),
                      CalcButton(
                        child: Text("÷"),
                        callback: () {
                          buttonPress("/");
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CalcButton(
                        child: Icon(
                          Icons.backspace,
                          color: white,
                        ),
                        callback: () {
                          if (index != 0) {
                            setState(() {
                              state = state.substring(0, state.length - 1);
                              index--;
                            });
                          }
                        },
                      ),
                      // CalcButton(
                      //   child: CaTeX("y^x"),
                      //   callback: () {},
                      // ),
                      CalcButton(
                        child: Text("("),
                        callback: () {
                          buttonPress("(");
                        },
                      ),
                      CalcButton(
                        child: Text(")"),
                        callback: () {
                          buttonPress(")");
                        },
                      ),
                      CalcButton(
                        child: Text("="),
                        callback: () {
                          buttonPress("=");
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CalcButton(
                        child: CaTeX(
                            "x"), //Text("x", style: textStyle.copyWith(color: white, fontSize: 20, fontStyle: FontStyle.italic),),
                        callback: () {
                          buttonPress("x");
                        },
                      ),
                      CalcButton(
                        child: CaTeX(
                            "y"), //Text("x", style: textStyle.copyWith(color: white, fontSize: 20, fontStyle: FontStyle.italic),),
                        callback: () {
                          buttonPress("y");
                        },
                      ),
                      CalcButton(
                        child: Icon(Icons.arrow_right, color: white),
                        callback: () {
                          setState(() {
                            if (index < state.length) {
                              index++;
                            }
                          });
                        },
                      ),
                      CalcButton(
                        child: Icon(Icons.arrow_left, color: white),
                        callback: () {
                          setState(() {
                            if (index > 0) {
                              index--;
                            }
                          });
                        },
                      ),
                      CalcButton(
                        callback: () {
                          buttonPress("^");
                        },
                        child: Text("^"),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CalcButton(
                        callback: () {
                          print(state);
                          setState(() {
                            state = parser.parse(state).simplify().toString();
                          });
                          justAnswered = true;
                        },
                        child: Text(
                          "Simplify",
                          style: textStyle.copyWith(color: white, fontSize: 15),
                        ),
                      ),
                      CalcButton(
                        callback: () {
                          setState(() {
                            state = state
                                .toSingleVariableFunction('x')
                                .call(state.interpret())
                                .toString();
                            index = state.length;
                          });
                          justAnswered = true;
                        },
                        child: Text(
                          "Evaluate",
                          style: textStyle.copyWith(color: white, fontSize: 15),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
