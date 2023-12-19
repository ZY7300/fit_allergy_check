import 'dart:io';

import 'package:camera/camera.dart';
import 'package:fit_allergy_check/model/allergen.dart';
import 'package:fit_allergy_check/model/overweight.dart';
import 'package:fit_allergy_check/model/underweight.dart';
import 'package:fit_allergy_check/pages/result_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanPage extends StatefulWidget {
  final String title;
  final List<Allergen>? allerLists;
  final List<Underweight>? underwLists;
  final List<Overweight>? overwLists;

  const ScanPage(
      {Key? key,
      required this.title,
      this.allerLists,
      this.underwLists,
      this.overwLists})
      : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  bool scanningInProgress = false;

  late final Future<void> _future;

  CameraController? _cameraController;

  final _textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();

    if (widget.allerLists != null) {
      for (var allergen in widget.allerLists!) {
        if (allergen.isSelected == true) {
          print('allergen selected ${allergen.allerName}');
        }
      }
    }

    if (widget.underwLists != null) {
      for (var underweight in widget.underwLists!) {
        if (underweight.isSelected == true) {
          print('underweight selected ${underweight.underwName}');
        }
      }
    }

    if (widget.overwLists != null) {
      for (var overweight in widget.overwLists!) {
        if (overweight.isSelected == true) {
          print('overweight selected ${overweight.overwName}');
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          return Stack(
            children: [
              if (_isPermissionGranted)
                FutureBuilder<List<CameraDescription>>(
                    future: availableCameras(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        _initCameraController(snapshot.data!);

                        return Center(
                          child: CameraPreview(_cameraController!),
                        );
                      } else {
                        return const LinearProgressIndicator();
                      }
                    }),
              Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                backgroundColor:
                    _isPermissionGranted ? Colors.transparent : null,
                body: _isPermissionGranted
                    ? Column(
                        children: [
                          Expanded(child: Container()),
                          Container(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: Center(
                              child: ElevatedButton(
                                  onPressed:
                                      scanningInProgress ? null : _scanImage,
                                  child: scanningInProgress
                                      ? const CircularProgressIndicator()
                                      : const Text('Scan Text')),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Container(
                          padding:
                              const EdgeInsets.only(left: 24.0, right: 24.0),
                          child: const Text(
                            'Camera permission denied',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              )
            ],
          );
        });
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    CameraDescription? camera;

    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
        cameraDescription, ResolutionPreset.max,
        enableAudio: false);

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    setState(() {
      scanningInProgress = true;
    });

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);

      final recognizedText = await _textRecognizer.processImage(inputImage);

      await Get.to(ResultPage(
        result: recognizedText.text,
        allergenLists: widget.allerLists,
        underwLists: widget.underwLists,
        overwLists: widget.overwLists,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred when scanning text')));
    } finally {
      setState(() {
        scanningInProgress = false;
      });
    }
  }
}
