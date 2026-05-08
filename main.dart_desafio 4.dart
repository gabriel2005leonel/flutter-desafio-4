import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaginaSensor(),
    );
  }
}

class PaginaSensor extends StatefulWidget {
  const PaginaSensor({super.key});

  @override
  State<PaginaSensor> createState() =>
      _PaginaSensorState();
}

class _PaginaSensorState
    extends State<PaginaSensor> {

  double x = 0;
  double y = 0;
  double z = 0;

  double mouseX = 0;
  double mouseY = 0;

  bool movimento = false;

  bool aviso = true;

  StreamSubscription? sensor;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {

      sensor =
          accelerometerEventStream().listen(
        (dados) {

          atualizarValores(
            dados.x,
            dados.y,
            dados.z,
          );
        },
      );
    }
  }

  void atualizarValores(
    double novoX,
    double novoY,
    double novoZ,
  ) {

    bool detectado =
        novoX.abs() > 8;

    setState(() {
      x = novoX;
      y = novoY;
      z = novoZ;
      movimento = detectado;
    });

    if (detectado) {
      mostrarMensagem();
    }
  }

  void mostrarMensagem() {

    if (!aviso) return;

    aviso = false;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Movimento Detectado',
        ),
      ),
    );

    Future.delayed(
      const Duration(seconds: 2),
      () {
        aviso = true;
      },
    );
  }

  void moverMouse(PointerEvent event) {

    double dx =
        event.position.dx - mouseX;

    double dy =
        event.position.dy - mouseY;

    atualizarValores(
      dx,
      dy,
      0,
    );

    mouseX = event.position.dx;
    mouseY = event.position.dy;
  }

  @override
  void dispose() {
    sensor?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onHover:
          kIsWeb ? moverMouse : null,

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detector de Movimento',
          ),
        ),

        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Text(
                'X: ${x.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              Text(
                'Y: ${y.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              Text(
                'Z: ${z.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              movimento
                  ? const Text(
                      'MOVIMENTO DETECTADO',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.red,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}