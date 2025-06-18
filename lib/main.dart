import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Necesario
import 'reproductorDeMusica/reproductor_de_musica.dart';
import 'helpers/utilsSongPlaylist.dart';
import 'helpers/utilsGestionArchivos.dart';
import 'pestannas/gestion_canciones.dart';
import 'pestannas/gestion_playlist.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de usar SharedPreferences

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/gestion': (context) => GestionCanciones(),
        '/gestionPlaylist': (context) => GestionPlaylist(), // <-- Nueva ruta
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/gestion');
              },
              child: Text('Ir a Gestión de Canciones'),
            ),
            SizedBox(width: 16), // Espacio entre botones
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/gestionPlaylist');
              },
              child: Text('Ir a Gestión de Playlists'),
            ),
          ],
        ),
      ),
    );
  }
}