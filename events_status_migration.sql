-- SQL script to modify the events table status column and add trigger for automatic status updates

-- 1. First, update any existing events with incorrect status casing
UPDATE events 
SET status = 'Upcoming'
WHERE status = 'upcoming';

-- 2. Create an enum type for event status
-- Note: If your Supabase setup doesn't support enums, you can use CHECK constraints instead
-- The following commands create a constraint to limit the status values

-- Modify the status column to restrict to allowed values
ALTER TABLE events
ADD CONSTRAINT event_status_check
CHECK (status IN ('Upcoming', 'Ended', 'Cancelled'));

-- Update any 'In Progress' or 'Completed' statuses to the new values
UPDATE events
SET status = 'Ended'
WHERE status IN ('In Progress', 'Completed');

-- 3. Create a function to automatically update event status
CREATE OR REPLACE FUNCTION update_event_status() RETURNS TRIGGER AS $$
BEGIN
    -- Skip if event is already Cancelled (manual status)
    IF NEW.status = 'Cancelled' THEN
        RETURN NEW;
    END IF;
    
    -- Check if the event date has passed and update to Ended if needed
    IF NEW.date < CURRENT_DATE AND NEW.status = 'Upcoming' THEN
        NEW.status := 'Ended';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Create a trigger that runs before insert/update to enforce status logic
CREATE OR REPLACE TRIGGER event_status_update
BEFORE INSERT OR UPDATE ON events
FOR EACH ROW
EXECUTE FUNCTION update_event_status();

-- 5. Create a daily scheduled function to automatically mark past events as Ended
CREATE OR REPLACE FUNCTION auto_update_past_events() RETURNS void AS $$
BEGIN
    -- Update all upcoming events that have passed to Ended status
    UPDATE events
    SET status = 'Ended'
    WHERE date < CURRENT_DATE 
    AND status = 'Upcoming';
END;
$$ LANGUAGE plpgsql;

-- Note: To schedule this function to run daily, you would typically use pgAgent,
-- Supabase Edge Functions with a CRON schedule, or an external scheduler.
-- Here's an example SQL that would schedule it with pg_cron (if available):
-- SELECT cron.schedule('0 0 * * *', $$SELECT auto_update_past_events();$$);
-- This sets it to run at midnight every day.

-- 6. Add a default value for new events
ALTER TABLE events 
ALTER COLUMN status SET DEFAULT 'Upcoming';

-- Example usage of the scheduled function manually:
-- SELECT auto_update_past_events();

-- Done! 