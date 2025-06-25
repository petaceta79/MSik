import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Necesario
import 'reproductorDeMusica/reproductor_de_musica.dart';
import 'helpers/utilsSongPlaylist.dart';
import 'helpers/utilsGestionArchivos.dart';
import 'pestannas/gestion_canciones.dart';
import 'pestannas/gestion_playlist.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pestannas/info.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de usar SharedPreferences

  await reiniciarCancionesMasEscuchadasCadaSemana(); // Cada semana se reinician las canciones mas escuchadas

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(411, 922),
      // Tamaño base sobre el que diseñaste (dp)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'MSik',
          theme: ThemeData(primarySwatch: Colors.orange),
          home: child,
          navigatorObservers: [routeObserver],
          routes: {
            '/gestion': (context) => GestionCanciones(),
            '/gestionPlaylist': (context) => GestionPlaylist(),
            '/info': (context) => Info(),
          },
        );
      },
      child: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A4A4A), // Gris oscuro
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 25.h),

              // Título "Msik"
              Titulo(),

              SizedBox(height: 40.h),

              // Botón de Canciones
              Nav_Canciones(context),

              // Botón de Playlists
              Nav_playlists(context),

              SizedBox(height: 45.h),

              UltimasPlaylistsWidget(),

              SizedBox(height: 18.h),

              CancionesMasEscuchadasWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: botonInfo(context),
    );
  }

  SizedBox botonInfo(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(right: 20.w), // espacio a la derecha con ScreenUtil
          child: botonInterrogante(context),
        ),
      ),
    );
  }

  Widget botonInterrogante(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/info'),
      child: Container(
        width: 60.w,   // ancho con ScreenUtil
        height: 60.h,  // alto con ScreenUtil
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.r, // radio con ScreenUtil
              offset: Offset(2.w, 2.h),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.sp,  // tamaño de texto con ScreenUtil
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Container Titulo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        'Msik',
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  GestureDetector Nav_Canciones(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/gestion'),
      child: Container(
        width: 250.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Canciones', style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 10.w),
            Icon(Icons.album, color: Colors.black, size: 24.sp),
          ],
        ),
      ),
    );
  }

  GestureDetector Nav_playlists(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/gestionPlaylist'),
      child: Container(
        width: 250.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Playlists', style: TextStyle(fontSize: 18.sp)),
            SizedBox(width: 10.w),
            Icon(Icons.library_music, color: Colors.black, size: 24.sp),
          ],
        ),
      ),
    );
  }
}

// Cajas UltimasPlaylists
class UltimasPlaylistsWidget extends StatefulWidget {
  @override
  _UltimasPlaylistsWidgetState createState() => _UltimasPlaylistsWidgetState();
}

class _UltimasPlaylistsWidgetState extends State<UltimasPlaylistsWidget>
    with RouteAware {
  List<String> lastPlaylistNames = [];

  @override
  void initState() {
    super.initState();
    cargarUltimasPlaylists();
  }

  Future<void> cargarUltimasPlaylists() async {
    final datos = await utlimasplaylistEscuchadas();
    setState(() {
      lastPlaylistNames = datos;
    });
  }

  void irAReproductor(String playlistName) async {
    final canciones = await getPlaylistSongs(playlistName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReproductorDeMusica(canciones: canciones),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Se llama cuando volvés a esta pantalla desde otra
    cargarUltimasPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          // Aquí adaptar padding
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12.r), // Radio adaptado
          ),
          child: Text(
            'Ultimas playlists',
            style: TextStyle(fontSize: 15.sp), // Tamaño de fuente adaptado
          ),
        ),
        SizedBox(height: 8.h), // Espacio adaptado
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cajaUltimaPlaylist(
              lastPlaylistNames.isNotEmpty ? lastPlaylistNames[0] : '',
            ),
            _cajaUltimaPlaylist(
              lastPlaylistNames.length > 1 ? lastPlaylistNames[1] : '',
            ),
          ],
        ),
      ],
    );
  }

  Widget _cajaUltimaPlaylist(String titulo) {
    return Container(
      width: 150.w,
      // ancho adaptado
      height: 160.h,
      // alto adaptado
      margin: EdgeInsets.all(8.w),
      // margen adaptado (usé .w, podría ser también .h o .r según diseño)
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(16.r), // radio adaptado
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 35.h),
          // espacio vertical adaptado
          Expanded(
            child: SizedBox(
              width: 125.w, // ancho adaptado
              child: Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp, // tamaño de texto adaptado
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          buildBotonReproducir(titulo),
          // asumo que este widget también tiene medidas internas que deberías adaptar
          SizedBox(height: 5.h),
          // espacio vertical adaptado
        ],
      ),
    );
  }

  Widget buildBotonReproducir(String titulo) {
    if (titulo.isEmpty) {
      // Si el título está vacío, mostramos un botón deshabilitado con ícono de X
      return ElevatedButton(
        onPressed: null, // Deshabilitado
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFC64820),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Icon(Icons.close, size: 20.sp), // Ícono de X
      );
    } else {
      // Si el título tiene contenido, mostramos el botón de reproducir
      return ElevatedButton(
        onPressed: () {
          irAReproductor(titulo);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFC64820),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Icon(Icons.play_arrow, size: 20.sp),
      );
    }
  }
}

