import 'package:flutter_test/flutter_test.dart';
import 'package:rba_app/plan.dart';

void main() {
  test('5% loan maths', () {
    // 10,000 over 12 months at 5% p.a. -> 856.07 per month (standard annuity).
    final pay = monthlyPayment(10000, 0.05, 12);
    expect(pay, closeTo(856.07, 0.01));
    expect(affordableLoan(pay, 0.05, 12), closeTo(10000, 0.01));
    expect(affordableLoan(0, 0.05, 12), 0);
    expect(eur(1234567.4), '€1,234,567');
    // 100/month at 4%: month 2 = 100 * 1.00333 + 100; capped at target.
    final s = savingsBalances(250, 0.04, 100);
    expect(s, [0, 100, closeTo(200.33, 0.01), 250]);
    expect(savingsInterest(s, 0.04), closeTo((100 + 200.33) * 0.04 / 12, 0.01));
  });

  test('recommendation', () {
    // Quick saving beats any loan.
    expect(recommend(saveMonths: 3, loanPay: 50, budget: 100), Pick.save);
    expect(recommend(saveMonths: 10, loanPay: 90, budget: 100), Pick.loan);
    // Loan over budget and saving takes > 3 months: deposit, then borrow.
    expect(recommend(saveMonths: 10, loanPay: 900, budget: 100), Pick.combo);
    // Nothing left for an instalment (e.g. insurance eats the budget).
    expect(recommend(saveMonths: 10, loanPay: 900, budget: 0), Pick.save);
  });
}
