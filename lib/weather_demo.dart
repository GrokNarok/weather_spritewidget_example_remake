import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'weather_button.dart';

enum WeatherType { sun, rain, snow }

class WeatherDemo extends StatefulWidget {
  WeatherDemo({Key? key}) : super(key: key);

  @override
  _WeatherDemoState createState() => _WeatherDemoState();
}

class _WeatherDemoState extends State<WeatherDemo> {
  WeatherType weatherType = WeatherType.sun;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${MediaQuery.of(context).size.width} / ${MediaQuery.of(context).size.height}')),
      body: Material(
        child: Stack(
          children: <Widget>[
            Weather(weatherType: weatherType),
            Align(
              alignment: FractionalOffset(0.5, 0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  WeatherButton(
                    onPressed: () => setState(() => weatherType = WeatherType.sun),
                    selected: weatherType == WeatherType.sun,
                    icon: "assets/icon-sun.png",
                  ),
                  WeatherButton(
                    onPressed: () => setState(() => weatherType = WeatherType.rain),
                    selected: weatherType == WeatherType.rain,
                    icon: "assets/icon-rain.png",
                  ),
                  WeatherButton(
                    onPressed: () => setState(() => weatherType = WeatherType.snow),
                    selected: weatherType == WeatherType.snow,
                    icon: "assets/icon-snow.png",
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

class Weather extends StatelessWidget {
  final WeatherType weatherType;

  const Weather({Key? key, required this.weatherType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Background(weatherType: weatherType),
        Cloud(imageAsset: 'assets/clouds-0.png', rotated: false, dark: false, loopTime: Duration(seconds: 20)),
        Cloud(imageAsset: 'assets/clouds-1.png', rotated: true, dark: true, loopTime: Duration(seconds: 40), visible: weatherType == WeatherType.rain),
        Cloud(imageAsset: 'assets/clouds-1.png', rotated: false, dark: false, loopTime: Duration(seconds: 60)),
        Sun(visible: weatherType == WeatherType.sun),
        Rain(visible: weatherType == WeatherType.rain),
        Snow(visible: weatherType == WeatherType.snow),
      ],
    );
  }
}

// For the different weathers we are displaying different gradient backgrounds,
// these are the colors for top and bottom.
const List<Color> _kBackgroundColorsTop = const <Color>[const Color(0xff5ebbd5), const Color(0xff0b2734), const Color(0xffcbced7)];
const List<Color> _kBackgroundColorsBottom = const <Color>[const Color(0xff4aaafb), const Color(0xff4c5471), const Color(0xffe0e3ec)];

class Background extends StatelessWidget {
  final WeatherType weatherType;

  const Background({Key? key, required this.weatherType}) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kBackgroundColorsTop[weatherType.index], _kBackgroundColorsBottom[weatherType.index]],
          ),
        ),
        duration: Duration(milliseconds: 1000),
      );
}

class Cloud extends StatefulWidget {
  final String imageAsset;
  final Duration loopTime;
  final bool rotated;
  final bool dark;
  final bool visible;

  const Cloud({
    Key? key,
    required this.imageAsset,
    required this.loopTime,
    this.rotated = false,
    this.dark = false,
    this.visible = true,
  }) : super(key: key);

  @override
  _CloudState createState() => _CloudState();
}

class _CloudState extends State<Cloud> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.loopTime, vsync: this);
    animation = Tween<double>(begin: 0, end: -2048.0).animate(controller);
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: widget.visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 1000),
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, child) => Stack(
            children: [
              Positioned(
                left: animation.value,
                child: child!,
              ),
            ],
          ),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(widget.rotated ? math.pi : 0),
            child: Row(
              children: [
                Image.asset(widget.imageAsset, color: widget.dark ? Color(0xff000000) : null, colorBlendMode: BlendMode.srcATop),
                Image.asset(widget.imageAsset, color: widget.dark ? Color(0xff000000) : null, colorBlendMode: BlendMode.srcATop),
              ],
            ),
          ),
        ),
      );
}

const _kNumSunRays = 50;

class Sun extends ImplicitlyAnimatedWidget {
  final bool visible;

  const Sun({
    Key? key,
    required this.visible,
  }) : super(
          key: key,
          duration: visible ? const Duration(milliseconds: 3000) : const Duration(milliseconds: 200),
          curve: visible ? const Interval(0.5, 1.0) : Curves.linear,
        );

  @override
  _SunState createState() => _SunState();
}

