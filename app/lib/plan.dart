import 'dart:math';

import 'package:flutter/material.dart';

const loanRate = 0.05; // ponytail: example fixed rate, real offers vary.
const savingsRate = 0.04; // Example savings account rate, compounded monthly.

// Chart series colors, validated for CVD separation and contrast on the dark panel.
const loanColor = Color(0xFF0083A0);
const saveColor = Color(0xFFE54F1B);
const comboColor = Color(0xFF9C7FD6);
const ink = Color(0xFFF1EDE6);
const muted = Color(0xFFB4B6BB);
const panel = Color(0xFF2B2D33);
const raised = Color(0xFF3A3D44);

/// Monthly annuity instalment for [principal] at [rate] p.a. over [months].
double monthlyPayment(double principal, double rate, int months) {
  final r = rate / 12;
  return principal * r / (1 - pow(1 + r, -months));
}

/// Whole months needed to repay [principal] at [rate] p.a. paying [pay] a month.
int monthsToRepay(double principal, double rate, double pay) {
  final r = rate / 12;
  // 1e-6 absorbs float noise so an exact 60.0000001 doesn't round up to 61.
  return (-log(1 - principal * r / pay) / log(1 + r) - 1e-6).ceil();
}

/// Savings balance at the start of each month, depositing [pay] monthly at
/// [rate] p.a. until [target] is reached.
List<double> savingsBalances(double target, double rate, double pay) {
  final out = [0.0];
  while (out.last < target) {
    out.add(min(target, out.last * (1 + rate / 12) + pay));
  }
  return out;
}

/// Interest earned along [balances]: each month earns on the prior balance.
double savingsInterest(List<double> balances, double rate) =>
    rate / 12 * balances.take(balances.length - 1).fold(0.0, (a, b) => a + b);

/// Remaining loan balance at the start of each month, 0..months.
List<double> loanBalances(double principal, double rate, int months) {
  final pay = monthlyPayment(principal, rate, months);
  final out = [principal];
  for (var m = 0; m < months; m++) {
    out.add(max(0, out.last * (1 + rate / 12) - pay));
  }
  return out;
}

/// Optional insurance add-on for a goal; [monthly] is an example price.
typedef Insurance = ({String name, double monthly, String covers});

String eur(num v) {
  final s = v.round().abs().toString();
  final grouped = s.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '${v < 0 ? '-' : ''}€$grouped';
}

String duration(int months) {
  final y = months ~/ 12, m = months % 12;
  return [
    if (y > 0) '$y ${y == 1 ? 'year' : 'years'}',
    if (m > 0) '$m ${m == 1 ? 'month' : 'months'}',
  ].join(' ');
}

Future<void> showPlan(
  BuildContext context, {
  required String goal,
  required double cost,
  required double own,
  required List<int> years,
  Insurance? insurance,
}) => showDialog(
  context: context,
  builder: (_) => PlanDialog(
    goal: goal,
    cost: cost,
    own: own,
    years: years,
    insurance: insurance,
  ),
);

class PlanDialog extends StatefulWidget {
  const PlanDialog({
    super.key,
    required this.goal,
    required this.cost,
    required this.own,
    required this.years,
    this.insurance,
  });

  final String goal;
  final double cost;
  final double own;
  final List<int> years;
  final Insurance? insurance;

