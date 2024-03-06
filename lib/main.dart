import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// Aqui se agrega la logica de negocio como tal

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // Nueva accion crea un par de palabras aleatorias
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // lista de pares de palabras
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });

                  print('Selected: $value');
                },
              ),
            ),
            Expanded(
                child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ))
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;

    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        //Se lo coloca para alinear al centro de manera vertical
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          BigCard(pair: pair),

          // Espacio entre el boton y el card
          SizedBox(height: 10),

          // El boton se agrega dentro de una fila
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Se coloca un boton que dice Next
              ElevatedButton(
                onPressed: () {
                  // se llama a la nueva funcion creada en el estado
                  appState.getNext();
                  print('button Next!');
                },
                child: Text('Next'),
              ),

              // Creo un espacio entre los botones
              SizedBox(width: 10),

              // Se coloca boton Like
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                  print('button Like!');
                },
                icon: Icon(icon),
                label: Text('Like'),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appStateFavoritePage = context.watch<MyAppState>();
    var words = appStateFavoritePage.favorites;

    return ListView.builder(
      // Agrear espacios en todas las direcciones
      // arriba, abajo, izquierda, derecha 
      padding: const EdgeInsets.all(8),

      // Numero de elemntos que contiene la lista
      itemCount: words.length,

      // Cada dato de la lista los genera en modo de widget
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 50,
          child: Center(
            child:
              Text('${words[index]}'),
          ),
        );
      },
    );
    throw UnimplementedError();
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}
