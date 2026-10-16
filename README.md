# Inbound Lead Engine

An AI-powered lead qualification and outreach system built in **n8n**. It scores inbound leads with Gemini, routes them by fit, runs personalised outreach with follow-up, logs everything to HubSpot, and stores the full lead lifecycle in SQLite for RevOps reporting.

## The problem

Inbound leads often sit in a spreadsheet or inbox for hours before anyone looks at them. By then, interest has cooled. Reps also waste time on leads that were never a fit, and follow-ups get forgotten.

This engine fixes that: it scores every lead the moment it arrives, lets only qualified leads reach outreach, and automatically replies or follows up with every contacted lead.

## What it does

1. **Intake:** watches a Google Sheet for new leads (sourced via Clay).
2. **AI scoring:** Gemini scores each lead 1–100 against ICP rules and returns written reasoning plus a `qualified` flag.
3. **Routing:** a lead is **Hot** only if score ≥ 70 **and** qualified. A high score alone isn't enough (for example, an employee of a vendor scores 95 but is disqualified as an insider).
4. **Outreach (Hot leads):** sends a personalised Gmail email, creates the contact in HubSpot, and logs the AI score and reasoning as a note.
5. **Follow-up:** waits 2 days, then checks the thread:
   - **Reply:** AI drafts and sends a response, logged in HubSpot.
   - **No reply:** sends one nudge.
6. **Tracking:** every status change (Scored → Contacted → Replied / Nudged, or Cold) is written to both Google Sheets and SQLite.

## Tech stack
n8n · Google Gemini API · Gmail · Google Sheets · HubSpot CRM · SQLite · Clay

## RevOps reporting
`reports.sql` runs four reports on the lead database:

| Report | Question it answers |
|---|---|
| Pipeline by tier | How much of the pipeline is Hot vs Cold, and at what scores? |
| Status funnel | Where are leads in the journey? |
| Account view | Which companies have multiple Hot leads (multi-threading opportunities)? |
| Reply rate | What % of contacted leads reply? |

Sample insight from a 15-lead test batch: 12 Hot (avg score 91.2) vs 3 Cold. Twine and what3words each had 2 Hot leads, making them the top accounts to multi-thread.

Run all reports:

```
sqlite3 leads.db < reports.sql
```

## Files
- `workflow.json`: the n8n workflow (API key replaced with a placeholder)
- `schema.sql`: SQLite table design
- `reports.sql`: RevOps reporting queries

Lead data is not included in this repo.

## Setup
1. Create the database: `sqlite3 leads.db < schema.sql`
2. Start n8n with the Execute Command node enabled: `NODES_EXCLUDE="[]" n8n start`
3. Import `workflow.json` into n8n.
4. Replace `YOUR_GEMINI_API_KEY` in the AI Score Lead and AI Draft Reply nodes.
5. Connect your Google Sheets, Gmail and HubSpot credentials.

## Business impact

- **Speed to lead:** the sheet is checked every minute, so a new lead is scored and, if Hot, emailed within minutes of being added, instead of waiting in someone's inbox for manual review.
- **Reps only work qualified leads:** in a 15-lead test batch, 3 leads were filtered out as Cold before any rep time was spent on them.
- **Explainable scoring in the CRM:** each HubSpot contact shows the AI score *and* the reason, so a rep can trust it or override it.
- **No lead falls through the cracks:** every contacted lead gets either an AI-drafted reply or a follow-up nudge, and its status is always up to date.
- **Account-level insight:** the reporting flagged Twine and what3words as accounts with 2 Hot leads each, ready for a multi-threaded approach.

## Key design decisions

1. **Score + qualified gate.** A high score alone isn't enough. A lead must score 70+ *and* be marked qualified, which stops false positives such as vendor employees.
2. **Stable matching.** Sheet rows are matched on LinkedIn URL, not row number, so sorting or deleting rows never breaks updates.
3. **Database for reporting.** Google Sheets shows the current status but overwrites history. SQLite keeps timestamps, which makes reply rate and funnel reporting possible.
4. **Every branch tested end to end.** Cold, Contacted, Replied and Nudged paths were each run with test leads, because the worst bugs fail silently.
5. **No secrets in the repo.** API keys are replaced with placeholders before publishing.

## What I'd build next
- Slack alert when a Hot lead arrives
- A/B testing of outreach email copy
- Reply rate broken down by industry and job title
- Moving from SQLite to Postgres for multi-user reporting
