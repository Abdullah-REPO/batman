import 'dart:math';

import 'package:game_final_project/screens/starting_page.dart';
import 'package:flutter/material.dart';

import 'Evilman.dart';
import 'batman.dart';
import 'game-object.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: starting(title: 'Batman Game'),
  ));
}

//  Turkey Code   *my_code: [11 -> 112]*
//  Notice that I added a title to 'home: starting()'
//  I changed the path at 'code: [1]' to " game_final_project/.... "
class starting extends StatefulWidget {
  const starting({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _startingState createState() => _startingState();
}

class _startingState extends State<starting> with SingleTickerProviderStateMixin{

  Batman bat = Batman();
  double runDistance = 0;
  double runVelocity = 30;

  late AnimationController worldController;
  Duration lastUpdateCall = Duration();

  List<Evilman> evil = [Evilman(worldLocation: Offset(200, 0))];

  @override
  void initState(){
    super.initState();

    worldController = AnimationController(vsync: this,duration: Duration(days: 99));
    worldController.addListener(_update);
    worldController.forward();
  }

  void _die(){
    setState(() {
      worldController.stop();
      bat.die();
    });
  }

  _update(){
    bat.update(lastUpdateCall, worldController.lastElapsedDuration!);

    double elapsedTimeSeconds = (worldController.lastElapsedDuration! - lastUpdateCall).inMilliseconds / 1000;

    runDistance += runVelocity * elapsedTimeSeconds;

    Size screensize = MediaQuery.of(context).size;

    Rect dinoRect = bat.getRect(screensize, runDistance).deflate(5);
    for(Evilman e in evil){
      Rect obstacleRect = e.getRect(screensize, runDistance);
      if(dinoRect.overlaps(obstacleRect.deflate(5))){
        _die();
      }

      if(obstacleRect.right < 0){
        setState(() {
          evil.remove(e);
          evil.add(Evilman(
              worldLocation: Offset(runDistance + Random().nextInt(100) + 50, 0)
          ));
        });

      }
    }
    lastUpdateCall = worldController.lastElapsedDuration!;
  }

  @override
  Widget build(BuildContext context) {
    Size screensize = MediaQuery.of(context).size;
    List<Widget> childern = [];
    for (GameObject object in [...evil, bat]){
      childern.add(
          AnimatedBuilder(
              animation: worldController,
              builder: (context, _){
                Rect objectRect = object.getRect(screensize, runDistance);
                return Positioned(
                  left: objectRect.left,
                  top: objectRect.top,
                  width: objectRect.width,
                  height: objectRect.height,
                  child: object.render(),
                );
              })
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            bat.jump();
          },
          child: Stack(
            alignment: Alignment.center,
            children: childern,
          )
      ),
    );
  }
}