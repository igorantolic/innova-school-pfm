import 'dart:math';

import 'package:flutter/material.dart';

const loanRate = 0.05; // ponytail: example fixed rate, real offers vary.
const savingsRate = 0.04; // Example savings account rate, compounded monthly.

// Option accent colors, validated for CVD separation and contrast on the dark panel.
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

/// Largest loan that [pay] a month repays at [rate] p.a. over [months].
double affordableLoan(double pay, double rate, int months) {
  final r = rate / 12;
  return max(0, pay * (1 - pow(1 + r, -months)) / r);
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

enum Pick { loan, save, combo }

/// Saving when it takes at most 3 months or no loan fits [budget]; the loan
/// when its instalment fits [budget]; otherwise save a deposit first, then
/// borrow what [budget] can repay.
Pick recommend({
  required int saveMonths,
  required double loanPay,
  required double budget,
}) => saveMonths <= 3
    ? Pick.save
    : loanPay <= budget
    ? Pick.loan
    : budget > 0
    ? Pick.combo
    : Pick.save;

/// Optional insurance add-on for a goal; [monthly] is an example price.
typedef Insurance = ({String name, double monthly, String covers});

/// Moves a tile's picture for animation progress [t] (0 → 1 → 0, eased).
typedef Motion = Widget Function(double t, Widget child);

/// A goal to plan for. Amounts (EUR) and [years] are the sliders' start values.
typedef Goal = ({
  String title,
  IconData icon,
  Motion motion,
  String costLabel,
  String ownLabel,
  double cost,
  double maxCost,
  double step,
  double own,
  double budget,
  ({int min, int initial, int max}) years,
  Insurance? insurance,
  List<(String, String)> info,
});

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

Future<void> showPlan(BuildContext context, Goal goal) =>
    showDialog(context: context, builder: (_) => PlanDialog(goal: goal));

class PlanDialog extends StatefulWidget {
  const PlanDialog({super.key, required this.goal});

  final Goal goal;

  @override
  State<PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<PlanDialog> {
  late double cost = widget.goal.cost;
  late double own = widget.goal.own;
  late double budget = widget.goal.budget;
  late int years = widget.goal.years.initial;
  bool insured = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.goal;
    final textTheme = Theme.of(context).textTheme;
    final highlight = Theme.of(context).colorScheme.primary;
    final amount = cost - own;
    final months = years * 12;
    final ins = g.insurance;
    // Insurance starts once you own it, so it shares the budget with the loan.
    final loanBudget = budget - (insured ? ins!.monthly : 0);
    final pay = amount > 0 ? monthlyPayment(amount, loanRate, months) : 0.0;
    final interest = pay * months - amount;
    final savings = savingsBalances(amount, savingsRate, budget);
    final saveMonths = savings.length - 1;
    final earned = savingsInterest(savings, savingsRate);
    final pick = recommend(
      saveMonths: saveMonths,
      loanPay: pay,
      budget: loanBudget,
    );
    // Deposit big enough that the rest is a loan repaid at loanBudget a month.
    final comboLoan = affordableLoan(loanBudget, loanRate, months);
    final deposit = amount - comboLoan;
    final comboSavings = savingsBalances(deposit, savingsRate, budget);
    final comboSaveMonths = comboSavings.length - 1;
    final comboEarned = savingsInterest(comboSavings, savingsRate);
    final comboInterest = loanBudget * months - comboLoan;
    String insLine(String from) =>
        '+ ${eur(ins!.monthly)} / month ${ins.name.toLowerCase()} $from';

    final reason = switch (pick) {
      Pick.save when saveMonths <= 3 =>
        'Save first. Putting aside ${eur(budget)} a month, you will have '
            '${eur(amount)} in ${duration(saveMonths)} – a short wait that '
            'avoids loan interest.',
      Pick.save =>
        'Save first. Your monthly budget does not leave room for a loan '
            'instalment, so put ${eur(budget)} a month aside – you will have '
            '${eur(amount)} in ${duration(saveMonths)}.',
      Pick.loan =>
        'Take the loan. The ${eur(pay)} monthly instalment fits the '
            '${eur(loanBudget)} you can spare, so you can buy now.',
      Pick.combo =>
        'Save a deposit first. A loan for the full ${eur(amount)} over '
            '${duration(months)} costs ${eur(pay)} a month – more than the '
            '${eur(loanBudget)} you can spare. Save ${eur(deposit)} in '
            '${duration(comboSaveMonths)}, then borrow the rest at '
            '${eur(loanBudget)} a month.',
    };

    final cards = {
      Pick.loan: OptionCard(
        color: loanColor,
        title: 'Take a loan now',
        headline: '${eur(pay)} / month',
        description:
            'Borrow ${eur(amount)} today and buy right away. You repay it in '
            'equal monthly instalments over ${duration(months)}, and the bank '
            'charges 5% a year on what you still owe.',
        lines: [
          'Total interest ${eur(interest)}',
          'Total repaid ${eur(pay * months)}',
          pay <= loanBudget
              ? 'Leaves ${eur(loanBudget - pay)} of your monthly budget free'
              : '${eur(pay - loanBudget)} a month over your budget',
          if (insured) insLine('from day one'),
        ],
        recommended: pick == Pick.loan,
      ),
      Pick.save: OptionCard(
        color: saveColor,
        title: 'Save, then buy',
        headline: '${eur(budget)} / month',
        description:
            'Put ${eur(budget)} aside each month in a savings account earning '
            '4% a year. Once you have ${eur(amount)}, you buy outright – no '
            'loan, no interest, nothing to repay. The trade-off is the wait.',
        lines: [
          'Ready in ${duration(saveMonths)}',
          'Interest earned +${eur(earned)}',
          'You keep ${eur(interest + earned)} compared to the loan',
          if (insured) insLine('once you buy'),
        ],
        recommended: pick == Pick.save,
      ),
      if (pick == Pick.combo)
        Pick.combo: OptionCard(
          color: comboColor,
          title: 'Save a deposit, then borrow',
          headline: '${eur(budget)} / month',
          description:
              'Save ${eur(budget)} a month until you have a ${eur(deposit)} '
              'deposit, then buy and borrow the remaining ${eur(comboLoan)}. '
              'The loan is sized so its instalment is ${eur(loanBudget)} a '
              'month – what you can afford – for ${duration(months)}.',
          lines: [
            'Deposit ready in ${duration(comboSaveMonths)}',
            'You buy ${duration(saveMonths - comboSaveMonths)} sooner than '
                'saving it all',
            'All done in ${duration(comboSaveMonths + months)}',
            'Interest earned +${eur(comboEarned)}, '
                'paid ${eur(comboInterest)}',
            if (insured) insLine('once you buy'),
          ],
          recommended: true,
        ),
    };

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
                      'Your ${g.title.toLowerCase()} plan',
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
              const SizedBox(height: 16),
              Wrap(
                spacing: 32,
                runSpacing: 8,
                children: [
                  AmountSlider(
                    label: g.costLabel,
                    value: cost,
                    from: g.step,
                    to: g.maxCost,
                    step: g.step,
                    onChanged: (v) => setState(() {
                      cost = v;
                      own = min(own, v);
                    }),
                  ),
                  AmountSlider(
                    label: g.ownLabel,
                    value: own,
                    from: 0,
                    to: cost,
                    step: g.step,
                    onChanged: (v) => setState(() => own = v),
                  ),
                  AmountSlider(
                    label: 'I can put aside each month',
                    value: budget,
                    from: 50,
                    to: 3000,
                    step: 50,
                    onChanged: (v) => setState(() => budget = v),
                  ),
                  AmountSlider(
                    label: 'Loan term',
                    value: years.toDouble(),
                    from: g.years.min.toDouble(),
                    to: g.years.max.toDouble(),
                    step: 1,
                    format: (v) => duration(v.round() * 12),
                    onChanged: (v) => setState(() => years = v.round()),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                own > 0
                    ? 'You need ${eur(amount)} '
                          '(${eur(cost)} minus your ${eur(own)}).'
                    : 'You need ${eur(amount)}.',
                style: textTheme.titleMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 24),
              if (amount <= 0)
                Text(
                  'Your savings already cover it – no loan or extra saving '
                  'needed.',
                  style: textTheme.titleLarge?.copyWith(color: ink),
                )
              else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: raised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: highlight, width: 2),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, color: highlight),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason,
                          style: textTheme.titleMedium?.copyWith(color: ink),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                // Recommended option first.
                cardRow([
                  cards[pick]!,
                  for (final e in cards.entries)
                    if (e.key != pick) e.value,
                ]),
                const SizedBox(height: 12),
                Text(
                  'Illustrative example only. Assumes a fixed 5% loan rate '
                  'and 4% p.a. on savings, compounded monthly; fees and '
                  'taxes are not included.',
                  style: textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
              if (g.info.isNotEmpty) ...[
                const Divider(height: 40),
                Text(
                  'Good to know',
                  style: textTheme.titleLarge?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                for (final (title, body) in g.info)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    shape: const Border(),
                    leading: Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                    expandedAlignment: Alignment.centerLeft,
                    childrenPadding: const EdgeInsets.only(
                      left: 40,
                      bottom: 12,
                    ),
                    children: [
                      Text(body, style: const TextStyle(color: muted)),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Labelled slider snapping to [step], showing its value (EUR by default).
class AmountSlider extends StatelessWidget {
  const AmountSlider({
    super.key,
    required this.label,
    required this.value,
    required this.from,
    required this.to,
    required this.step,
    required this.onChanged,
    this.format = eur,
  });

  final String label;
  final double value, from, to, step;
  final ValueChanged<double> onChanged;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(color: muted)),
              ),
              Text(
                format(value),
                style: const TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: from,
            max: to,
            divisions: max(1, ((to - from) / step).round()),
            label: format(value),
            semanticFormatterCallback: format,
            onChanged: onChanged,
          ),
        ],
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
    required this.headline,
    required this.description,
    required this.lines,
    this.recommended = false,
  });

  final Color color;
  final String title;
  final String headline;
  final String description;
  final List<String> lines;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    final highlight = Theme.of(context).colorScheme.primary;
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
          if (recommended) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: highlight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Recommended for you',
                style: TextStyle(color: panel, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headline,
            style: const TextStyle(
              color: ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: muted, height: 1.5)),
          const SizedBox(height: 12),
          for (final l in lines)
            Text(l, style: const TextStyle(color: ink, height: 1.6)),
        ],
      ),
    );
  }
}
