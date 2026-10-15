# Problem One-Pager (Step 2.4 – Reflection)

Built from the 5 interviews in `intervirews/` and the analysis in `out.md`.
**TBD** = no data yet; needs input from the bank.

---

## 1. Problem

### What is the problem?
Customers have real financial goals (buying a flat, getting a driving licence, investing). They don't link those goals to the bank, so they plan alone.

Bank communication doesn't close this gap:
- Generic notifications get ignored or switched off.
- Important messages (for example, the migration) are unclear.

Customers trust people (advisors, phone) for decisions. The digital channel only handles transactions.

### What is the size of the problem? *(How often does it occur?)*
In the interviews:
- **4 of 5** use few products or have a goal the bank isn't part of (Interviews 2, 3, 4 and 5).
- **3 of 5** ignore notifications, have turned them off, or find them unclear (Interviews 2, 3 and 4).
- **2 of 5** had poor communication during the migration (Interviews 1 and 3).
- **3 of 5** prefer a person (advisor or phone) for decisions (Interviews 2, 4 and 5).

Bank-wide frequency: **TBD**. Needs:
- the notification opt-out rate
- average products per customer
- the number of customers with savings patterns but no matching product

### What metrics and sources is this based on? *(What data informs the perception of the problem?)*
- 5 qualitative customer interviews (October 2026).
- Not yet available:
  - push and notification open and opt-out rates
  - product holding per customer
  - call-centre contact reasons after the migration
  - app usage analytics

---

## 2. Stakeholders

### Who is affected by the problem? *(Who are the stakeholders?)*
- **Customers:**
  - young adults (25–35) saving for big purchases
  - mass-affluent customers interested in investments and insurance
  - premium and migrated customers
- **Bank:**
  - private advisors and branch staff
  - call centre
  - CRM / marketing (notification owners)
  - product owners (loans, investments, insurance)
  - digital / mobile app team
  - migration team

### How many people or departments are involved? *(Calculate in FTE)*
About 6 departments (advisors, call centre, CRM/marketing, product, digital, migration). FTE: **TBD**.

### What metrics and sources is this based on? *(Who did you talk to?)*
5 retail customers:
1. Premium customer
2. Inteligo customer, middle-aged man, ~60k income
3. General-feedback customer
4. Female, 25–35
5. Female, ~30

No internal stakeholders have been interviewed yet.

---

## 3. Process

**1. Current design:**
The bank sends generic messages (push, SMS, e-mail). The customer uses the app for payments, cards and transfers. Products such as loans and investments are offered through general campaigns or by an advisor.

**2. How it is actually lived:**
1. The customer mutes or ignores notifications.
2. The customer makes goal plans alone (Interview 4 decided on her own that buying a flat within 5 years doesn't work).
3. The customer doesn't see that bank products could help (Interview 5 didn't see a loan for her driving licence as useful).
4. Product decisions happen only through an advisor or phone (Interview 2 switched banks because an advisor recommended it).
5. During system changes, customers are left without guidance (Interview 1).

**3. Upcoming planned changes:**
**TBD.** The migration has already happened (October). No other planned changes are known.

**4. Ideal process:**
1. The app spots a goal, either from a savings pattern or because the customer sets one (PFM).
2. The customer gets a few personalised insights linked to that goal, for example "at this rate the flat takes X years; with a loan it takes Y."
3. The customer is offered a one-tap handover to an advisor or phone contact.
4. The matching product is offered at the right moment.
5. Major changes (like the migration) come with step-by-step guidance.

```
Current:  Generic msg → ignored/muted → customer plans alone → no product / leaves for advisor elsewhere
Ideal:    Goal detected → relevant insight in app → talk to a person → right product at right time
```

---

## 4. Business impact

### What is the business impact of the problem? *(Effect on operations and outcomes)*
- Lost cross-sell: loans (housing, consumer), investments and insurance go to competitors, or the customer never buys them.
- Low engagement with notification channels, where marketing effort is wasted.
- Risk of losing customers' trust and the customers themselves after a migration. Advisors are a key retention lever, and they work in both directions.
- Extra call-centre and branch load from unclear communication.

### How big is the business impact? *(Extent to which the business is affected)*
**TBD.** Estimate formula:

```
Lost revenue ≈ (# customers with unlinked goals) × (realistic conversion uplift) × (avg margin per product)
             + (# migration-related contacts) × (cost per contact)
```

### What metrics and sources is this based on? *(Which data did you base your insights on?)*
Currently only the qualitative interviews. Needed:
- product margin per product type
- customer segments by product holding
- conversion rates of current campaigns
- call-centre cost per contact

---

## 5. Decision checkpoints

| Question | Continue? | Note |
|---|---|---|
| Is the problem size worth pursuing? | ☑ Yes (provisional) | Strong qualitative signal; confirm with bank-wide data |
| Are stakeholders willing to support an attempt to solve this? | ☐ Unknown | Internal stakeholders (CRM, product, advisors) not consulted yet |
| Is the business impact worth solving? | ☑ Yes (provisional) | Cross-sell and retention are core revenue levers; quantify with formula above |

## Open data needs (before Step 3)
1. Notification open and opt-out rates.
2. Average products per customer, by segment.
3. Number of customers with saving behaviour but no loan or investment product.
4. Migration-related call-centre volume.
5. FTE involved per department.
6. Interviews with internal stakeholders (advisors, CRM, product).
