with session_info as (
SELECT
     s.date,
     s.ga_session_id,
     sp.country,
     sp.device,
     sp.continent,
     sp.channel,
     ab.test,
     ab.test_group
FROM `DA.ab_test` ab
JOIN `DA.session` s
   ON ab.ga_session_id = s.ga_session_id
JOIN `DA.session_params` sp
   ON sp.ga_session_id = s.ga_session_id
),


session_orders as (
SELECT
     si.date,
     si.ga_session_id,
     si.country,
     si.device,
     si.continent,
     si.channel,
     si.test,
     si.test_group,
     COUNT(DISTINCT o.ga_session_id) AS sessions_with_orders
FROM `DA.order` o
JOIN session_info si
   ON o.ga_session_id = si.ga_session_id
GROUP BY
     si.date,
     si.ga_session_id,
     si.country,
     si.device,
     si.continent,
     si.channel,
     si.test,
     si.test_group
),


session_events as (
SELECT
     si.date,
     si.ga_session_id,
     si.country,
     si.device,
     si.continent,
     si.channel,
     si.test,
     si.test_group,
     ep.event_name,
     COUNT(ep.ga_session_id) AS sessions_with_events
FROM `DA.event_params` ep
JOIN session_info si
   ON ep.ga_session_id = si.ga_session_id
GROUP BY
     si.date,
     si.ga_session_id,
     si.country,
     si.device,
     si.continent,
     si.channel,
     si.test,
     si.test_group,
     ep.event_name
),


session_count as (
SELECT
     si.date,
     si.ga_session_id,
     si.country,
     si.device,
     si.continent,
     si.channel,
     si.test,
     si.test_group,
     COUNT(DISTINCT si.ga_session_id) as session_count
FROM session_info si
GROUP BY
     si.date,
     si.ga_session_id,
     si.country,
     si.device,
     si.continent,
     si.channel,
     si.test,
     si.test_group
),


account_count as (
SELECT
     si.date,
     si.ga_session_id,
     si.country,
     si.device,
     si.continent,
     si.channel,
     si.test,
     si.test_group,
     COUNT(DISTINCT acs.ga_session_id) as new_accounts_cnt
FROM `DA.account_session` acs
JOIN session_info si
ON acs.ga_session_id = si.ga_session_id
GROUP BY
     si.date,
     si.ga_session_id,
     si.country,
     si.device,
     si.continent,
     si.channel,
     si.test,
     si.test_group
)


SELECT
     so.date,
     so.ga_session_id,
     so.country,
     so.device,
     so.continent,
     so.channel,
     so.test,
     so.test_group,
     'session with orders' as event_name,
     sessions_with_orders as value
FROM session_orders so


UNION ALL


SELECT
     se.date,
     se.ga_session_id,
     se.country,
     se.device,
     se.continent,
     se.channel,
     se.test,
     se.test_group,
     se.event_name,
     sessions_with_events as value
FROM session_events se


UNION ALL


SELECT
     sc.date,
     sc.ga_session_id,
     sc.country,
     sc.device,
     sc.continent,
     sc.channel,
     sc.test,
     sc.test_group,
     'session' as event_name,
     session_count as value
FROM session_count sc


UNION ALL


SELECT
     ac.date,
     ac.ga_session_id,
     ac.country,
     ac.device,
     ac.continent,
     ac.channel,
     ac.test,
     ac.test_group,
     'new_account' as event_name,
     new_accounts_cnt as value
FROM account_count ac




