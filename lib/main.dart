import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'screens/pokemon_detail_page.dart';

void main() => runApp(PokemonListPage());

class PokemonListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primaryColor: Colors.green),
        home: Scaffold(
            appBar: AppBar(
              title: Text('Pokemon Flutter'),
            ),
            body: PokemonList()));
  }
}

class PokemonList extends StatefulWidget {
  @override
  PokemonListState createState() => PokemonListState();
}

class PokemonListState extends State<PokemonList> {
  late Future<List<PokemonDetail>> futurePokemonList;

  Future<List<PokemonDetail>> _fetchPokemonList() async {
    var response = await http.get(Uri.https('pokeapi.co', 'api/v2/pokemon'));

    if (response.statusCode == 200) {
      var res = PokemonListResponse.fromJson(jsonDecode(response.body));

      var details =
          res.pokemonList.map((pokemon) => http.get(Uri.parse(pokemon.url)));

      var pokemonDetailList = await Future.wait(details).then((response) =>
          response
              .map((curr) => PokemonDetail.fromJson(jsonDecode(curr.body)))
              .toList());

      return pokemonDetailList;
    }

    return [];
  }

  @override
  void initState() {
    super.initState();
    futurePokemonList = _fetchPokemonList();
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<PokemonDetail>>(
        future: futurePokemonList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: GridView.count(
                crossAxisCount: 2,
                children: snapshot.data!
                    .map(
                      (detail) => Container(
                        child: Material(
                          child: InkWell(
                            child: Container(
                              child: Column(children: [
                                Expanded(
                                  child: Image.network(
                                      detail.sprites.frontDefault),
                                  flex: 2,
                                ),
                                Text(detail.name),
                              ]),
                              padding: const EdgeInsets.all(16),
                            ),
                            onTap: () {
                              print('preseed');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PokemonDetailPage()));
                            },
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              side: BorderSide(
                                  color: Colors.grey[400]!, width: 1.0)),
                        ),
                      ),
                    )
                    .toList(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                padding: EdgeInsets.all(16.0),
              ),
              // padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
            );
          } else if (snapshot.hasError) {
            return Text('Error');
          }

          return Center(child: CircularProgressIndicator());
        });
  }
}

class PokemonListResponse {
  final int count;
  final String next;
  final String? previous;
  final List<PokemonListItem> pokemonList;

  PokemonListResponse(
      {required this.count,
      required this.next,
      required this.previous,
      required this.pokemonList});

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List;
    List<PokemonListItem> pokemonList =
        list.map((item) => PokemonListItem.fromJson(item)).toList();

    return PokemonListResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      pokemonList: pokemonList,
    );
  }
}

class PokemonListItem {
  final String name;
  final String url;

  PokemonListItem({required this.name, required this.url});

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(name: json['name'], url: json['url']);
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final Sprites sprites;

  PokemonDetail({required this.id, required this.name, required this.sprites});

  factory PokemonDetail.fromJson(Map<String, dynamic> json) => PokemonDetail(
      id: json['id'],
      name: json['name'],
      sprites: Sprites.fromJson(json['sprites']));
}

class Sprites {
  final String frontDefault;

  Sprites({required this.frontDefault});

  factory Sprites.fromJson(Map<String, dynamic> json) =>
      Sprites(frontDefault: json['front_default']);
}
