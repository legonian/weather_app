import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class WetherDatabase {
  SavedWeather local = SavedWeather();

  Future<void> updateLocal() async {
    List<Weather> data = await getExternal();
    local.upload(data);
  }

  Future<List<Weather>> getExternal() async {
    final weatherUrl = 'https://raw.githubusercontent.com'
        '/legonian/weather_app/master/'
        'example1.json';
    final res = await http.get(weatherUrl);

    if (res.statusCode == 200) {
      final jsonRes = convert.jsonDecode(res.body) as Map<String, dynamic>;
      if (jsonRes['ok'] as bool) {
        final jsonData = jsonRes['data'] as List<dynamic>;
        return jsonData.map((json) => Weather.fromMap(json)).toList();
      } else {
        print('Server dont have the requested data (json[ok] = false).');
        return <Weather>[];
      }
    } else {
      print('Request failed with status: ${res.statusCode}.');
      return <Weather>[];
    }
  }

  Future<List<Weather>> getLocal() async {
    return local.data();
  }
}

class SavedWeather {
  final path = 'weather.db';
  final dbName = 'weather';

  Future<Database> init() async {
    return openDatabase(
      join(await getDatabasesPath(), path),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE weather('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'time TEXT,'
          'temp REAL,'
          'humidity REAL,'
          'presure REAL'
          ')',
        );
      },
      version: 1,
    );
  }

  Future<List<Weather>> data() async {
    final data = await init();
    final List<Map<String, dynamic>> maps = await data.query(dbName);
    return List.generate(maps.length, (i) => Weather.fromMap(maps[i]));
  }

  Future<void> upload(List<Weather> weatherData) async {
    final data = await init();

    await clear();

    for (var singleData in weatherData) {
      await data.insert(
        dbName,
        singleData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> clear() async {
    final data = await init();
    await data.delete(dbName);
  }
}

class Weather {
  final DateTime time;
  final double temp;
  final double humidity;
  final double presure;

  Weather({this.time, this.temp, this.humidity, this.presure});

  factory Weather.fromMap(Map<String, dynamic> map) {
    final time = DateTime.parse(map['time'] as String);
    final temp = (map['temp'] as num).toDouble();
    final humidity = (map['humidity'] as num).toDouble();
    final presure = (map['presure'] as num).toDouble();

    return Weather(
      time: time,
      temp: temp,
      humidity: humidity,
      presure: presure,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time': time.toIso8601String(),
      'temp': temp,
      'humidity': humidity,
      'presure': presure,
    };
  }

  @override
  String toString() {
    return 'Weather{time: $time, name: $temp, age: $humidity, age: $presure}';
  }
}