class _SunState extends ImplicitlyAnimatedWidgetState<Sun> {
  Tween<double>? _opacity;
  late Animation<double> _opacityAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _opacity = visitor(
      _opacity,
      widget.visible ? 1.0 : 0.0,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  void didUpdateTweens() {
    _opacityAnimation = animation.drive(_opacity!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -180,
          left: -140,
          child: AnimatedOpacity(
            opacity: widget.visible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 1500),
            child: Transform.scale(
              scale: 2.0,
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(<double>[
                  1, 0, 0, 0, 114, // Do some color finagling to more or less replicate the effect of
                  0, 1, 0, 0, 207, // image's BlendMode.plus from the original implementation
                  0, 0, 1, 0, 233, //
                  0, 0, 0, 1.7, -50
                ]),
                child: Image.asset('assets/sun.png'),
              ),
            ),
          ),
        ),
        ...List.generate(
          _kNumSunRays,
          (index) => Positioned(
            top: 72,
            left: 116,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Ray(),
            ),
          ),
        ),
      ],
    );
  }
}

class Ray extends StatefulWidget {
  @override
  _RayState createState() => _RayState();
}

class _RayState extends State<Ray> with TickerProviderStateMixin {
  late Animation<double> rotationAnimation;
  late AnimationController rotationController;
  late Animation<double> scaleAnimation;
  late AnimationController scaleController;

  final opacity = 0.25 + (randomDouble() * 0.25);

  @override
  void initState() {
    super.initState();

    final rotationDuration = ((60 + randomDouble() * 540) * 1000).floor();
    final startingRotation = randomDouble() * 2.0;
    final finalRotation = startingRotation + (randomBool() ? 2.0 : -2.0); // +/- full rotation
    rotationController = AnimationController(duration: Duration(milliseconds: rotationDuration), vsync: this);
    rotationAnimation = Tween<double>(begin: startingRotation, end: finalRotation).animate(rotationController);
    rotationController.repeat();

    final scaleX = 2.5 + randomDouble();
    final scaleDuration = ((randomSignedDouble() * 2.0 + 4.0) * 1000).floor();
    scaleController = AnimationController(duration: Duration(milliseconds: scaleDuration), vsync: this);
    scaleAnimation = Tween<double>(begin: scaleX, end: scaleX * 0.5).animate(scaleController);
    scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    rotationController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotationAnimation,
      builder: (_, child) => Transform(
        alignment: Alignment.centerLeft,
        transform: Matrix4.rotationZ(math.pi * rotationAnimation.value)..scale(scaleAnimation.value, 0.3),
        child: child!,
      ),
      child: Transform.scale(
        scale: 1.0,
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(<double>[
            1, 0, 0, 0, 114, // Do some color finagling to more or less replicate the effect of
            0, 1, 0, 0, 207, // image's BlendMode.plus from the original implementation
            0, 0, 1, 0, 233, //
            0, 0, 0, 1.7 * opacity, -50 * opacity
          ]),
          child: Image.asset('assets/ray.png'),
        ),
      ),
    );
  }
}

class Rain extends StatelessWidget {
  final bool visible;

  const Rain({Key? key, required this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final dropsPerLayer = (constraints.maxWidth * constraints.maxHeight / 15000.0).floor();
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: visible ? 2000 : 500),
          child: Stack(
            children: [
              ...List.generate(dropsPerLayer, (_) => Raindrop(distance: 2.0)),
              ...List.generate(dropsPerLayer, (_) => Raindrop(distance: 1.5)),
              ...List.generate(dropsPerLayer, (_) => Raindrop(distance: 1.0)),
            ],
          ),
        );
      });
}

class Raindrop extends StatelessWidget {
  final double distance;

  const Raindrop({Key? key, this.distance = 1.0}) : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final sidewaysMovement = -(constraints.maxHeight / 3000.0);
        final baseDuration = (constraints.maxHeight * 2.5).floor();
        return Particle(
          duration: Duration(milliseconds: (baseDuration * distance).floor()),
          durationVariance: Duration(milliseconds: (baseDuration * 0.1 * distance).floor()),
          spawnArea: Rect.fromLTRB(-1.1, -1.8, 1.1, -1.8),
          motionVectorBounds: Rect.fromLTRB(sidewaysMovement, 3.6, sidewaysMovement, 3.6),
          scaleVariance: 0.2,
          child: Transform.scale(
            scale: 1 / (distance * 1.5),
            child: Transform.rotate(
              angle: math.pi / 18,
              child: Image.asset('assets/rain-drop.png'),
            ),
          ),
        );
      });
}

class Snow extends StatelessWidget {
  final bool visible;

