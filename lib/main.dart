import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main Project',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: "/home",
      routes: {
        "/setup": (context) => const Setup(),
        "/home": (context) => const MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final controller = AnimationController(vsync: this, duration: Duration(seconds: 2))
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed("/setup");
    });
    return Scaffold(
        appBar: AppBar(
          // centerTitle: true,
          title: Text('Main Project'),
        ),
        body: Center(
          child: Column(
            children: [
              Image(image: AssetImage('assets/images/kg.jpeg'), width: 200, height: 350),
              SizedBox(height: 10),
              Text("Project Title",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              Text("By Avinash.T")
            ],
          ),
        ),
      );
  }
}

class Setup extends StatefulWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  _setupState createState() => _setupState();
}

class _setupState extends State<Setup> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  late var data;
  late List<SalesData> allData = [
    // Bind data source
    SalesData('Jan', 35),
    SalesData('Feb', 28),
    SalesData('Mar', 34),
    SalesData('Apr', 32),
    SalesData('May', 40)
  ];
  late FirebaseFirestore firestore;
  late TooltipBehavior _tooltipBehavior;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        firestore = FirebaseFirestore.instance;
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
    CollectionReference _collectionRef = FirebaseFirestore.instance.collection('sample');

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _collectionRef.get();

    // Get data from docs and convert map to List
    allData = querySnapshot.docs.map((doc){
      data = doc.data();
      print(data["Month"] + "temp "+ data["Temp"].toString());
      return SalesData(data["Month"], data["Temp"].toDouble());
    }).toList();

    print("done");
    //
    // Future<void> getData() async {
    //   // Get docs from collection reference
    //   QuerySnapshot querySnapshot = await _collectionRef.get();
    //
    //   // Get data from docs and convert map to List
    //   final allData = querySnapshot.docs.map((doc){
    //     data = doc.data();
    //     log('data $data');
    //     return data;
    //   }).toList();
    //
    //   print(allData);
    // }
  }

  @override
  void initState() {
    initializeFlutterFire();
    _tooltipBehavior =  TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if(_error) {
      return Scaffold(
        body: Center(
          child: Text("error"),
        ),
      );
    }
    print("main");
    if(_initialized) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Graph'),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Drawer Header',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Graph Setting'),
                ),
                ListTile(
                  leading: Icon(Icons.offline_bolt_outlined),
                  title: Text('Custom Input'),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile'),
                ),
              ],
            ),
          ),
          body: Center(
              child: Container(
                //Initialize chart
                  child: SfCartesianChart(
                    // Initialize category axis
                      title: ChartTitle(text: 'Half yearly sales analysis'),
                      tooltipBehavior: _tooltipBehavior,
                      primaryXAxis: CategoryAxis(),
                      series: <ChartSeries>[
                        // Initialize line series
                        LineSeries<SalesData, String>(
                            dataSource: allData,
                            xValueMapper: (SalesData sales, _) => sales.year,
                            yValueMapper: (SalesData sales, _) => sales.sales
                        )
                      ]
                  )
              )
          )
      );
    }
    return Scaffold(
      body: Center(
        child: Text("loading"),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double? sales;
}