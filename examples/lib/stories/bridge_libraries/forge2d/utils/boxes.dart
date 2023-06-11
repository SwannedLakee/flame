import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Box extends BodyComponent {
  final Vector2 startPosition;
  final double width;
  final double height;
  final BodyType bodyType;

  Box({
    required this.startPosition,
    required this.width,
    required this.height,
    this.bodyType = BodyType.dynamic,
    Color? color,
  }) {
    if (color != null) {
      paint = PaletteEntry(color).paint();
    } else {
      paint = randomPaint();
    }
  }

  Paint randomPaint() => PaintExtension.random(withAlpha: 0.9, base: 100);

  @override
  Body createBody() {
    final shape = PolygonShape()
      ..setAsBox(width / 2, height / 2, Vector2.zero(), 0);
    final fixtureDef = FixtureDef(shape, friction: 0.3, density: 10);
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: startPosition,
      type: bodyType,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class DraggableBox extends Box with DragCallbacks {
  MouseJoint? mouseJoint;
  late final groundBody = world.createBody(BodyDef());

  DraggableBox({
    required super.startPosition,
    required super.width,
    required super.height,
  });

  @override
  bool onDragUpdate(DragUpdateEvent info) {
    final mouseJointDef = MouseJointDef()
      ..maxForce = 3000 * body.mass * 10
      ..dampingRatio = 0
      ..frequencyHz = 20
      ..target.setFrom(info.localPosition)
      ..collideConnected = false
      ..bodyA = groundBody
      ..bodyB = body;

    if (mouseJoint == null) {
      mouseJoint = MouseJoint(mouseJointDef);
      world.createJoint(mouseJoint!);
    }

    mouseJoint?.setTarget(info.localPosition);
    return false;
  }

  @override
  void onDragEnd(DragEndEvent info) {
    super.onDragEnd(info);
    if (mouseJoint == null) {
      return;
    }
    world.destroyJoint(mouseJoint!);
    mouseJoint = null;
    info.continuePropagation = false;
  }
}
