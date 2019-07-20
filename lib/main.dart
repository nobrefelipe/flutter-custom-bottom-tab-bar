import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Center(),
      backgroundColor: Color.fromRGBO(252, 15, 67, 1),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

class CustomBottomNavigationBar extends StatefulWidget {
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with TickerProviderStateMixin {
  // Init Animation Controllers
  AnimationController _animationController;
  AnimationController _fadeOutController;

  // Init Animations
  Animation<double> _positionAnimation;
  Animation<double> _fadeFabOutAnimation;
  Animation<double> _fadeFabInAnimation;

  // Init Tween
  Tween<double> _positionTween;

  // Alpha : used for fade in and out  and translate the icons
  double fabIconAlpha = 1;

  // Current selected tab
  int currentSelected = 0;

  // Active Icons
  IconData activeIcon = Icons.add_circle;

  @override
  void initState() {
    super.initState();

    // Set up Tween init state
    _positionTween = Tween<double>(begin: 0, end: 0);

    // Set up the FADE OUT Animation Controller
    _fadeOutController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (500 ~/ 3),
      ),
    );

    // Set up the TRANSLATION Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    // Create the TRANSLATION Animation
    _positionAnimation = _positionTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    )..addListener(() => setState(() {}));

    // Create the FADE OUT Animation
    _fadeFabOutAnimation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _fadeOutController, curve: Curves.easeOut))

      //Set the Alpha value : will get animated from 1 to 0
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabOutAnimation.value;
        });
      })

      // Listen to the end of the Fade Out animation and ...
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            //activeIcon = nextIcon;
          });
        }
      });

    // Create the FADE IN Animation
    // Will be run everytime setState() is called
    // The Alpha value will be animated from 0 to 1
    _fadeFabInAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Interval(0, 1, curve: Curves.easeOut)))
      ..addListener(() {
        setState(() {
          fabIconAlpha = _fadeFabInAnimation.value;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
/*======================
  START : tabs container
======================*/
        Container(
          padding: EdgeInsets.only(bottom: 25.0),
          width: double.infinity,
          color: Colors.white,
          height: 100,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
/*======================
  START : tab items
======================*/

              // Home Tab
              TabItem(
                selected: currentSelected == -1,
                iconData: Icons.home,
                title: "HOME",
                callbackFunction: () {
                  setState(() {
                    activeIcon = Icons.home;
                    currentSelected = -1;
                  });

                  _initAnimationAndStart(_positionAnimation.value, -1);
                },
              ),

              //Add Tab
              TabItem(
                selected: currentSelected == 0,
                iconData: Icons.add_circle,
                title: "ADD",
                callbackFunction: () {
                  setState(() {
                    activeIcon = Icons.add_circle;
                    currentSelected = 0;
                  });

                  _initAnimationAndStart(_positionAnimation.value, 0);
                },
              ),

              //Setting Tab
              TabItem(
                selected: currentSelected == 1,
                iconData: Icons.settings,
                title: "SETTINGS",
                callbackFunction: () {
                  setState(() {
                    activeIcon = Icons.settings;
                    currentSelected = 1;
                  });

                  _initAnimationAndStart(_positionAnimation.value, 1);
                },
              ),
            ],
          ),
        ),

/*======================
  START : pointer
======================*/
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(color: Colors.transparent),

            /*
              Use [FractionallySizedBox] widget with [widthFactor] to set the child width
              widthFactor: 1/3 will make the child expand to 1/3th of the parent width
              then use the [alignment] attribute to set the position of the circle
            */
            child: Align(
              // Same as per widthFactor for the height
              heightFactor: 1,
              /*
                Set the X position of the circle (-1 , 0 , 1)
                _positionAnimation.value will be set from the tab icons upon click
                values can be -1, 0 or 1
              */
              alignment: Alignment(_positionAnimation.value, 0),
              child: FractionallySizedBox(
                /*
                  Child widget will expand to 1/3th  width of the parent
                */
                widthFactor: 1 / 3,

                /*
                   START : circle
                */
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      // Pull up the circle by half of its size
                      offset: Offset(0.0, -40.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          /*
                            The background of the white circle
                            it needs to get the same background colors of the canvas
                            so it maked the 'hole' effect
                           */
                          Container(
                            height: 80,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(252, 15, 67, 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(40),
                              ),
                            ),
                          ),

                          /*
                            The icosn container
                            wrapped inside a [Opacity] Widget so it can be faded in and out by the contollers
                            Also wrapped with a [Transform.translate] widget so it can be moved up adn down
                          */
                          Opacity(
                            /* fabIconAlpha is managed by the fadein and out animations */
                            opacity: fabIconAlpha,
                            child: Transform.translate(
                              /* 
                                fabIconAlpha is managed by the translation animation
                                when fabIconAlpha = 0 pushed the icon down
                                when fabIconAlpha = 1 animate the icon up
                              */
                              offset: Offset(0.0, (25 - 25 * fabIconAlpha)),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  //
                                  /* The background of the circle */
                                  color: Colors.white,

                                  /* Make the Container rounded */
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(40),
                                  ),

                                  /* Box shadow aroudn the white circle */
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black38,
                                      offset: Offset(0, 0),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),

                                /*
                                  The Active icon
                                */
                                child: Icon(
                                  activeIcon,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /*
                      The clip path 
                      used to make the 'hole' smoothly match the tabs bar baskground
                      creating a soft curve
                      !! Can be improved !!
                    */
                    ClipPath(
                      clipper: CustomShape(),
                      child: Container(
                        width: 100,
                        height: 80,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                //
                // END: circle
                //
              ),
            ),
          ),
        ),
/*======================
  END : pointer
======================*/
      ],
    );
  }

  _initAnimationAndStart(double from, double to) {
    // From = current animation value. Can be -1, 0 or 1
    _positionTween.begin = from;

    // To = the tab we want to animate to. Can be -1, or 1
    _positionTween.end = to;

    _fadeOutController.reset();

    // Reset the animation controller
    _animationController.reset();

    // Init the translation  animation
    _animationController.forward();

    // Init the fadeout animation
    _fadeOutController.forward();
  }
}

