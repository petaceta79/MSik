import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../helpers/utilsGestionArchivos.dart';

class Info extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A4A4A),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A4A4A),
        centerTitle: true,
        title: Text(
          'Canciones',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: EdgeInsets.only(top: 25.h),
          child: Scrollinfo(context),
        ),
      ),
    );
  }

  Widget Scrollinfo(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 350.w,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.deepOrangeAccent, width: 2.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withAlpha((0.5 * 255).round()),
                  blurRadius: 5.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Descripción'),
                _sectionText(
                  'MSik es un reproductor de música que guarda todos los audios de forma local. Los archivos descargados desde YouTube se almacenan en formato MP3, ocupando poco espacio. Estos se guardan en carpetas privadas, por lo que no son accesibles desde fuera de la aplicación.',
                ),
                _sectionText(
                  'Permite reproducir los audios de forma individual o agruparlos en listas de reproducción (playlists).',
                ),
                _sectionText(
                  'Durante la reproducción, ofrece las funciones básicas de cualquier reproductor de música, como saltar canciones, repetir en bucle, entre otras.',
                ),

                SizedBox(height: 20.h),

                _sectionTitle('Contacto'),
                _sectionText('GitHub: https://github.com/petaceta79'),
                _sectionText('Email: creeperxx79@gmail.com'),

                SizedBox(height: 20.h),

                _sectionTitle('Política de Privacidad'),
                _sectionText(
                  'Esta aplicación respeta completamente tu privacidad.',
                ),
                _sectionText(
                  'Todos los archivos y datos generados o utilizados por la app se almacenan únicamente en tu dispositivo.',
                ),
                _sectionText(
                  'No se recopila, transmite ni comparte ninguna información personal o sensible con terceros.',
                ),
                _sectionText(
                  'Tu información es tuya. Esta app está diseñada para funcionar de forma segura y privada.',
                ),

                SizedBox(height: 20.h),

                _sectionTitle('Aviso legal'),
                _sectionText(
                  'Esta aplicación ha sido desarrollada con el único propósito de permitir la reproducción local de archivos de audio.',
                ),
                _sectionText(
                  'El desarrollador no se responsabiliza por el uso indebido que los usuarios puedan hacer de la aplicación, en especial respecto a la descarga, almacenamiento o reproducción de contenido protegido por derechos de autor.',
                ),
                _sectionText(
                  'El usuario es el único responsable de asegurarse de cumplir con las leyes locales e internacionales sobre propiedad intelectual y derechos de autor.',
                ),
                _sectionText(
                  'Esta herramienta se proporciona "tal cual", sin garantías de ningún tipo, expresas o implícitas.',
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          deleteAllBoton(context),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  ElevatedButton deleteAllBoton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        bool confirmado = await advertenciaBorrar(context);
        if (confirmado) {
          borraTodo();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC64820), // Color de fondo
        foregroundColor: Colors.white,      // Color del texto e íconos
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Text(
        '¡BORRAR TODO!',
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text, style: TextStyle(fontSize: 16.sp)),
    );
  }

  Future<bool> advertenciaBorrar(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // No se puede cerrar tocando fuera
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('¿Estás seguro?'),
              actions: [
                TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancelar
                  },
                ),
                TextButton(
                  child: Text('Sí'),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirmar
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Si se cierra el diálogo sin seleccionar nada, devuelve false
  }
}
