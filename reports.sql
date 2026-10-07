-- Inbound Lead Engine: RevOps reports
.headers on
.mode column

-- 1. Pipeline by tier
SELECT tier,
       COUNT(*) AS leads,
       ROUND(AVG(lead_score), 1) AS avg_score,
       MIN(lead_score) AS min_score,
       MAX(lead_score) AS max_score
FROM leads
GROUP BY tier
ORDER BY leads DESC;

-- 2. Status funnel
SELECT status,
       COUNT(*) AS leads,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM leads), 1) AS pct_of_total
FROM leads
GROUP BY status
ORDER BY leads DESC;

-- 3. Account view (multi-threading opportunities)
SELECT company,
       COUNT(*) AS leads,
       SUM(CASE WHEN tier = 'Hot' THEN 1 ELSE 0 END) AS hot_leads,
       ROUND(AVG(lead_score), 1) AS avg_score
FROM leads
GROUP BY company
ORDER BY hot_leads DESC, avg_score DESC;

-- 4. Reply rate (fills in once outreach runs live)
SELECT SUM(CASE WHEN contacted_at IS NOT NULL THEN 1 ELSE 0 END) AS contacted,
       SUM(CASE WHEN replied_at IS NOT NULL THEN 1 ELSE 0 END) AS replied,
       ROUND(100.0 * SUM(CASE WHEN replied_at IS NOT NULL THEN 1 ELSE 0 END)
             / NULLIF(SUM(CASE WHEN contacted_at IS NOT NULL THEN 1 ELSE 0 END), 0), 1) AS reply_rate_pct
FROM leads;