// Cajas UltimasPlaylists
class CancionesMasEscuchadasWidget extends StatefulWidget {
  @override
  _CancionesMasEscuchadasWidgetState createState() =>
      _CancionesMasEscuchadasWidgetState();
}

class _CancionesMasEscuchadasWidgetState
    extends State<CancionesMasEscuchadasWidget>
    with RouteAware {
  List<String> lastSongsNames = ['', ''];
  List<int> lastSongsTimes = [0, 0];

  @override
  void initState() {
    super.initState();
    cargarSongsMasEscuchadas();
  }

  Future<void> cargarSongsMasEscuchadas() async {
    final datos = await DosCancionesMasEscuchadas();
    setState(() {
      lastSongsNames = [datos[0], datos[2]];
      lastSongsTimes = [int.parse(datos[1]), int.parse(datos[3])];
    });
  }

  void irAReproductor(String songName) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReproductorDeMusica(canciones: [songName]),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Se llama cuando volvés a esta pantalla desde otra
    cargarSongsMasEscuchadas();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            'Canciones más escuchadas (por semana)',
            style: TextStyle(fontSize: 15.sp),
          ),
        ),
        SizedBox(height: 8.h), // espacio vertical adaptado
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cajaUltimaPlaylist(lastSongsNames[0], lastSongsTimes[0]),
            _cajaUltimaPlaylist(lastSongsNames[1], lastSongsTimes[1]),
          ],
        ),
      ],
    );
  }

  Widget _cajaUltimaPlaylist(String titulo, int amount) {
    return Container(
      width: 150.w,
      // ancho adaptado
      height: 160.h,
      // alto adaptado
      margin: EdgeInsets.all(8.w),
      // margen adaptado
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(16.r), // radio adaptado
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 35.h), // espacio vertical adaptado
          Expanded(
            child: SizedBox(
              width: 125.w, // ancho adaptado
              child: Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp, // tamaño de texto adaptado
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildBotonReproducir(titulo),
              // ya adaptado previamente
              SizedBox(width: 8.w),
              // espacio horizontal adaptado
              numAmount(amount),
              // función para mostrar número, ojo si usa tamaños, adaptar ahí
            ],
          ),
          SizedBox(height: 5.h), // espacio vertical adaptado
        ],
      ),
    );
  }

  Widget numAmount(int amount) {
    final displayText = amount > 99999 ? '99999+' : amount.toString();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      // padding adaptado
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent,
        borderRadius: BorderRadius.circular(8.r), // radio adaptado
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14
              .sp, // tamaño de texto adaptado (puedes ajustar a lo que necesites)
        ),
      ),
    );
  }

  Widget buildBotonReproducir(String titulo) {
    if (titulo.isEmpty) {
      // Si el título está vacío, mostramos un botón deshabilitado con ícono de X
      return ElevatedButton(
        onPressed: null, // Deshabilitado
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFC64820),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Icon(Icons.close, size: 18.sp), // Ícono de X
      );
    } else {
      // Si el título tiene contenido, mostramos el botón de reproducir
      return ElevatedButton(
        onPressed: () {
          irAReproductor(titulo);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFC64820),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Icon(Icons.play_arrow, size: 18.sp),
      );
    }
  }
}
