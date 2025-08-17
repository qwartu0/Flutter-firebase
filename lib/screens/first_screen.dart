import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../services/remote_config_service.dart';
import 'mine_screen.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _explicitController;
  late Animation<double> _explicitAnimation;
  bool _showStaggered = false;
  bool _animationCompleted = false;
  double _balance = 1000.0;
  String _name = "User";
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  bool _isAddBalanceEnabled = true;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _name);

    _explicitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _explicitAnimation = CurvedAnimation(
      parent: _explicitController,
      curve: Curves.easeInOut,
    );

    _initializeRemoteConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _explicitController.forward();
    });

    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
      setState(() {
        _isAddBalanceEnabled = _remoteConfig.getBool('add_balance_enabled');
      });
    });
  }

  Future<void> _initializeRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 0),
      ));
      await _remoteConfig.fetchAndActivate();

      setState(() {
        _isAddBalanceEnabled = _remoteConfig.getBool('add_balance_enabled');
      });
    } catch (e) {
      print('RemoteConfig error: $e');
      setState(() {
        _isAddBalanceEnabled = true;
      });
    }
  }

  @override
  void dispose() {
    _explicitController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleStaggeredAnimation() {
    setState(() {
      _showStaggered = !_showStaggered;
    });
  }

  void _addBalance() {
    setState(() {
      _balance += 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _balance > 2200
        ? Colors.red
        : RemoteConfigService.getBlockColor();
    final cardColor = Color.lerp(
      const Color(0xFFB9895C),
      Colors.amber,
      _explicitController.value,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: AnimatedContainer(
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: _balance > 2200 ? 380 : 360,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            color: backgroundColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(36, 36, 36, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(seconds: 2),
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'DCOPAY',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onEnd: () {
                                    setState(() {
                                      _animationCompleted = true;
                                    });
                                  },
                                ),
                                const SizedBox(height: 35),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _nameController,
                                        onChanged: (value) {
                                          setState(() {
                                            _name = value;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Enter name',
                                          hintStyle: TextStyle(color: Colors.white70),
                                        ),
                                        style: TextStyle(
                                          fontSize: _animationCompleted ? 28 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MineScreen(),
                                          ),
                                        );
                                      },
                                      child: AnimatedRotation(
                                        duration: const Duration(seconds: 3),
                                        turns: _animationCompleted ? 1.25 : 0,
                                        child: const Icon(
                                          Icons.person_pin,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'What would you like to do today?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Center(
                                  child: Container(
                                    width: 274,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                      color: const Color(0xFF718270),
                                    ),
                                  ),
                                ),
                                Draggable(
                                  feedback: Material(
                                    child: AnimatedContainer(
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.fastOutSlowIn,
                                      width: 350,
                                      height: 125,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                        ),
                                        color: cardColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(30, 15, 0, 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Wallet',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Text(
                                              'Your Balance:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 500),
                                                  child: Text(
                                                    key: ValueKey<double>(_balance),
                                                    '${_balance}\$',
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  transitionBuilder: (child, animation) {
                                                    return ScaleTransition(
                                                      scale: animation,
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: 120),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Container(),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_explicitController.status == AnimationStatus.completed) {
                                        _explicitController.reverse();
                                      } else {
                                        _explicitController.forward();
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.fastOutSlowIn,
                                      width: 350,
                                      height: 125,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                        ),
                                        color: cardColor,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(30, 15, 0, 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Wallet',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const Text(
                                              'Your Balance:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                AnimatedSwitcher(
                                                  duration: const Duration(milliseconds: 500),
                                                  child: Text(
                                                    key: ValueKey<double>(_balance),
                                                    '${_balance}\$',
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  transitionBuilder: (child, animation) {
                                                    return ScaleTransition(
                                                      scale: animation,
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: 120),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  onDragEnd: (details) {
                                    // Можно добавить логику при завершении drag
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 1500),
                              crossFadeState: _showStaggered
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: const [
                                  ActionButton(icon: Icons.arrow_upward, label: 'Pay'),
                                  ActionButton(icon: Icons.arrow_downward, label: 'Request'),
                                  ActionButton(icon: Icons.add, label: 'Add Money'),
                                ],
                              ),
                              secondChild: Column(
                                children: [
                                  StaggeredAnimation(
                                    children: const [
                                      ActionButton(icon: Icons.arrow_upward, label: 'Pay'),
                                      ActionButton(icon: Icons.arrow_downward, label: 'Request'),
                                      ActionButton(icon: Icons.add, label: 'Add Money'),
                                      ActionButton(icon: Icons.book, label: 'Passbook'),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  StaggeredAnimation(
                                    direction: Axis.vertical,
                                    children: const [
                                      ActionButton(icon: Icons.history, label: 'History'),
                                      ActionButton(icon: Icons.settings, label: 'Settings'),
                                      ActionButton(icon: Icons.help, label: 'Help'),
                                      ActionButton(icon: Icons.exit_to_app, label: 'Exit'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _toggleStaggeredAnimation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(_showStaggered ? 'Hide Staggered' : 'Show Staggered'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ScaleTransition(
                          scale: _explicitAnimation,
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFF23695C),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Virtual Banking',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Tap the card or button below',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const Spacer(),
                                      Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: () {
                                            final controller = AnimationController(
                                              vsync: this,
                                              duration: const Duration(seconds: 1),
                                            )..forward();
                                          },
                                          child: const Text(
                                            'Tap Me!',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEFD9D1),
                                  minimumSize: const Size(0, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: _isAddBalanceEnabled ? _addBalance : null,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text('Add 50\$', style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF23695C), size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class StaggeredAnimation extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;

  const StaggeredAnimation({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      children: [
        for (int i = 0; i < children.length; i++)
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (i * 5000)),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: direction == Axis.horizontal
                      ? Offset(20 * (1 - value), 0)
                      : Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: children[i],
          ),
      ],
    );
  }
}