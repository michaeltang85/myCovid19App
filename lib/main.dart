import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/detailDailyStats.dart';
import 'package:flutter/rendering.dart';

import 'dart:convert' show json;

void main() {
  runApp(MaterialApp(title:'Canada Covid stats', home: CovidData(),));
}

class DailyData {
  final String date;
  final int confirmed;
  final int deaths;
  final int recovered;
  DailyData({this.date, this.confirmed, this.deaths, this.recovered});
}


Future<CovidStatsData> fetchData() async {
  final response = await http.get('https://pomber.github.io/covid19/timeseries.json');
  if (response.statusCode == 200){
    return CovidStatsData.fromJson(json.decode(response.body));
  }
  else {
    throw Exception('Failed to load covid stats');
  }
}

class CovidDataState extends State<CovidData> {
  Future<CovidStatsData> futureData;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override 
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Widget _buildRow(DailyData dailyData){
    return ListTile(
          title: Text(
            dailyData.date,
            style: _biggerFont,
          ),
          trailing: Text(
            dailyData.confirmed.toString(),
            style: _biggerFont,
          ),
          onTap: () {
            Navigator.push (
              context,
              MaterialPageRoute(builder: (context) => DetailDailyStats(dailyData: dailyData)),
            );
          },
      );
  }


  Widget build(BuildContext context) {
    return MaterialApp(title: 'Canada Covid Stats', 
    theme: ThemeData(primarySwatch: Colors.blue),
    home: Scaffold(
          
          appBar: AppBar(
              title: Text('Canada Covid Data'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: (){
                    setState(() { futureData = fetchData(); });
                  }
                ),
              ]
          ),
          
          body: Column(
                children:[ 
                  Image(
                      image: AssetImage('images/bg.jpg'),
                      fit: BoxFit.cover,
                      
                    ),
                  FutureBuilder<CovidStatsData>(
                  future: futureData,
                  builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SizedBox(
                            height: 360, 
                            child:(
                              ListView.builder(
                               itemCount: snapshot.data.canada.length,
                                itemBuilder: (context, index) {
                                DailyData dailyData = snapshot.data.canada[index];
                                return _buildRow(dailyData);
                             },))
                            );
                        }
                        else if (snapshot.hasError){
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
                      } 
                    ,) 
                ],
                  ),
      ),
    );
  }
}

class CovidData extends StatefulWidget {
  @override 
  CovidDataState createState() => CovidDataState();
}

class CovidStatsData {
  final List<DailyData> canada;
  CovidStatsData({this.canada});
  factory CovidStatsData.fromJson(Map<String, dynamic> json){
    List<DailyData> canada = json['Canada'].map<DailyData>((data){
      return DailyData(
        date: data["date"],
        confirmed: data["confirmed"],
        deaths: data["deaths"],
        recovered: data["recovered"]
      );
    }).toList();
    return CovidStatsData(canada: canada,);
  }
}

