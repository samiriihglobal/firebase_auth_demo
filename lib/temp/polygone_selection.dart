import 'package:flutter/material.dart';

class PolygonImageSelectionPage extends StatefulWidget {
  @override
  _PolygonImageSelectionPageState createState() =>
      _PolygonImageSelectionPageState();
}

class _PolygonImageSelectionPageState extends State<PolygonImageSelectionPage> {
  static const double pointHitRadius = 15.0;
  static const double snapDistance = 20.0;

  MouseCursor currentCursor = SystemMouseCursors.precise;

  // ✅ MULTI POLYGONS
  List<PolygonData> polygons = [];

  // ✅ CURRENT DRAWING
  List<Offset> currentPoints = [];
  bool isDrawing = false;
  bool isSnapping = false;
  Offset? previewPoint;
  int? draggingPointIndex;

  // ✅ HOVER
  PolygonData? hoveredPolygon;
  Offset? hoverPosition;

  @override
  void dispose() {
    super.dispose();
  }

  // =========================
  // POINT IN POLYGON
  // =========================
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

  bool get isPolygonClosed => false; // we now rely on saved polygons

  // =========================
  // RESET
  // =========================
  void resetPolygon() {
    setState(() {
      polygons.clear();
      currentPoints.clear();
      previewPoint = null;
      hoveredPolygon = null;
      isDrawing = false;
    });
  }

  // =========================
  // BUILD
  // =========================
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

