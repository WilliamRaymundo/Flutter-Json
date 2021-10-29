import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

Future<List<dynamic>> pegarCidades() async {
  final resposta = await http.get(
      Uri.parse("https://servicodados.ibge.gov.br/api/v1/localidades/regioes"));

  if (resposta.statusCode == 200) {
    var cidadeObjJson = jsonDecode(resposta.body);
    List<dynamic> listagem =
        cidadeObjJson.map((objJson) => Cidade.fromJson(objJson)).toList();
    return listagem;
  } else {
    throw Exception("Comunicação Falhou");
  }
}

class Cidade {
  final int id;
  final String nome;
  final String sigla;

  Cidade({required this.id, required this.nome, required this.sigla});

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(id: json["id"], nome: json["nome"], sigla: json['sigla']);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late Future<List<dynamic>> futureCidades;

  @override
  void initState() {
    super.initState();
    futureCidades = pegarCidades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FutureBuilder<List<dynamic>>(
            future: futureCidades,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                        leading: FlutterLogo(size: 16.0),
                        title: Text(snapshot.data![index].nome),
                        subtitle: Text(snapshot.data![index].sigla),
                      ));
                    });
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            futureCidades = pegarCidades();
          });
        },
      ),
    );
  }
}
