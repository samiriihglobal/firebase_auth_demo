import 'package:flutter/material.dart';

class PolygonImageSelectionPage extends StatefulWidget {
  @override
  _PolygonImageSelectionPageState createState() =>
      _PolygonImageSelectionPageState();
}

class _PolygonImageSelectionPageState extends State<PolygonImageSelectionPage> {
  List<Offset> polygonPoints = [];
  bool isPolygonClosed = false;
  Offset? previewPoint;
  int? draggingPointIndex;
  static const double pointHitRadius = 15.0;

  static const double snapDistance = 20.0;
  MouseCursor currentCursor = SystemMouseCursors.precise;


  bool isSnapping = false;

  void resetPolygon() {
    setState(() {
      polygonPoints.clear();
      isPolygonClosed = false;
      previewPoint = null;
      isSnapping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Professional Polygon Lasso")),
      body: Stack(
        children: [
          Image.network(
            'https://picsum.photos/400/400',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          MouseRegion(
            cursor: MouseCursor.uncontrolled,
            onHover: (event) {

              final hoverPosition = event.localPosition;

              bool hoveringPoint = false;

              for (var point in polygonPoints) {
                if ((hoverPosition - point).distance < pointHitRadius) {
                  hoveringPoint = true;
                  break;
                }
              }
              if (isPolygonClosed) return;


              // Check if hovering over an existing point
              for (var point in polygonPoints) {
                if ((hoverPosition - point).distance < pointHitRadius) {
                  hoveringPoint = true;
                  break;
                }
              }

              setState(() {
                previewPoint = hoverPosition;

                // Cursor logic
                if (draggingPointIndex != null) {
                  // Already dragging → grabbing
                  currentCursor = SystemMouseCursors.grabbing;
                } else if (hoveringPoint) {
                  // Hover over point → show grab
                  currentCursor = SystemMouseCursors.grab;
                } else {
                  // Default adding cursor
                  currentCursor = SystemMouseCursors.precise;
                }

                // Snapping logic
                if (polygonPoints.isNotEmpty) {
                  final distance =
                      (previewPoint! - polygonPoints.first).distance;
                  isSnapping =
                      distance < snapDistance && polygonPoints.length >= 3;
                } else {
                  isSnapping = false;
                }
              });
            },
            child: GestureDetector(

            onTapUp: (details) {
                if (isPolygonClosed) return;

                final tapPosition = details.localPosition;

                // Snap close
                if (isSnapping) {
                  setState(() {
                    isPolygonClosed = true;
                    previewPoint = null;
                    isSnapping = false;
                  });
                  showDialog(context: context, builder: (context)=>Center(
                    child: Material(
                      child: Container(
                        height: 400 ,
                        width: 500,
                        decoration: BoxDecoration(

                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: [
                              Spacer(),
                              Text("Enter the details"),
                              SizedBox(height: 20,),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "details",
                                ),
                              ),
                              Spacer(),
                              Text("Enter the prompt"),
                              SizedBox(height: 20,),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "prompt",
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),

                      ),
                    ),
                  ));
                  return;
                }

                // Add new point
                setState(() {
                  polygonPoints.add(tapPosition);
                });
              },

              onPanStart: (details) {
                final touchPosition = details.localPosition;

                for (int i = 0; i < polygonPoints.length; i++) {
                  if ((touchPosition - polygonPoints[i]).distance < pointHitRadius) {
                    draggingPointIndex = i;

                    setState(() {
                      currentCursor = SystemMouseCursors.grabbing;
                    });

                    return;
                  }
                }
              },

              onPanUpdate: (details) {
                if (draggingPointIndex != null) {
                  setState(() {
                    polygonPoints[draggingPointIndex!] += details.delta;
                  });
                }
              },

              onPanEnd: (_) {
                draggingPointIndex = null;

                setState(() {
                  currentCursor = SystemMouseCursors.basic;
                });
              },


              child: CustomPaint(
                size: Size.infinite,
                painter: PolygonPainter(
                  polygonPoints: polygonPoints,
                  isPolygonClosed: isPolygonClosed,
                  previewPoint: previewPoint,
                  isSnapping: isSnapping,
                  snapDistance: snapDistance,
                ),
              ),
            ),

          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: resetPolygon,
              child: const Text("Reset"),
            ),
          ),
        ],
      ),
    );
  }
}

class PolygonPainter extends CustomPainter {
  final List<Offset> polygonPoints;
  final bool isPolygonClosed;
  final Offset? previewPoint;
  final bool isSnapping;
  final double snapDistance;

  PolygonPainter({
    required this.polygonPoints,
    required this.isPolygonClosed,
    required this.previewPoint,
    required this.isSnapping,
    required this.snapDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    if (polygonPoints.isEmpty) {
      if (previewPoint != null) {
        canvas.drawCircle(previewPoint!, 5, Paint()..color = Colors.green);
      }
      return;
    }

    final path = Path()..moveTo(polygonPoints[0].dx, polygonPoints[0].dy);

    // Draw lines between confirmed points
    for (int i = 1; i < polygonPoints.length; i++) {
      path.lineTo(polygonPoints[i].dx, polygonPoints[i].dy);
    }

    // Add preview edge
    if (!isPolygonClosed && previewPoint != null) {
      path.lineTo(previewPoint!.dx, previewPoint!.dy);
    }

    // Fill dynamically
    int effectiveCount =
        polygonPoints.length + (!isPolygonClosed && previewPoint != null ? 1 : 0);

    if (effectiveCount >= 3) {
      if (isPolygonClosed) {
        path.close();
      }
      canvas.drawPath(path, fillPaint);
    }

    // Draw outline
    canvas.drawPath(path, linePaint);

    // Draw snap radius indicator
    if (!isPolygonClosed && polygonPoints.isNotEmpty) {
      canvas.drawCircle(
        polygonPoints.first,
        snapDistance,
        Paint()
          ..color = Colors.yellow.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Draw confirmed points
    for (int i = 0; i < polygonPoints.length; i++) {
      final point = polygonPoints[i];

      final paint = Paint()
        ..color = (i == 0 && isSnapping && !isPolygonClosed)
            ? Colors.yellow
            : Colors.red;

      canvas.drawCircle(point, 6, paint);
    }

    // Draw preview point
    if (previewPoint != null && !isPolygonClosed) {
      canvas.drawCircle(
        previewPoint!,
        6,
        Paint()..color = isSnapping ? Colors.yellow : Colors.green,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
