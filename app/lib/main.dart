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
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: rbaBg,
        ),
      ),
      home: const MainPage(),
    );
  }
}

/// A detail question: free text/number, or a choice when [options] is set.
/// [initial] prefills the field.
typedef Question = ({
  String label,
  bool number,
  List<String>? options,
  String? initial,
});

Question text(String label, {String? initial}) =>
    (label: label, number: false, options: null, initial: initial);
Question number(String label, {String? initial}) =>
    (label: label, number: true, options: null, initial: initial);
Question choice(String label, List<String> options, {String? initial}) =>
    (label: label, number: false, options: options, initial: initial);

const when = ['Within 3 months', '3 – 12 months', 'More than a year'];

final goals =
    <
      ({
        String title,
        String cost,
        String? own,
        List<int> years,
        Insurance? insurance,
        IconData icon,
        Motion motion,
        List<(String, String)> info,
        List<Question> questions,
      })
    >[
      (
        title: 'New car',
        cost: 'Approximate price (EUR)',
        own: 'Down payment (EUR)',
        years: [3, 5, 7],
        insurance: (
          name: 'Car insurance',
          monthly: 50,
          covers:
              'Comprehensive cover for damage and theft, on top of the '
              'mandatory liability policy.',
        ),
        icon: Icons.directions_car_rounded,
        motion: drive,
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
        questions: [
          choice('New or used?', ['New', 'Used'], initial: 'New'),
          number('Approximate price (EUR)', initial: '25000'),
          number('Down payment (EUR)', initial: '2500'),
          choice('When do you plan to buy?', when, initial: when[1]),
        ],
      ),
      (
        title: 'House or flat',
        cost: 'Approximate price (EUR)',
        own: 'Down payment (EUR)',
        years: [10, 20, 30],
        insurance: (
          name: 'Home insurance',
          monthly: 15,
          covers:
              'Covers the property against fire, flood and burglary. Banks '
              'usually require it for a housing loan.',
        ),
        icon: Icons.home_rounded,
        motion: pulse,
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
        questions: [
          choice('Property type', ['House', 'Flat'], initial: 'Flat'),
          text('Location (city)', initial: 'Zagreb'),
          number('Approximate price (EUR)', initial: '180000'),
          number('Down payment (EUR)', initial: '36000'),
          choice('When do you plan to buy?', when, initial: when[2]),
        ],
      ),
      (
        title: 'Holiday',
        cost: 'Budget (EUR)',
        own: null,
        years: [1, 2, 3],
        insurance: (
          name: 'Travel insurance',
          monthly: 5,
          covers:
              'Annual policy for medical costs abroad, cancellations and '
              'lost luggage.',
        ),
        icon: Icons.beach_access_rounded,
        motion: sway,
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
        questions: [
          text('Destination', initial: 'Lisbon'),
          number('Number of people', initial: '2'),
          number('Budget (EUR)', initial: '3000'),
          choice('When are you travelling?', when, initial: when[1]),
        ],
      ),
      (
        title: 'Major life event',
        cost: 'Estimated cost (EUR)',
        own: 'Savings so far (EUR)',
        years: [2, 3, 5],
        insurance: null,
        icon: Icons.celebration_rounded,
        motion: hop,
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
        questions: [
          choice('What is the event?', [
            'Wedding',
            'New baby',
            'Education',
            'Other',
          ], initial: 'Wedding'),
          number('Estimated cost (EUR)', initial: '15000'),
          number('Savings so far (EUR)', initial: '3000'),
          choice('When is it?', when, initial: when[2]),
        ],
      ),
    ];

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int? selected;
  final formKey = GlobalKey<FormState>();
  final answers = <String, String>{};

  void select(int i) => setState(() {
    selected = i;
    answers.clear();
  });

  void plan() {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    final goal = goals[selected!];
    final own = goal.own;
    showPlan(
      context,
      goal: goal.title,
      cost: double.parse(answers[goal.cost]!),
      own: own == null ? 0 : double.parse(answers[own]!),
      years: goal.years,
      insurance: goal.insurance,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final goal = selected == null ? null : goals[selected!];
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
              for (var i = 0; i < goals.length; i++)
                GoalCard(
                  title: goals[i].title,
                  icon: goals[i].icon,
                  motion: goals[i].motion,
                  selected: selected == i,
                  onTap: () => select(i),
                ),
            ],
          ),
          if (goal != null) ...[
            const SizedBox(height: 32),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  color: rbaDark,
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        // New key per goal resets the fields when switching.
                        key: ValueKey(selected),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: textTheme.headlineMedium?.copyWith(
                              color: rbaTealLight,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final (title, body) in goal.info)
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              shape: const Border(),
                              leading: const Icon(
                                Icons.info_outline,
                                color: rbaTealLight,
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rbaInk,
                                ),
                              ),
                              expandedAlignment: Alignment.centerLeft,
                              childrenPadding: const EdgeInsets.only(
                                left: 40,
                                bottom: 12,
                              ),
                              children: [
                                Text(
                                  body,
                                  style: const TextStyle(color: rbaMuted),
                                ),
                              ],
                            ),
                          const Divider(height: 32),
                          Text(
                            'Tell us more',
                            style: textTheme.titleLarge?.copyWith(
                              color: rbaInk,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (final q in goal.questions) ...[
                            QuestionField(
                              question: q,
                              onSaved: (v) => answers[q.label] = v ?? '',
                            ),
                            const SizedBox(height: 16),
                          ],
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: rbaYellow,
                              foregroundColor: rbaDark,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: plan,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Help me plan this'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Moves a tile's picture for animation progress [t] (0 → 1 → 0, eased).
typedef Motion = Widget Function(double t, Widget child);

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
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Motion motion;
  final bool selected;
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
    final selected = widget.selected;
    return Semantics(
      button: true,
      selected: selected,
      label: widget.title,
      child: Material(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? rbaYellow : Colors.transparent,
            width: 5,
          ),
        ),
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
                if (selected)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: rbaYellow,
                      child: Icon(Icons.check, color: rbaDark),
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

class QuestionField extends StatelessWidget {
  const QuestionField({
    super.key,
    required this.question,
    required this.onSaved,
  });

  final Question question;
  final FormFieldSetter<String> onSaved;

  @override
  Widget build(BuildContext context) {
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Required' : null;
    final decoration = InputDecoration(labelText: question.label);
    final options = question.options;
    if (options != null) {
      return DropdownButtonFormField<String>(
        decoration: decoration,
        initialValue: question.initial,
        items: [
          for (final o in options) DropdownMenuItem(value: o, child: Text(o)),
        ],
        onChanged: (_) {},
        validator: required,
        onSaved: onSaved,
      );
    }
    return TextFormField(
      decoration: decoration,
      initialValue: question.initial,
      keyboardType: question.number ? TextInputType.number : TextInputType.text,
      validator: question.number
          ? (v) =>
                required(v) ??
                (num.tryParse(v!.trim()) == null ? 'Enter a number' : null)
          : required,
      onSaved: onSaved,
    );
  }
}
