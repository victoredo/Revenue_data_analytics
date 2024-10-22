WITH 

open_accounts AS (
   SELECT
       user_id_hashed,
       account_id_hashed,
       created_ts,
       closed_ts,
       account_status
   FROM analytics-take-home-test.victor_okon_take_home_task.unified_account_model
   WHERE account_status in  ('open', 'reopened')
),

-- generate a list of unique dates (calculation dates)
unique_transaction_dates AS (
   SELECT DISTINCT CAST(tr.date AS DATE) AS calculation_date
   FROM `analytics-take-home-test.monzo_datawarehouse.account_transactions` tr
),

transactions_last_7_days AS (
   SELECT
       uad.calculation_date,
       oa.user_id_hashed,
       COUNT(DISTINCT oa.account_id_hashed) AS open_accounts,
       SUM(CASE 
               WHEN DATE(tr.date) BETWEEN DATE_SUB(uad.calculation_date, INTERVAL 7 DAY) AND uad.calculation_date
               THEN 1 ELSE 0
           END) AS transactions_in_last_7_days
   FROM unique_transaction_dates uad
   JOIN open_accounts oa
       ON uad.calculation_date BETWEEN CAST(oa.created_ts AS DATE) AND COALESCE(CAST(oa.closed_ts AS DATE), uad.calculation_date)
   LEFT JOIN `analytics-take-home-test.monzo_datawarehouse.account_transactions` tr
       ON oa.account_id_hashed = tr.account_id_hashed
   GROUP BY uad.calculation_date, oa.user_id_hashed
),

active_user_rate AS (
   SELECT
       t.calculation_date,
       COUNT(DISTINCT CASE WHEN t.transactions_in_last_7_days > 0 THEN t.user_id_hashed END) AS active_users,
       COUNT(DISTINCT t.user_id_hashed) AS total_open_users,
       COUNT(DISTINCT CASE WHEN t.transactions_in_last_7_days > 0 THEN t.user_id_hashed END) / 
       COUNT(DISTINCT t.user_id_hashed) AS seven_day_active_user_rate
   FROM transactions_last_7_days t
   GROUP BY t.calculation_date
)

SELECT *
FROM  active_user_rate
order by calculation_date



