import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'network.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NLP Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Answering machine'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _urlController = TextEditingController();
  TextEditingController _questionController = TextEditingController();
  TextEditingController _contextController = TextEditingController();
  String _answerText = "";

  static const platform = const MethodChannel("org.android.client.nlp_demo.channel");

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body:  Column(
            children: <Widget>[
              Expanded(
                child: Column(
                    children: <Widget>[
                      _loadUrlWidget(),
                      _getContextWidget(),
                      Padding(padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 0.0)),
                      _getQuestionWidget(),
                      _getAnswerWidget(),
                      Padding(padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 0.0)),
                    ]
                )
            ),
              _getButtonWidget(),
            ]
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _questionController.dispose();
    _contextController.dispose();
    _urlController.dispose();
  }

  Widget _loadUrlWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(controller: _urlController,),
        ),
        OutlineButton(
          child: Text('Wiki', style: TextStyle(fontSize: 20, color: Colors.black)),
          textColor: Colors.white,
          onPressed: () async {
            _contextController.text = await loadTextFromHtml(_urlController.text);
          },
        )

      ],
    );
  }

  Widget _getContextWidget() {
    return Expanded(
      child: SingleChildScrollView(
        child: TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          controller: _contextController,
          decoration: InputDecoration(
            hintText: "Context here",
          ),
        )
      )
    );
  }
  
  Widget _getQuestionWidget() {
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      controller: _questionController,
      decoration: InputDecoration(
        hintText: "Question here"
      ),
    );
    
  }

  Widget _getAnswerWidget() {
    return Text(
      '$_answerText',
      style: Theme.of(context).textTheme.display1,
    );
  }
  
  Widget _getButtonWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: RaisedButton(
        onPressed: _onAnswerButtonClicked,
        child: const Text('Answer me', style: TextStyle(fontSize: 20)),
        color: Colors.blue,
        textColor: Colors.white,
        elevation: 5,
      ),
    );
  }

  void _onAnswerButtonClicked() async {
    print("Clicked");
    var answer = await this._getAnswer(_contextController.text,
        _questionController.text);
    setState(() {
      _answerText = answer.answerText;
      _contextController.selection = _getSelectedText(_answerText);
      _contextController.j
    });
  }

  Future<QaAnswer> _getAnswer(String context, String question) async {
    var answerResult = await platform.invokeMethod("getAnswer",
        {"context": _contextController.text, "question": _questionController.text});
    return QaAnswer(answerResult);
  }

  TextSelection _getSelectedText(String selection) {
    var start = _contextController.text.indexOf(selection);
    var end = start + selection.length;
    return TextSelection(baseOffset: start, extentOffset: end);
  }
}

class QaAnswer {
  String answerText;
  int startPosition;
  int endPosition;

  QaAnswer(Map<dynamic, dynamic> answerResult) {
    answerText = answerResult["answerText"];
    startPosition = int.parse(answerResult["startPosition"]);
    endPosition = int.parse(answerResult["endPosition"]);
  }
}
