-- NOTE: to use EVENT statements you need MySQL v5.1.6+

-- To check if your mysql server has the event feature enabled
-- enter the mysql command line and type:
 
-- mysql> SHOW PROCESSLIST\G

-- If you have a process with the following information:

--*************************** X. row ***************************
--     Id: 98
--   User: event_scheduler
--   Host: localhost
--     db: NULL
--Command: Daemon
--   Time: 183
--  State: Waiting for next activation
--   Info: NULL

-- the feature is active. Else, you must activate it doing the following
-- on the mysql command line:

-- mysql> SET GLOBAL event_scheduler = ON;

-- To delete this scheduled event: DROP EVENT keep_alive_monitor
-- To disable the scheduled event: ALTER EVENT keep_alive_monitor DISABLE
-- To enable the scheduled event: ALTER EVENT keep_alive_monitor ENABLE





GRANT EVENT ON babeliumproject.* TO babelia@localhost;

delimiter |

CREATE DEFINER = babelia@localhost EVENT IF NOT EXISTS babeliumproject.keep_alive_monitor
    ON SCHEDULE
	EVERY 5 MINUTE
    COMMENT 'This event monitors the users sessions and closes them when needed.'
    DO 
	BEGIN
		UPDATE user_session SET duration = TIMESTAMPDIFF(SECOND,session_date,CURRENT_TIMESTAMP), closed=1 
		WHERE (keep_alive = 0 AND closed=0 AND duration=0);

		UPDATE user_session SET keep_alive = 0 
		WHERE (keep_alive = 1 AND closed = 0);
	END |

delimiter ;