  const Snow({Key? key, required this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final flakesPerLayer = (constraints.maxWidth * constraints.maxHeight / 45000.0).floor();
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: Duration(milliseconds: visible ? 2000 : 500),
          child: Stack(
            children: [
              ...List.generate(flakesPerLayer, (_) => Snowflake(image: Image.asset('assets/flake-0.png'), distance: 1.0)),
              ...List.generate(flakesPerLayer, (_) => Snowflake(image: Image.asset('assets/flake-1.png'), distance: 1.0)),
              ...List.generate(flakesPerLayer, (_) => Snowflake(image: Image.asset('assets/flake-2.png'), distance: 1.0)),
              ...List.generate(flakesPerLayer, (_) => Snowflake(image: Image.asset('assets/flake-3.png'), distance: 1.5)),
              ...List.generate(flakesPerLayer, (_) => Snowflake(image: Image.asset('assets/flake-4.png'), distance: 1.5)),
              ...List.generate(flakesPerLayer, (_) => Snowflake(image: Image.asset('assets/flake-5.png'), distance: 1.5)),
              ...List.generate(flakesPerLayer, (_) => Snowflake(image: Image.asset('assets/flake-6.png'), distance: 2.0)),
              ...List.generate(flakesPerLayer, (_) => Snowflake(image: Image.asset('assets/flake-7.png'), distance: 2.0)),
              ...List.generate(flakesPerLayer, (_) => Snowflake(image: Image.asset('assets/flake-8.png'), distance: 2.0)),
            ],
          ),
        );
      });
}

class Snowflake extends StatelessWidget {
  final Image image;
  final double distance;

  const Snowflake({
    Key? key,
    required this.image,
    this.distance = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        final baseDuration = (constraints.maxHeight * 25.0).floor();
        return Particle(
          duration: Duration(milliseconds: (baseDuration * distance).floor()),
          durationVariance: Duration(milliseconds: (baseDuration * 0.35 * distance).floor()),
          spawnArea: Rect.fromLTRB(-1.1, -1.8, 1.1, -1.8),
          motionVectorBounds: Rect.fromLTRB(-0.2, 3.6, 0.2, 3.6),
          lifetimeSpinVariance: math.pi * 3,
          scaleVariance: 0.3,
          child: Transform.scale(
            scale: 1 / (distance * 1.5),
            child: image,
          ),
        );
      });
}

class Particle extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration durationVariance;
  final Rect spawnArea;
  final Rect motionVectorBounds;
  final double lifetimeSpinVariance;
  final double scaleVariance;

  const Particle({
    Key? key,
    required this.child,
    required this.duration,
    this.durationVariance = const Duration(milliseconds: 0),
    required this.spawnArea,
    required this.motionVectorBounds,
    this.lifetimeSpinVariance = 0.0,
    this.scaleVariance = 0.0,
  })  : assert(duration > durationVariance),
        super(key: key);

  @override
  _ParticleState createState() => _ParticleState();
}

class _ParticleState extends State<Particle> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Tween<Alignment> positionTween;
  late Animation<Alignment> positionAnimation;
  late Tween<double> rotationTween;
  late Animation<double> rotationAnimation;

  late Duration duration;
  late Alignment startAlignment;
  late Alignment endAlignment;
  late double endRotation;
  late double scale;

  @override
  void initState() {
    super.initState();

    positionTween = Tween<Alignment>();
    rotationTween = Tween<double>();

    _randomise();

    animationController = AnimationController(duration: duration, vsync: this);
    positionAnimation = positionTween.animate(animationController);
    rotationAnimation = rotationTween.animate(animationController);

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _randomise();
        animationController.duration = duration;
        animationController.reset();
        animationController.forward(from: randomDouble() * 0.1);
      }
    });

    animationController.forward(from: randomDouble());
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _randomise() {
    Alignment _randomAlignment(Rect bounds) => Alignment(
          bounds.left + (bounds.right - bounds.left) * randomDouble(),
          bounds.top + (bounds.bottom - bounds.top) * randomDouble(),
        );
    duration = widget.duration + Duration(milliseconds: (randomSignedDouble() * widget.durationVariance.inMilliseconds).floor());
    startAlignment = _randomAlignment(widget.spawnArea);
    endAlignment = startAlignment + _randomAlignment(widget.motionVectorBounds);
    endRotation = randomSignedDouble() * widget.lifetimeSpinVariance;
    scale = 1.0 + (randomSignedDouble() * widget.scaleVariance);

    positionTween.begin = startAlignment;
    positionTween.end = endAlignment;
    rotationTween.begin = 0.0;
    rotationTween.end = endRotation;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (_, __) => Align(
        alignment: positionAnimation.value,
        child: Transform.rotate(
          angle: rotationAnimation.value,
          child: Transform.scale(
            scale: scale,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

math.Random _random = new math.Random();

// Random methods

/// Returns a random [double] in the range of 0.0 to 1.0.
double randomDouble() {
  return _random.nextDouble();
}

/// Returns a random [double] in the range of -1.0 to 1.0.
double randomSignedDouble() {
  return _random.nextDouble() * 2.0 - 1.0;
}

/// Returns a random [int] from 0 to max - 1.
int randomInt(int max) {
  return _random.nextInt(max);
}

/// Returns either [true] or [false] in a most random fashion.
bool randomBool() {
  return _random.nextDouble() < 0.5;
}
