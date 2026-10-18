import 'package:flutter/material.dart';

import 'plan.dart';

// Colors taken from rba.hr site CSS.
const rbaYellow = Color(0xFFFEE600);
const rbaDark = Color(0xFF2B2D33);
const rbaTeal = Color(0xFF037080);
// Dark theme (default): page, panels and text on them.
const rbaBg = Color(0xFF1E1F23);
const rbaInk = Color(0xFFF1EDE6);
const rbaMuted = Color(0xFFB4B6BB);
const rbaTealLight = Color(0xFF4FB8C6);

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ready for',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: rbaYellow,
          primary: rbaYellow,
          onPrimary: rbaDark,
          secondary: rbaTealLight,
          surface: rbaDark,
          onSurface: rbaInk,
        ),
        scaffoldBackgroundColor: rbaBg,
      ),
      home: const MainPage(),
    );
  }
}

final goals = <Goal>[
  (
    title: 'Car',
    icon: Icons.directions_car_rounded,
    motion: drive,
    costLabel: 'Total price',
    ownLabel: 'Saved for the down payment',
    cost: 25000,
    maxCost: 100000,
    step: 500,
    own: 2500,
    budget: 300,
    years: (min: 1, initial: 5, max: 8),
    insurance: (
      name: 'Car insurance',
      monthly: 50,
      covers:
          'Comprehensive cover for damage and theft, on top of the '
          'mandatory liability policy.',
    ),
    info: [
      (
        'Financing options',
        'Pay from savings, take a car loan or lease. With a loan the car '
            'is yours from day one; leasing usually means lower monthly '
            'payments.',
      ),
      (
        'What you will need',
        'ID, proof of income (recent payslips) and the seller\'s offer '
            'or pro-forma invoice.',
      ),
      (
        'Running costs',
        'Plan for registration, insurance, servicing and fuel on top of '
            'the purchase price.',
      ),
    ],
  ),
  (
    title: 'House or flat',
    icon: Icons.home_rounded,
    motion: pulse,
    costLabel: 'Total price',
    ownLabel: 'Saved for the down payment',
    cost: 180000,
    maxCost: 1000000,
    step: 5000,
    own: 35000,
    budget: 800,
    years: (min: 5, initial: 25, max: 30),
    insurance: (
      name: 'Home insurance',
      monthly: 15,
      covers:
          'Covers the property against fire, flood and burglary. Banks '
          'usually require it for a housing loan.',
    ),
    info: [
      (
        'Housing loan basics',
        'Most buyers combine savings for the down payment with a '
            'long-term housing loan. A bigger down payment means lower '
            'monthly instalments.',
      ),
      (
        'What you will need',
        'ID, proof of income, a land registry extract for the property '
            'and a property valuation.',
      ),
      (
        'Extra costs',
        'Budget for property transfer tax, notary and agency fees, and '
            'moving in.',
      ),
    ],
  ),
  (
    title: 'Holiday',
    icon: Icons.beach_access_rounded,
    motion: sway,
    costLabel: 'Budget',
    ownLabel: 'Already saved',
    cost: 3000,
    maxCost: 20000,
    step: 100,
    own: 0,
    budget: 200,
    years: (min: 1, initial: 1, max: 3),
    insurance: (
      name: 'Travel insurance',
      monthly: 5,
      covers:
          'Annual policy for medical costs abroad, cancellations and '
          'lost luggage.',
    ),
    info: [
      (
        'Save or borrow?',
        'Saving a little each month avoids interest. For bigger trips a '
            'small cash loan or card instalments can spread the cost.',
      ),
      (
        'Travel smart',
        'Book early, get travel insurance and keep a reserve for '
            'unexpected costs on the trip.',
      ),
    ],
  ),
  (
    title: 'Major life event',
    icon: Icons.celebration_rounded,
    motion: hop,
    costLabel: 'Estimated cost',
    ownLabel: 'Savings so far',
    cost: 15000,
    maxCost: 100000,
    step: 500,
    own: 3000,
    budget: 400,
    years: (min: 1, initial: 3, max: 5),
    insurance: null,
    info: [
      (
        'Plan ahead',
        'Weddings, a new baby or education come with big costs. Starting '
            'early gives you more freedom and less stress.',
      ),
      (
        'Ways to fund it',
        'Combine a savings plan, a cash loan and insurance to cover the '
            'event without draining your reserves.',
      ),
    ],
  ),
];

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: rbaYellow,
        foregroundColor: rbaDark,
        toolbarHeight: 80,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ready for',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            Text('be ready for what matters', style: TextStyle(fontSize: 13)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            'What would you like to achieve?',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall?.copyWith(
              color: rbaInk,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your goal and we will help you get there.',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(color: rbaMuted),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: [
              for (final g in goals)
                GoalCard(
                  title: g.title,
                  icon: g.icon,
                  motion: g.motion,
                  onTap: () => showPlan(context, g),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget drive(double t, Widget child) =>
    Transform.translate(offset: Offset((t - 0.5) * 60, 0), child: child);
Widget pulse(double t, Widget child) =>
    Transform.scale(scale: 0.9 + 0.15 * t, child: child);
Widget sway(double t, Widget child) => Transform.rotate(
  angle: (t - 0.5) * 0.5,
  alignment: Alignment.bottomCenter,
  child: child,
);
Widget hop(double t, Widget child) =>
    Transform.translate(offset: Offset(0, -20 * t), child: child);

class GoalCard extends StatefulWidget {
  const GoalCard({
    super.key,
    required this.title,
    required this.icon,
    required this.motion,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Motion motion;
  final VoidCallback onTap;

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final t = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the OS "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.stop();
    } else if (!controller.isAnimating) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.title,
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: widget.onTap,
          child: Ink(
            width: 280,
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [rbaTeal, rbaDark],
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: const Alignment(0, -0.45),
                  child: AnimatedBuilder(
                    animation: t,
                    builder: (_, child) => widget.motion(t.value, child!),
                    child: Icon(widget.icon, size: 96, color: rbaYellow),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 40, height: 4, color: rbaYellow),
                      const SizedBox(height: 8),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
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
    );
  }
}
