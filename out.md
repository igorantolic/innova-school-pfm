# Interview Analysis vs. Hypotheses

Source: 5 interviews in `intervirews/`, compared against `hipotesys.md`.

`hipotesys.md` lists interview questions, not stated hypotheses. The hypothesis behind each set of questions is inferred below.

| # | Inferred hypothesis | Verdict |
|---|---|---|
| H1 | Bank products don't match customers' current life situation and plans. Customers use only a few basic products. | **Supported** |
| H2 | Bank messages don't reach or engage customers. They get ignored or turned off. | **Strongly supported** |
| H3 | Customers bank in a hybrid way: digital for daily tasks, but they want a person for some situations. | **Supported** |

---

## Interview overview

| # | Profile | Products used | Channels | Notifications | Key point |
|---|---|---|---|---|---|
| 1 | Premium customer | Cards | n/a | Poor communication during migration | October migration caused card and address-update problems. No clear guidance. |
| 2 | Inteligo, middle-aged man, ~60k income | Debit card only ("very limited") | Mobile app (likes it), ATM, **private advisor** | Doesn't react much | Interested in investments and insurance. Moved from NBH to RBHU because an advisor recommended it. |
| 3 | General feedback | Cards, mobile app | Mobile app | Wants clearer, more proactive notifications | Doesn't know which products and features exist. Onboarding after migration is weak. |
| 4 | Female, 25–35 | Insurance, card | **Phone** | **Turned OFF** | Saving for a flat. Didn't know loan information could help her decide. Concluded a 5-year purchase plan isn't feasible. |
| 5 | Female, ~30 | n/a | Mobile app, **phone, personal contact** | n/a | Has future plans, but doesn't see a loan for her driving licence as useful. |

---

## H1: Product fit to life situation

**Evidence for:**
- People use few products. Interview 2 has only a debit card. Interview 4 has a card and insurance.
- Life goals exist but aren't linked to bank products:
  - Interview 4 is saving for a flat and didn't know loan information could help. She decided alone that buying within 5 years doesn't work for her.
  - Interview 5 has plans (a driving licence) but doesn't see the bank as part of reaching them.
- There is latent demand that isn't being served. Interview 2 is interested in investment and insurance products but gets information from private advisors, not from the bank's channels.
- Interview 3: customers don't know which products and features are available.

**Evidence against / nuance:**
- Core daily products work well: cards, the app and ATMs are praised (Interviews 2 and 3). The gap is in **life-goal products** (loans, investments, savings planning), not in everyday banking.

**Conclusion:** Supported. The problem is less that products don't fit and more that **customers don't connect their life goals to what the bank offers**. Nobody makes that connection for them at the right moment.

---

## H2: Bank messages and reactions

**Evidence for:**
- Interview 4 turned notifications **OFF** because she dislikes them.
- Interview 2 "does not react that much" to notifications.
- Interview 3 wants **clearer, more proactive** notifications, so current ones don't help.
- Interview 1: during the migration, the most important communication moment, information was unclear and caused real problems with cards and address updates.

**Evidence against:** None. No interviewee said bank messages were useful.

**Conclusion:** Strongly supported. Messages are seen as noise, so people ignore or mute them. The messages that would matter (migration steps, relevant product information) are unclear or missing. **Relevance and timing** are the issue, not volume.

---

## H3: Digital vs. human channels

**Evidence for:**
- Digital is the default for daily banking. The mobile app is liked (Interviews 2, 3 and 5), and the ATM network is valued (Interview 2).
- Human contact matters for advice and decisions:
  - Interview 2 relies on **private advisors**, and an advisor's recommendation made him switch banks.
  - Interview 4 **prefers talking by phone**.
  - Interview 5 uses the phone and personal contact alongside the app.
- Interview 1 needed guidance during the migration, which a person could have given.

**Conclusion:** Supported. The pattern is **app for transactions, people for decisions, problems and trust**. Interviewees were never asked directly *which* situations need a person (question 2 of H3), so this is inferred.

---

## Cross-cutting insights

1. **The advisor is the most effective channel.** The only case where the bank changed a customer's behaviour (Interview 2 switching banks) came from a person, not from a notification.
2. **Unused moments:** people save for a flat, plan a driving licence, are interested in investing, and the bank isn't involved in any of it.
3. **Migration is a trust risk.** Interviews 1 and 3 both point to poor guidance during system changes.
4. **The "notification paradox":** people turn messages off, yet they lack the information they need. This suggests replacing generic pushes with fewer, goal-linked messages or human follow-up.

## Gaps and limitations

- Small sample (5), and the formats differ: Interviews 1–3 are summaries, Interviews 4–5 are short notes.
- Interview 3 includes an "Overall Conclusion" that covers all interviews, so it isn't purely one customer's voice.
- Several hypothesis questions weren't answered directly. Examples: "which messages and via which channels" (H2 Q1) and "walk me through your banking" (H3 Q1).
- Age and gender are missing for Interviews 1–3.

## Suggested next steps

- Turn the inferred hypotheses into testable statements in `hipotesys.md`.
- Ask follow-up questions about **life goals → bank products** (flat, car, education) and **which notifications, if any, people find useful**.
- Test a concept: goal-based savings/loan guidance delivered through an advisor or phone contact instead of push notifications.
