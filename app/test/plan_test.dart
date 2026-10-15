import 'package:flutter_test/flutter_test.dart';
import 'package:rba_app/plan.dart';

void main() {
  test('5% loan maths', () {
    // 10,000 over 12 months at 5% p.a. -> 856.07 per month (standard annuity).
    expect(monthlyPayment(10000, 0.05, 12), closeTo(856.07, 0.01));
    final b = loanBalances(10000, 0.05, 12);
    expect(b.first, 10000);
    expect(b.last, closeTo(0, 0.01));
    expect(eur(1234567.4), '€1,234,567');
    // Paying the 12-month instalment repays it in 12 months; half takes ~6.
    final pay = monthlyPayment(10000, 0.05, 12);
    expect(monthsToRepay(10000, 0.05, pay), 12);
    expect(monthsToRepay(5000, 0.05, pay), 6);
    // 100/month at 4%: month 2 = 100 * 1.00333 + 100; capped at target.
    final s = savingsBalances(250, 0.04, 100);
    expect(s, [0, 100, closeTo(200.33, 0.01), 250]);
    expect(savingsInterest(s, 0.04), closeTo((100 + 200.33) * 0.04 / 12, 0.01));
  });
}
