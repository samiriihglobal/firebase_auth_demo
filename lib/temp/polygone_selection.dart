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

  final TextEditingController detailsController = TextEditingController();
  final TextEditingController promptController = TextEditingController();

  bool isHoveringInsidePolygon = false;
  Offset? hoverPosition;

  String? savedDetails;
  String? savedPrompt;

  @override
  void dispose() {
    detailsController.dispose();
    promptController.dispose();
    super.dispose();
  }


  bool isSnapping = false;

  void resetPolygon() {
    setState(() {
      polygonPoints.clear();
      isPolygonClosed = false;
      previewPoint = null;
      isSnapping = false;
    });
  }

  bool isPointInPolygon(Offset point, List<Offset> polygon) {
    if (polygon.length < 3) return false;

    int intersectCount = 0;

    for (int j = 0; j < polygon.length; j++) {
      final p1 = polygon[j];
      final p2 = polygon[(j + 1) % polygon.length];

      if ((p1.dy > point.dy) != (p2.dy > point.dy)) {
        final x = (p2.dx - p1.dx) * (point.dy - p1.dy) / (p2.dy - p1.dy) + p1.dx;
        if (point.dx < x) intersectCount++;
      }
    }

    return (intersectCount % 2) == 1;
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
              final hoverPos = event.localPosition;

              bool hoveringPoint = false;

              for (var point in polygonPoints) {
                if ((hoverPos - point).distance < pointHitRadius) {
                  hoveringPoint = true;
                  break;
                }
              }

              if (isPolygonClosed) {
                setState(() {
                  hoverPosition = hoverPos;
                  isHoveringInsidePolygon =
                      isPointInPolygon(hoverPos, polygonPoints);
                });
              }

              // 👇 keep your existing logic below
              if (isPolygonClosed) return;

              setState(() {
                previewPoint = hoverPos;

                if (draggingPointIndex != null) {
                  currentCursor = SystemMouseCursors.grabbing;
                } else if (hoveringPoint) {
                  currentCursor = SystemMouseCursors.grab;
                } else {
                  currentCursor = SystemMouseCursors.precise;
                }

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

            onTapUp: (details) async {
                if (isPolygonClosed) return;

                final tapPosition = details.localPosition;

                // Snap close
                if (isSnapping) {
                  setState(() {
                    isPolygonClosed = true;
                    previewPoint = null;
                    isSnapping = false;
                  });
                  await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        width: 420,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Add Region Details",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 24),

                            TextFormField(
                              controller: detailsController,
                              decoration: InputDecoration(
                                labelText: "Details",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.description),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: promptController,
                              decoration: InputDecoration(
                                labelText: "Prompt",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.auto_awesome),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      resetPolygon();
                                      detailsController.clear();
                                      promptController.clear();
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final details = detailsController.text.trim();
                                      final prompt = promptController.text.trim();

                                      debugPrint("DETAILS: $details");
                                      debugPrint("PROMPT: $prompt");

                                      setState(() {
                                        savedDetails = details;
                                        savedPrompt = prompt;
                                      });


                                      Navigator.pop(context);

                                      // 🔥 optional: clear after save
                                      detailsController.clear();
                                      promptController.clear();
                                    },
                                    child: const Text("Save"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  );
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
          if (isPolygonClosed &&
              isHoveringInsidePolygon &&
              hoverPosition != null)
            Positioned(
              left: hoverPosition!.dx + 12,
              top: hoverPosition!.dy + 12,
              child: IgnorePointer(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (savedDetails != null && savedDetails!.isNotEmpty)
                          Text(
                            savedDetails!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (savedPrompt != null && savedPrompt!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            savedPrompt!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
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
