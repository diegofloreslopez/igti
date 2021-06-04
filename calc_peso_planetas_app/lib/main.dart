import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:calc_peso_planetas_app/planet.dart';

void main() => runApp(WeightPlanetCalcApp());

/*
 Calcula seu peso corporal em outros planetas, baseado na gravidade do planeta.   
*/
class WeightPlanetCalcApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Trab. Prático IGTI';
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: HomeScreenForm(),
      ),
    );
  }
}

class HomeScreenForm extends StatefulWidget {
  @override
  _HomeScreenFormState createState() {
    return _HomeScreenFormState();
  }
}

Future<List<Planet>> fetchPlanets() async {
  var planetsJsonObjs = await rootBundle
      .loadString("assets/planets.json")
      .then((jsonStr) => jsonDecode(jsonStr)['planets']) as List;

  List<Planet> planetList =
      planetsJsonObjs.map((planetJson) => Planet.fromJson(planetJson)).toList();
  return planetList;
}

class _HomeScreenFormState extends State<HomeScreenForm> {
  late Future<List<Planet>> planetListFuture;
  TextEditingController textFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    planetListFuture = fetchPlanets();
  }

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(0),
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('Calcule seu peso em outros planetas'),
                      subtitle:
                          Text('Insira seu peso e selecione o planeta/astro'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 150, 10),
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                controller: textFieldController,
                decoration: InputDecoration(
                  labelText: "Quanto você pesa (em kg) ?",
                  // enabledBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10.0),
                  // ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Insira seu peso!";
                  }
                  return null;
                },
              ),
            ),
            Flexible(
              child: FutureBuilder<List<Planet>>(
                  future: planetListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? listViewPlanetsWidget(
                            context, snapshot.data, textFieldController.text)
                        : Center(child: CircularProgressIndicator());
                  }),
            )
          ],
        ));
  }

  Widget listViewPlanetsWidget(
      BuildContext buildContext, List<Planet>? planets, String weightInput) {
    if (planets == null)
      return new Text(
          "Erro ao carregar lista de Planetas >> List<Planet>? planets == null");

    return ListView.builder(
      shrinkWrap: true,
      itemCount: planets.length,
      itemBuilder: (buildContext, index) {
        return Card(
          child: ListTile(
            title: Text(planets[index].title),
            leading: CircleAvatar(
              backgroundImage: AssetImage('assets/${planets[index].name}.png'),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              if (_formKey.currentState!.validate()) {
                Navigator.push(
                  buildContext,
                  MaterialPageRoute(
                    builder: (buildContext) => DetailScreen(
                        planet: planets[index],
                        weightInput: textFieldController.text),
                    // settings: RouteSettings(arguments: peso)
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Planet planet;
  final String weightInput;
  final double oneNewtonKgf = 0.102;

  double calculateWeightOnPlanet() {
    // # Cálculo
    // (Peso em kg * Gravidade do Planeta em m/s²) = Força em Newtons
    // 1 Newton = 0,1012 Kgf
    // (Peso em kg * Gravidade do Planeta em m/s²) * (1 Newton) = Peso no outro Planeta
    return (double.parse(weightInput) * planet.gravity) * oneNewtonKgf;
  }

  DetailScreen({Key? key, required this.planet, required this.weightInput})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double weightOnPlanet = calculateWeightOnPlanet();

    return Scaffold(
      appBar: AppBar(
        title: Text(planet.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/${planet.name}.png'),
                    ),
                    title: Text(
                        "Seu peso no astro/planeta ${planet.title} é: ${weightOnPlanet.toStringAsFixed(2)} kg"),
                    subtitle: Text(
                        "Gravidade: ${planet.gravity.toStringAsFixed(2)} m/s²"),
                  ),
                ],
              ),
            ),
            Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: (weightOnPlanet > double.parse(weightInput))
                  ? Image.asset(
                      'assets/fat_person.png',
                      fit: BoxFit.fill,
                    )
                  : Image.asset(
                      'assets/thin_person.png',
                      fit: BoxFit.fill,
                    ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(10),
            )
          ],
        ),
      ),
    );
  }
}
