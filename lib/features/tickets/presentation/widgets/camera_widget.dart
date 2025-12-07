import 'package:flutter/material.dart';

/// Widget de Cámara para capturar fotos de tickets
///
/// Este widget permite al usuario tomar fotografías de sus tickets/recibos
/// para asociarlas con los registros de gastos.
///
/// FUNCIONALIDAD FUTURA:
/// - Integración con el paquete `image_picker` para acceder a la cámara
/// - Permisos de cámara en Android/iOS
/// - Recorte y compresión de imágenes
/// - Upload directo a Supabase Storage
///
/// NOTA: Actualmente este es un widget simulado. La integración real
/// con `image_picker` se implementará en una versión posterior.
class WidgetCamara extends StatefulWidget {
  /// Callback que se ejecuta cuando se toma una foto
  /// Retorna la ruta local de la imagen capturada
  final Function(String rutaImagen)? alTomarFoto;

  /// Muestra una vista previa de la foto tomada
  final bool mostrarVistaPrevia;

  const WidgetCamara({
    super.key,
    this.alTomarFoto,
    this.mostrarVistaPrevia = true,
  });

  @override
  State<WidgetCamara> createState() => _WidgetCamaraState();
}

class _WidgetCamaraState extends State<WidgetCamara> {
  // Ruta de la imagen capturada (null si no se ha tomado foto)
  String? _rutaImagenCapturada;

  // Estado de carga mientras se procesa la imagen
  bool _procesandoImagen = false;

  /// Simula la captura de foto con la cámara
  ///
  /// IMPLEMENTACIÓN FUTURA con image_picker:
  ///
  /// ```dart
  /// import 'package:image_picker/image_picker.dart';
  ///
  /// Future<void> _tomarFotoConCamara() async {
  ///   setState(() {
  ///     _procesandoImagen = true;
  ///   });
  ///
  ///   try {
  ///     // Crear instancia del selector de imágenes
  ///     final ImagePicker selector = ImagePicker();
  ///
  ///     // Abrir la cámara y capturar la foto
  ///     final XFile? imagen = await selector.pickImage(
  ///       source: ImageSource.camera,  // Usa la cámara del dispositivo
  ///       imageQuality: 80,             // Compresión al 80% para ahorrar espacio
  ///       maxWidth: 1920,               // Ancho máximo de 1920px
  ///       maxHeight: 1080,              // Alto máximo de 1080px
  ///       preferredCameraDevice: CameraDevice.rear, // Cámara trasera por defecto
  ///     );
  ///
  ///     if (imagen != null) {
  ///       // Guardar la ruta de la imagen capturada
  ///       setState(() {
  ///         _rutaImagenCapturada = imagen.path;
  ///       });
  ///
  ///       // Notificar al widget padre que se tomó una foto
  ///       widget.alTomarFoto?.call(imagen.path);
  ///
  ///       // Mostrar confirmación al usuario
  ///       if (mounted) {
  ///         ScaffoldMessenger.of(context).showSnackBar(
  ///           const SnackBar(
  ///             content: Text('Foto capturada exitosamente'),
  ///             backgroundColor: Colors.green,
  ///           ),
  ///         );
  ///       }
  ///     }
  ///   } catch (error) {
  ///     // Manejar errores (permisos denegados, cámara no disponible, etc.)
  ///     if (mounted) {
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         SnackBar(
  ///           content: Text('Error al tomar foto: $error'),
  ///           backgroundColor: Colors.red,
  ///         ),
  ///       );
  ///     }
  ///   } finally {
  ///     setState(() {
  ///       _procesandoImagen = false;
  ///     });
  ///   }
  /// }
  /// ```
  ///
  /// PERMISOS REQUERIDOS:
  ///
  /// Android (android/app/src/main/AndroidManifest.xml):
  /// ```xml
  /// <uses-permission android:name="android.permission.CAMERA" />
  /// <uses-feature android:name="android.hardware.camera" />
  /// ```
  ///
  /// iOS (ios/Runner/Info.plist):
  /// ```xml
  /// <key>NSCameraUsageDescription</key>
  /// <string>Necesitamos acceso a tu cámara para tomar fotos de tus tickets</string>
  /// <key>NSPhotoLibraryUsageDescription</key>
  /// <string>Necesitamos acceso a tu galería para seleccionar fotos de tickets</string>
  /// ```
  Future<void> _tomarFotoConCamara() async {
    setState(() {
      _procesandoImagen = true;
    });

    // TODO: Integrar paquete image_picker
    // Por ahora, simulamos un delay como si estuviéramos abriendo la cámara
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _procesandoImagen = false;
      _rutaImagenCapturada = '/simulado/ruta/foto_ticket.jpg';
    });

    // Notificar al widget padre
    widget.alTomarFoto?.call(_rutaImagenCapturada!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto simulada capturada (integración pendiente)'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Permite seleccionar una foto de la galería
  ///
  /// IMPLEMENTACIÓN FUTURA:
  /// Similar a _tomarFotoConCamara pero usando ImageSource.gallery
  Future<void> _seleccionarDeGaleria() async {
    setState(() {
      _procesandoImagen = true;
    });

    // TODO: Implementar selección desde galería con image_picker
    // final XFile? imagen = await ImagePicker().pickImage(
    //   source: ImageSource.gallery,
    //   imageQuality: 80,
    // );

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _procesandoImagen = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selección de galería (integración pendiente)'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título del widget
          const Text(
            'Fotografía del Ticket',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),

          // Vista previa de la imagen (si existe)
          if (widget.mostrarVistaPrevia && _rutaImagenCapturada != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Foto capturada',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rutaImagenCapturada!,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón: Tomar Foto
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _procesandoImagen ? null : _tomarFotoConCamara,
                  icon: _procesandoImagen
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.camera_alt),
                  label: const Text('Tomar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Botón: Seleccionar de Galería
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _procesandoImagen ? null : _seleccionarDeGaleria,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Texto informativo
          const SizedBox(height: 12),
          Text(
            'La foto ayudará a respaldar tu registro de gasto',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
