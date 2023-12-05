import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Test',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
   List<dynamic> _bmis = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  String? _gender;
  String _status = "";

  void _showMessage(String msg){
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg))
      );
    }
  }

  void _calculateBmi() async{

    double weight = double.parse(weightController.text);
    double height = double.parse(heightController.text);
    String username = nameController.text.trim();
    String bmi_status = "";
    String gender = "";
    height = height/100; // convert cm to m

    // BMI = weight (kg) / height (m^2)
    double bmi = weight / (height*height);
    String desc = bmi.toStringAsFixed(2) + " kg/m2";



    if(_gender == "female"){
        if(bmi < 16)
          _status = "Female Underweight. Careful during strong wind!";
        else if(bmi >= 16 && bmi < 22)
          _status = "Female That’s ideal! Please maintain";
        else if(bmi >= 22 && bmi < 27)
          _status = "Female Overweight! Work out please";
        else
          _status = "Female Whoa Obese! Dangerous mate!";
         gender = "female";

    }
    else if(_gender == "male"){
      if(bmi < 18.5)
        _status = "Male Underweight. Careful during strong wind!";
      else if(bmi >= 18.5 && bmi < 24.9)
        _status = "Male That’s ideal! Please maintain";
      else if(bmi >= 25 && bmi < 29.9)
        _status = "Male Overweight! Work out please";
      else
        _status = "Male Whoa Obese! Dangerous mate!";
       gender = "male";

    }else{
        _status = "none";
    }

    bmi_status = _status;

    if(username.isNotEmpty && weight.isFinite && height.isFinite){
      var newItem = {
        "username":username,
        "weight":weight,
        "height":height,
        "bmi_status":bmi_status,
        "gender":gender,
      };
      _bmis.add(newItem);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("bmis",jsonEncode(_bmis));

      // try to get back
      var getString = prefs.getString("bmis");

      setState(() {
        bmiController.text = desc;
        _bmis;
        // loadData();
      });
    }
  }

  @override
  void initState(){
    super.initState();

        loadData();

  }

  void loadData() async {
    // load the file manager
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var bmiString = prefs.getString("bmis");
    print("inside  load data");
    print(bmiString);
    print("over");
    if (bmiString != null) {
      var bmi = jsonDecode(bmiString);
      print(bmi[0]);
      setState(() {

        _bmis = bmi;

        nameController.text = bmi[0]["username"];
          weightController.text = bmi[0]["weight"].toString();
          heightController.text = (bmi[0]["height"]*100).toStringAsFixed(2);
          // BMI = weight (kg) / height (m^2)
          double bmiValue = bmi[0]["weight"] / (bmi[0]["height"]*bmi[0]["height"]);
          bmiController.text = bmiValue.toStringAsFixed(2);
          _gender = bmi[0]["gender"];

      });
    }else{
      print("is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BMI Calculator"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Your Fullname"
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: heightController,
              decoration: InputDecoration(
                  labelText: "Height in cm; 170"
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: weightController,
              decoration: InputDecoration(
                  labelText: "Weight in KG"
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: bmiController,
              decoration: InputDecoration(
                  labelText: "BMI Value"
              ),
              readOnly: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                Radio(value: "male", groupValue: _gender, onChanged: (value){
                  setState(() {
                    _gender = value as String?;
                  });
                }),
                Text("Male"),
                Radio(value: "female", groupValue: _gender, onChanged: (value){
                  setState(() {
                    _gender = value as String?;
                  });
                }),
                Text("Female"),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(onPressed: () async{

                // 1. get the file manager
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                // 2. get the previous data
                var bmiString = prefs.getString("bmis");
                // 3. remove the previous data
                if(bmiString != null)
                  {
                      await prefs.clear();
                    setState(() {

                      _bmis = [];

                    });

                  }
                else{
                  print("opss");
                }
                // 4. process the added item
                _calculateBmi();


            }, child: Text("Calculate BMI and Save")),
          ),
          bmiController.text.isNotEmpty ? Text(_status) :SizedBox()
        ],
      ),
    );
  }
}

