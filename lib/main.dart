import 'package:flutter/material.dart';

// import 'db.dart';
import 'plot.dart';
import 'weather.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // final database = WetherDatabase();
  // await database.init();
  // print(await database.getLocal());

  // await database.update();
  // print(await database.getLocal());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // database = WetherDatabase();
    // database.init();
    // database.update();
    _getLocal();
  }

  _getLocal() async {
    data = await database.getLocal();
  }

  _getExternal() async {
    data = await database.getExternal();
  }

  // WetherDatabase database;
  WetherDatabase database = WetherDatabase();

  List<Weather> data;

  _onTap(BuildContext context, Widget widget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: widget,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Bezier Chart Sample"),
        ),
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              ListTile(
                  title: Text("Show Local Data"),
                  subtitle: Text("Weather Chart from local memory"),
                  onTap: () {
                    _onTap(
                      context,
                      Column(children: [
                        AllWeatherDebug(database: data),
                        PlotGraph(database: data),
                      ]),
                    );
                  }),
              ListTile(
                  title: Text("Fetch and Show New Data"),
                  subtitle: Text("Weather Chart from API"),
                  onTap: () async {
                    await _getExternal();
                    setState(() {});
                    _onTap(
                      context,
                      Column(children: [
                        AllWeatherDebug(database: data),
                        PlotGraph(database: data),
                      ]),
                    );
                  }),
              ListTile(
                title: Text("Settings"),
                subtitle: Text("Get Info and change API path"),
                onTap: () => _onTap(
                  context,
                  Text('3'),
                ),
              ),
            ])));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class AllWeatherDebug extends StatelessWidget {
  const AllWeatherDebug({@required this.database});

  final List<Weather> database;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (var w in database) weatherCell(w)],
    );
  }

  Widget weatherCell(Weather w) {
    return Row(
      children: <Widget>[
        Text(w.time.toLocal().toString()),
        SizedBox(width: 50),
        Text(w.temp.toString()),
      ],
    );
  }
}
