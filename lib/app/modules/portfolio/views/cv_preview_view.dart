import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'cv_templates_view.dart';

class CvPreviewView extends StatefulWidget {
  @override
  _CvPreviewViewState createState() => _CvPreviewViewState();
}

class _CvPreviewViewState extends State<CvPreviewView> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CV Preview'),
        actions: [
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () => setState(() => _scale += 0.1),
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: () => setState(() => _scale = _scale > 0.2 ? _scale - 0.1 : 0.1),
          ),
          IconButton(
            icon: Icon(Icons.zoom_out_map),
            onPressed: () => setState(() => _scale = 1.0),
          ),
        ],
      ),
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          _previousScale = _scale;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _scale = _previousScale * details.scale;
          });
        },
        child: Transform.scale(
          scale: _scale,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: SingleChildScrollView(
              child: CvTemplatesView(), // Reuse the template view
            ),
          ),
        ),
      ),
    );
  }
}