          // =========================
          // MOUSE REGION
          // =========================
          MouseRegion(
            cursor: currentCursor,
            onHover: (event) {
              final hoverPos = event.localPosition;

              PolygonData? foundPolygon;

              // ✅ check saved polygons
              for (final poly in polygons) {
                if (isPointInPolygon(hoverPos, poly.points)) {
                  foundPolygon = poly;
                  break;
                }
              }

              bool hoveringPoint = false;

              // ✅ check draggable points (current polygon)
              for (var point in currentPoints) {
                if ((hoverPos - point).distance < pointHitRadius) {
                  hoveringPoint = true;
                  break;
                }
              }

              setState(() {
                hoveredPolygon = foundPolygon;
                hoverPosition = hoverPos;
                previewPoint = hoverPos;

                // cursor logic
                if (draggingPointIndex != null) {
                  currentCursor = SystemMouseCursors.grabbing;
                } else if (hoveringPoint) {
                  currentCursor = SystemMouseCursors.grab;
                } else {
                  currentCursor = SystemMouseCursors.precise;
                }

                // snapping logic
                if (currentPoints.isNotEmpty) {
                  final distance =
                      (hoverPos - currentPoints.first).distance;
                  isSnapping =
                      distance < snapDistance && currentPoints.length >= 3;
                } else {
                  isSnapping = false;
                }
              });
            },

            // =========================
            // GESTURES
            // =========================
            child: GestureDetector(
              onTapUp: (details) {
                final tapPosition = details.localPosition;

                // snap to close
                if (isSnapping && currentPoints.length >= 3) {
                  _showDetailsDialog();
                  return;
                }

                // add point
                setState(() {
                  currentPoints.add(tapPosition);
                });
              },

              onPanStart: (details) {
                final touchPosition = details.localPosition;

                for (int i = 0; i < currentPoints.length; i++) {
                  if ((touchPosition - currentPoints[i]).distance <
                      pointHitRadius) {
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
                    currentPoints[draggingPointIndex!] += details.delta;
                  });
                }
              },

              onPanEnd: (_) {
                draggingPointIndex = null;

                setState(() {
                  currentCursor = SystemMouseCursors.precise;
                });
              },

              // =========================
              // PAINTER
              // =========================
              child: CustomPaint(
                size: Size.infinite,
                painter: PolygonPainter(
                  polygons: polygons,
                  currentPoints: currentPoints,
                  previewPoint: previewPoint,
                  isSnapping: isSnapping,
                  snapDistance: snapDistance,
                ),
              ),
            ),
          ),

          // =========================
          // RESET BUTTON
          // =========================
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: resetPolygon,
              child: const Text("Reset"),
            ),
          ),

          // =========================
          // TOOLTIP
          // =========================
          if (hoveredPolygon != null && hoverPosition != null)
            Positioned(
              left: hoverPosition!.dx + 12,
              top: hoverPosition!.dy + 12,
              child: IgnorePointer(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hoveredPolygon!.details.isNotEmpty)
                          Text(
                            hoveredPolygon!.details,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (hoveredPolygon!.prompt.isNotEmpty)
                          Text(
                            hoveredPolygon!.prompt,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
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

  // =========================
  // SAVE DIALOG
  // =========================
  void _showDetailsDialog() {
    final detailsController = TextEditingController();
    final promptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Save Region",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: detailsController,
                  decoration: const InputDecoration(
                    labelText: "Details",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: promptController,
                  decoration: const InputDecoration(
                    labelText: "Prompt",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          polygons.add(
                            PolygonData(
                              points: List.from(currentPoints),
                              details: detailsController.text.trim(),
                              prompt: promptController.text.trim(),
                            ),
                          );

                          currentPoints.clear();
                          previewPoint = null;
                          isDrawing = false;
                        });

                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================
// PAINTER
// =========================
class PolygonPainter extends CustomPainter {
  final List<PolygonData> polygons;
  final List<Offset> currentPoints;
  final Offset? previewPoint;
  final bool isSnapping;
  final double snapDistance;

  PolygonPainter({
    required this.polygons,
    required this.currentPoints,
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
      ..color = Colors.blue.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    // ===============================
    // ✅ DRAW SAVED POLYGONS
    // ===============================
    for (final poly in polygons) {
      if (poly.points.length < 3) continue;

      final path = Path()
        ..moveTo(poly.points.first.dx, poly.points.first.dy);

      for (int i = 1; i < poly.points.length; i++) {
        path.lineTo(poly.points[i].dx, poly.points[i].dy);
      }

      path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, linePaint);
    }

    // ===============================
    // ✅ CURRENT POLYGON DRAWING
    // ===============================
    if (currentPoints.isEmpty) {
      // preview point only
      if (previewPoint != null) {
        canvas.drawCircle(
          previewPoint!,
          6,
          Paint()..color = Colors.green,
        );
      }
      return;
    }

    final path =
    Path()..moveTo(currentPoints.first.dx, currentPoints.first.dy);

    for (int i = 1; i < currentPoints.length; i++) {
      path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
    }

    // preview edge
    if (previewPoint != null) {
      path.lineTo(previewPoint!.dx, previewPoint!.dy);
    }

    // ===============================
    // 🔵 DYNAMIC FILL (LIVE)
    // ===============================
    int effectiveCount =
        currentPoints.length + (previewPoint != null ? 1 : 0);

    if (effectiveCount >= 3) {
      canvas.drawPath(path, fillPaint);
    }

    // outline
    canvas.drawPath(path, linePaint);

    // ===============================
    // 🟡 SNAP RADIUS CIRCLE
    // ===============================
    canvas.drawCircle(
      currentPoints.first,
      snapDistance,
      Paint()
        ..color = Colors.yellow.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ===============================
    // 🔴 CONFIRMED POINTS
    // ===============================
    for (int i = 0; i < currentPoints.length; i++) {
      final point = currentPoints[i];

      final paint = Paint()
        ..color = (i == 0 && isSnapping)
            ? Colors.yellow
            : Colors.red;

      canvas.drawCircle(point, 6, paint);
    }

    // ===============================
    // 🟢 PREVIEW POINT
    // ===============================
    if (previewPoint != null) {
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

// =========================
// DATA
// =========================
class PolygonData {
  List<Offset> points;
  String details;
  String prompt;

  PolygonData({
    required this.points,
    required this.details,
    required this.prompt,
  });
}