  @override
  State<PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<PlanDialog> {
  late int years = widget.years[1];
  double saveShare = 0.5;
  bool insured = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final amount = widget.cost - widget.own;
    final months = years * 12;
    final pay = amount > 0 ? monthlyPayment(amount, loanRate, months) : 0.0;
    final interest = pay * months - amount;
    final savings = savingsBalances(amount, savingsRate, pay);
    final saveMonths = savings.length - 1;
    final earned = savingsInterest(savings, savingsRate);
    // Option 3: save part first with the same monthly amount, borrow the rest.
    final saved = amount * saveShare;
    final comboSavings = savingsBalances(saved, savingsRate, pay);
    final comboSaveMonths = comboSavings.length - 1;
    final comboEarned = savingsInterest(comboSavings, savingsRate);
    final ins = widget.insurance;
    String insLine(String from) =>
        '+ ${eur(ins!.monthly)} / month '
        '${ins.name.toLowerCase()} $from';
    final comboLoan = amount - saved;
    final comboLoanMonths = amount > 0
        ? monthsToRepay(comboLoan, loanRate, pay)
        : 0;
    final comboInterest = amount > 0
        ? monthlyPayment(comboLoan, loanRate, comboLoanMonths) *
                  comboLoanMonths -
              comboLoan
        : 0.0;

    final screenWidth = MediaQuery.sizeOf(context).width;
    return Dialog(
      backgroundColor: panel,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.025,
        vertical: 24,
      ),
      child: SizedBox(
        width: screenWidth * 0.95,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your ${widget.goal.toLowerCase()} plan',
                      style: textTheme.headlineMedium?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.own > 0
                    ? 'You need ${eur(amount)} '
                          '(${eur(widget.cost)} minus your ${eur(widget.own)}).'
                    : 'You need ${eur(amount)}.',
                style: textTheme.titleMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 24),
              if (amount <= 0)
                Text(
                  'Your own funds already cover it – no loan or extra '
                  'saving needed.',
                  style: textTheme.titleLarge?.copyWith(color: ink),
                )
              else ...[
                if (ins != null) ...[
                  CheckboxListTile(
                    value: insured,
                    onChanged: (v) => setState(() => insured = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Add ${ins.name.toLowerCase()} · '
                      'about ${eur(ins.monthly)} / month',
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      ins.covers,
                      style: const TextStyle(color: muted),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                cardRow(
                  [
                    OptionCard(
                      color: loanColor,
                      title: 'Option 1 · Take a loan',
                      subtitle: 'Fixed 5% p.a. on the remaining balance',
                      headline: '${eur(pay)} / month',
                      lines: [
                        'Repaid in ${duration(months)}',
                        'Total interest ${eur(interest)}',
                        'Total repaid ${eur(pay * months)}',
                        if (insured) insLine('from day one'),
                      ],
                      extra: Wrap(
                        spacing: 8,
                        children: [
                          for (final y in widget.years)
                            ChoiceChip(
                              label: Text('$y ${y == 1 ? 'year' : 'years'}'),
                              selected: y == years,
                              onSelected: (_) => setState(() => years = y),
                            ),
                        ],
                      ),
                    ),
                    OptionCard(
                      color: saveColor,
                      title: 'Option 2 · Save before you buy',
                      subtitle: 'Same amount into a 4% p.a. savings account',
                      headline: '${eur(pay)} / month',
                      lines: [
                        'Ready in ${duration(saveMonths)}',
                        'Interest earned +${eur(earned)}',
                        'You keep ${eur(interest + earned)} compared to the '
                            'loan',
                        if (insured) insLine('once you buy'),
                      ],
                    ),
                    OptionCard(
                      color: comboColor,
                      title: 'Option 3 · Save some, borrow the rest',
                      subtitle: 'Save first, then a smaller loan',
                      headline: '${eur(pay)} / month',
                      lines: [
                        'Save ${eur(saved)} in ${duration(comboSaveMonths)}',
                        'Then borrow ${eur(comboLoan)}, repaid in '
                            '${duration(comboLoanMonths)}',
                        'All done in '
                            '${duration(comboSaveMonths + comboLoanMonths)}',
                        'Interest earned +${eur(comboEarned)}, '
                            'paid ${eur(comboInterest)}',
                        'You keep '
                            '${eur(interest - comboInterest + comboEarned)} '
                            'compared to the loan',
                        if (insured) insLine('once you buy'),
                      ],
                      extra: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save first: ${(saveShare * 100).round()}%',
                            style: const TextStyle(color: muted),
                          ),
                          Slider(
                            value: saveShare,
                            min: 0.1,
                            max: 0.9,
                            divisions: 8,
                            activeColor: comboColor,
                            label: '${(saveShare * 100).round()}%',
                            onChanged: (v) => setState(() => saveShare = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Loan balance vs. savings over time',
                  style: textTheme.titleLarge?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    LegendItem(color: loanColor, label: 'Option 1 · loan left'),
                    LegendItem(color: saveColor, label: 'Option 2 · saved'),
                    LegendItem(
                      color: comboColor,
                      label: 'Option 3 · saved, then loan left',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PlanChart(
                  series: [
                    (
                      label: 'Loan left',
                      color: loanColor,
                      values: loanBalances(amount, loanRate, months),
                    ),
                    (label: 'Saved', color: saveColor, values: savings),
                    (
                      label: 'Option 3',
                      color: comboColor,
                      // Climbs while saving, drops to the smaller loan at purchase.
                      values: [
                        ...comboSavings,
                        ...loanBalances(
                          comboLoan,
                          loanRate,
                          comboLoanMonths,
                        ).skip(1),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Illustrative example only. Assumes a fixed 5% loan rate '
                  'and 4% p.a. on savings, compounded monthly; fees and '
                  'taxes are not included.',
                  style: textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Equal-height cards in one row when they fit, wrapping otherwise.
Widget cardRow(List<Widget> cards) => LayoutBuilder(
  builder: (context, c) => c.maxWidth >= cards.length * (370 + 16) - 16
      ? IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, card) in cards.indexed) ...[
                if (i > 0) const SizedBox(width: 16),
                card,
              ],
            ],
          ),
        )
      : Wrap(spacing: 16, runSpacing: 16, children: cards),
);

class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.headline,
    required this.lines,
    this.extra,
  });

  final Color color;
  final String title;
  final String subtitle;
  final String headline;
  final List<String> lines;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 370,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: raised,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(subtitle, style: const TextStyle(color: muted)),
          const SizedBox(height: 12),
          Text(
            headline,
            style: const TextStyle(
              color: ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          for (final l in lines)
            Text(l, style: const TextStyle(color: ink, height: 1.6)),
          if (extra != null) ...[const SizedBox(height: 12), extra!],
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  const LegendItem({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: ink)),
      ],
    );
  }
}

/// One chart line: a value per month from month 0.
typedef Series = ({String label, Color color, List<double> values});

/// Value of [s] at [month]; past its end a series holds its last value.
double valueAt(List<double> s, int month) => s[min(month, s.length - 1)];

/// Line chart of monthly series sharing one EUR axis, with hover readout.
class PlanChart extends StatefulWidget {
  const PlanChart({super.key, required this.series});

  final List<Series> series;

  @override
  State<PlanChart> createState() => _PlanChartState();
}

class _PlanChartState extends State<PlanChart> {
  int? hover;

  @override
  Widget build(BuildContext context) {
    final painter = _ChartPainter(widget.series, hover);
    return SizedBox(
      height: 280,
      child: LayoutBuilder(
        builder: (context, box) {
          final h = hover;
          return MouseRegion(
            onHover: (e) => setState(
              () => hover = painter.monthAt(e.localPosition.dx, box.maxWidth),
            ),
            onExit: (_) => setState(() => hover = null),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(size: box.biggest, painter: painter),
                if (h != null)
                  Positioned(
                    left: min(
                      painter.xOf(h, box.maxWidth) + 12,
                      box.maxWidth - 250,
                    ),
                    top: 0,
                    child: _Tooltip(month: h, series: widget.series),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({required this.month, required this.series});

  final int month;
  final List<Series> series;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: raised,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x33000000))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            month == 0 ? 'Start' : 'After ${duration(month)}',
            style: const TextStyle(color: ink, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          for (final s in series)
            LegendItem(
              color: s.color,
              label: '${s.label} ${eur(valueAt(s.values, month))}',
            ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.series, this.hover);

  final List<Series> series;
  final int? hover;

  static const left = 72.0, bottom = 28.0, top = 8.0, right = 16.0;

  int get months => series.map((s) => s.values.length).reduce(max) - 1;
  double get maxY => series.expand((s) => s.values).reduce(max);

  double xOf(int month, double width) =>
      left + (width - left - right) * month / months;

  int monthAt(double x, double width) =>
      ((x - left) / (width - left - right) * months).round().clamp(0, months);

  double yOf(double v, Size size) =>
      top + (size.height - top - bottom) * (1 - v / maxY);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0xFF44474E)
      ..strokeWidth = 1;
    // Horizontal grid + EUR labels.
    for (var i = 0; i <= 4; i++) {
      final v = maxY * i / 4;
      final y = yOf(v, size);
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), grid);
      _text(canvas, eur(v), Offset(left - 8, y), alignRight: true);
    }
    // Year ticks on the x axis.
    final years = months / 12;
    final step = max(1, (years / 8).ceil());
    for (var yr = 0; yr <= years; yr += step) {
      _text(
        canvas,
        yr == 0 ? 'Now' : '${yr}y',
        Offset(xOf(yr * 12, size.width), size.height - bottom + 14),
        center: true,
      );
    }

    for (final s in series) {
      _line(canvas, size, s.values, s.color);
    }

    final h = hover;
    if (h != null) {
      final x = xOf(h, size.width);
      canvas.drawLine(
        Offset(x, top),
        Offset(x, size.height - bottom),
        Paint()
          ..color = muted
          ..strokeWidth = 1,
      );
      for (final s in series) {
        final p = Offset(x, yOf(valueAt(s.values, h), size));
        canvas.drawCircle(p, 6, Paint()..color = panel);
        canvas.drawCircle(p, 4.5, Paint()..color = s.color);
      }
    }
  }

  void _line(Canvas canvas, Size size, List<double> s, Color color) {
    final path = Path()..moveTo(xOf(0, size.width), yOf(s[0], size));
    for (var m = 1; m < s.length; m++) {
      path.lineTo(xOf(m, size.width), yOf(s[m], size));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _text(
    Canvas canvas,
    String s,
    Offset at, {
    bool alignRight = false,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: const TextStyle(color: muted, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignRight
        ? at.dx - tp.width
        : center
        ? at.dx - tp.width / 2
        : at.dx;
    tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.hover != hover || old.series != series;
}