class TabItem extends StatefulWidget {
  final bool selected;
  final IconData iconData;
  final String title;
  final Function callbackFunction;

  TabItem({
    Key key,
    this.selected,
    this.iconData,
    this.title,
    this.callbackFunction,
  }) : super(key: key);

  @override
  _TabItemState createState() => _TabItemState();
}

class _TabItemState extends State<TabItem> {
  @override
  Widget build(BuildContext context) {
    print(widget.selected);
    return Expanded(
      child: GestureDetector(
        // On tap call the callback function passed from the Tabs List Container
        onTap: () => widget.callbackFunction(),

        child: Container(
          /*
            ??Possible bug?? 
            Workaround
            Without the background only the icon and the label is tappable 
            with the background all the tab become tappable
          */
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // The Icon
              /*
                Use Animated Opacity to fade in and out the Icons
                depending on the tab slected status
              */
              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: widget.selected ? 0.0 : 1.0,
                child: Icon(
                  widget.iconData,
                  size: 28,
                  color: Colors.black54,
                ),
              ),

              /*
                Use Animated Container to animate the space between the icon and label
                so when the tab is selected the label slides down 
                and the icon slides up 
              */
              AnimatedContainer(
                height: widget.selected ? 10.0 : 0.0,
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 200),
              ),

              // The Label
              /*
                Use Animated Opacity to fade in and out the Label
                depending on the tab slected status
              */
              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: widget.selected ? 1.0 : 0.0,
                child: Text(
                  "${widget.title}",
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
  The clip path 
  used to make the 'hole' smoothly match the tabs bar baskground
  creating a soft curve
  !! Can be improved !!
*/
class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    //path.moveTo(0.0, size.height/2);

    path.lineTo(0.0, size.height / 2);

    path.lineTo(size.width, size.height / 2);

    path.lineTo(size.width, size.height / 2);

    path.lineTo(size.width, 0.0);

    var firstEndPoint = Offset(size.width - 15.0, 15.0);
    var firstControlPont = Offset(size.width - 5.0, 0.0);

    path.quadraticBezierTo(
      firstControlPont.dx,
      firstControlPont.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondEndPoint = Offset(15.0, 15.0);
    var secondControlPont = Offset(size.width / 2, size.height * 0.7);

    path.quadraticBezierTo(
      secondControlPont.dx,
      secondControlPont.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    var thirdEndPoint = Offset(0.0, 0.0);
    var thirdControlPont = Offset(5.0, 0.0);

    path.quadraticBezierTo(
      thirdControlPont.dx,
      thirdControlPont.dy,
      thirdEndPoint.dx,
      thirdEndPoint.dy,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
