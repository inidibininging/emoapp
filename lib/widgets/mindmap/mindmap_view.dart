import 'dart:math';
import 'package:emoapp/view_model/mindmap_view_model.dart';
import 'package:emoapp/widgets/mindmap/idea_node_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Main mindmap canvas widget with zoom and pan support
class MindmapView extends StatefulWidget {
  const MindmapView({
    Key? key,
    this.onCreateIdea,
    this.ownerUuid = '',
  }) : super(key: key);

  final Function(double x, double y)? onCreateIdea;
  final String ownerUuid;

  @override
  State<MindmapView> createState() => _MindmapViewState();
}

class _MindmapViewState extends State<MindmapView> {
  late TransformationController _transformationController;
  Offset? _tapDownPosition;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _tapDownPosition = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details, MindmapViewModel viewModel) {
    // Update pan offset from drag delta
    viewModel.panOffset = viewModel.panOffset + details.focalPointDelta;

    // Update zoom from pinch scale
    if (details.scale != 1.0) {
      final newZoom = viewModel.zoomLevel * details.scale;
      viewModel.zoomLevel = newZoom.clamp(0.1, 3.0);
    }
  }

  void _onTapDown(TapDownDetails details, MindmapViewModel viewModel) {
    // Convert screen coordinates to canvas coordinates
    final localPosition = details.localPosition - viewModel.panOffset;
    final canvasX = localPosition.dx / viewModel.zoomLevel;
    final canvasY = localPosition.dy / viewModel.zoomLevel;

    // Check if tapped on an existing idea
    bool tappedOnIdea = false;
    for (final idea in viewModel.ideas) {
      final dx = idea.positionX - canvasX;
      final dy = idea.positionY - canvasY;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance <= 40) {
        tappedOnIdea = true;
        viewModel.selectIdea(idea);
        break;
      }
    }

    // If didn't tap on an idea and onCreateIdea is provided, create new idea
    if (!tappedOnIdea && widget.onCreateIdea != null) {
      widget.onCreateIdea!(canvasX, canvasY);
    }
  }

  void _onDoubleTap(MindmapViewModel viewModel) {
    if (viewModel.selectedIdea != null) {
      viewModel.startEditing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MindmapViewModel>(
      builder: (context, viewModel, _) => GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: (details) => _onScaleUpdate(details, viewModel),
        onTapDown: (details) => _onTapDown(details, viewModel),
        onDoubleTap: () => _onDoubleTap(viewModel),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Canvas background
            Container(
              color: Colors.grey[100],
              child: CustomPaint(
                painter: _MindmapCanvasPainter(
                  zoomLevel: viewModel.zoomLevel,
                  panOffset: viewModel.panOffset,
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translate(viewModel.panOffset.dx, viewModel.panOffset.dy)
                    ..scale(viewModel.zoomLevel),
                  child: SizedBox(
                    width: 10000,
                    height: 10000,
                    child: GestureDetector(
                      onLongPressStart: (details) {
                        // Convert screen coordinates to canvas coordinates
                        // We must undo the Transform that was applied to parent widgets
                        final screenPos = details.globalPosition;
                        final renderBox =
                            context.findRenderObject() as RenderBox;
                        final localPos = renderBox.globalToLocal(screenPos);

                        final canvasX = (localPos.dx - viewModel.panOffset.dx) /
                            viewModel.zoomLevel;
                        final canvasY = (localPos.dy - viewModel.panOffset.dy) /
                            viewModel.zoomLevel;

                        viewModel.deselectIdea();
                        for (final idea in viewModel.ideas) {
                          final dx = idea.positionX - canvasX;
                          final dy = idea.positionY - canvasY;
                          final distance = sqrt(dx * dx + dy * dy);

                          if (distance <= 45) {
                            viewModel.startMovingIdea(idea);
                            break;
                          }
                        }
                      },
                      onLongPressMoveUpdate: (details) {
                        if (viewModel.movingIdea != null) {
                          final screenPos = details.globalPosition;
                          final renderBox =
                              context.findRenderObject() as RenderBox;
                          final localPos = renderBox.globalToLocal(screenPos);

                          final canvasX =
                              (localPos.dx - viewModel.panOffset.dx) /
                                  viewModel.zoomLevel;
                          final canvasY =
                              (localPos.dy - viewModel.panOffset.dy) /
                                  viewModel.zoomLevel;
                          viewModel.updateMovingIdeaPosition(canvasX, canvasY);
                        }
                      },
                      onLongPressEnd: (details) async {
                        await viewModel.stopMovingIdea();
                      },
                      child: Stack(
                        children: [
                          // Draw connection lines between ideas
                          CustomPaint(
                            painter: _IdeaConnectionsPainter(
                              ideas: viewModel.ideas,
                            ),
                            size: Size.infinite,
                          ),
                          // Draw idea nodes
                          ...viewModel.ideas.map((idea) {
                            return Positioned(
                              left: idea.positionX - 40,
                              top: idea.positionY - 40,
                              child: GestureDetector(
                                onTap: () => viewModel.selectIdea(idea),
                                child: IdeaNodeWidget(
                                  idea: idea,
                                  isSelected:
                                      viewModel.selectedIdea?.id == idea.id,
                                  isMoving: viewModel.movingIdea?.id == idea.id,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Top toolbar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Zoom controls
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.zoom_out),
                          onPressed: viewModel.zoomOut,
                        ),
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(
                              '${(viewModel.zoomLevel * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.zoom_in),
                          onPressed: viewModel.zoomIn,
                        ),
                        const VerticalDivider(width: 1),
                        IconButton(
                          icon: const Icon(Icons.restart_alt),
                          onPressed: () {
                            viewModel.resetZoom();
                            viewModel.resetPan();
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Selection info
                  if (viewModel.selectedIdea != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        viewModel.selectedIdea!.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the mindmap canvas grid
class _MindmapCanvasPainter extends CustomPainter {
  final double zoomLevel;
  final Offset panOffset;

  _MindmapCanvasPainter({
    required this.zoomLevel,
    required this.panOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gridSize = 50.0;
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    // Draw vertical lines
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += gridSize;
    }

    // Draw horizontal lines
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += gridSize;
    }
  }

  @override
  bool shouldRepaint(_MindmapCanvasPainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.panOffset != panOffset;
  }
}

/// Custom painter for drawing connections between ideas
class _IdeaConnectionsPainter extends CustomPainter {
  final List<dynamic> ideas;

  _IdeaConnectionsPainter({required this.ideas});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2;

    // Draw lines from each idea to its references
    for (final idea in ideas) {
      try {
        // Safely access references
        final references = idea.references ?? [];
        for (final reference in references) {
          // Find the referenced idea
          dynamic? referencedIdea;
          try {
            referencedIdea = ideas.firstWhere(
              (i) => i.id == reference.ideaUuid,
            );
          } catch (e) {
            continue;
          }

          if (referencedIdea != null &&
              referencedIdea.positionX != null &&
              referencedIdea.positionY != null &&
              idea.positionX != null &&
              idea.positionY != null) {
            canvas.drawLine(
              Offset(idea.positionX, idea.positionY),
              Offset(referencedIdea.positionX, referencedIdea.positionY),
              paint,
            );
          }
        }
      } catch (e) {
        debugPrint('Error drawing connection for idea: $e');
        continue;
      }
    }
  }

  @override
  bool shouldRepaint(_IdeaConnectionsPainter oldDelegate) {
    // Repaint if number of ideas changed
    if (oldDelegate.ideas.length != ideas.length) {
      return true;
    }
    // Repaint if any idea's position or references changed
    for (int i = 0; i < ideas.length; i++) {
      final oldIdea = oldDelegate.ideas[i];
      final newIdea = ideas[i];
      if (oldIdea.positionX != newIdea.positionX ||
          oldIdea.positionY != newIdea.positionY ||
          oldIdea.references.length != newIdea.references.length) {
        return true;
      }
    }
    return false;
  }
}
