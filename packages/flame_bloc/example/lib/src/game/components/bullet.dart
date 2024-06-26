import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc_example/src/game/components/enemy.dart';
import 'package:flame_bloc_example/src/game/game.dart';
import 'package:flame_bloc_example/src/inventory/bloc/inventory_bloc.dart';

class BulletComponent extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  static const bulletSpeed = -500;

  bool destroyed = false;

  double xDirection;

  final Weapon weapon;

  BulletComponent(
    double x,
    double y,
    this.weapon, {
    this.xDirection = 0.0,
  }) : super(position: Vector2(x, y)) {
    size = Vector2(_mapWidth(), 20);

    add(RectangleHitbox());
  }

  double _mapWidth() {
    return switch (weapon) {
      Weapon.bullet => 10,
      Weapon.laser || Weapon.plasma => 5,
    };
  }

  String _mapSpritePath() {
    return switch (weapon) {
      Weapon.bullet => 'bullet.png',
      Weapon.laser => 'laser.png',
      Weapon.plasma => 'plasma.png',
    };
  }

  double _mapSpriteWidth() {
    return switch (weapon) {
      Weapon.bullet => 8,
      Weapon.laser || Weapon.plasma => 4,
    };
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await game.loadSpriteAnimation(
      _mapSpritePath(),
      SpriteAnimationData.sequenced(
        stepTime: 0.2,
        amount: 4,
        textureSize: Vector2(_mapSpriteWidth(), 16),
      ),
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is EnemyComponent) {
      destroyed = true;
      other.takeHit();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    y += bulletSpeed * dt;
    if (xDirection != 0) {
      x += bulletSpeed * dt * xDirection;
    }

    if (destroyed || toRect().bottom <= 0) {
      removeFromParent();
    }
  }
}
