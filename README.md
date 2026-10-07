# Inbound Lead Engine

An AI-powered lead qualification and outreach system built in **n8n**. It scores inbound leads with Gemini, routes them by fit, runs personalised outreach with follow-up, logs everything to HubSpot, and stores the full lead lifecycle in SQLite for RevOps reporting.

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

## What I learned
- Debugging n8n item linking: after Wait and Gmail steps, expressions referencing earlier nodes can resolve empty, so later nodes read from their direct input instead.
- Tracing a silent failure (sheet updates returning no output) to a node pointing at an old copy of the spreadsheet.
- Designing the qualification gate so the AI's judgement, not just the score, decides routing.
