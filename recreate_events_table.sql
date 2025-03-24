-- SQL Script to recreate the events table with proper time handling

-- 1. First, create a backup of the existing events table
CREATE TABLE events_backup AS 
SELECT * FROM events;

-- 2. Save staff assignments for later restoration
CREATE TABLE event_staff_backup AS
SELECT * FROM event_staff;

-- 3. Drop dependencies (event_staff references events)
DROP TABLE IF EXISTS event_staff;

-- 4. Drop the current events table
DROP TABLE IF EXISTS events;

-- 5. Create a new events table with proper column types
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR NOT NULL,
    date DATE NOT NULL,
    time VARCHAR(5), -- Using VARCHAR instead of TIME type to avoid PostgreSQL time format issues
    venue VARCHAR,
    address TEXT,
    customer_id UUID REFERENCES customers(id),
    notes TEXT,
    status VARCHAR DEFAULT 'Upcoming',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Create index for faster searches
CREATE INDEX events_date_idx ON events(date);
CREATE INDEX events_status_idx ON events(status);
CREATE INDEX events_customer_id_idx ON events(customer_id);

-- 7. Restore data from backup, handling the time field carefully
INSERT INTO events (
    id, title, date, time, venue, address, customer_id, notes, status, created_at, updated_at
)
SELECT 
    id, title, date, 
    CASE 
        WHEN time IS NULL THEN NULL
        ELSE 
            -- Try to safely convert the time to text
            COALESCE(CAST(time AS text), NULL)
    END as time,
    venue, address, customer_id, notes, status, created_at, updated_at
FROM events_backup;

-- 8. Recreate the event_staff table
CREATE TABLE event_staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(event_id, employee_id)
);

-- 9. Restore event_staff data
INSERT INTO event_staff (id, event_id, employee_id, created_at)
SELECT id, event_id, employee_id, created_at
FROM event_staff_backup
WHERE event_id IN (SELECT id FROM events);

-- 10. Add database trigger to automatically handle empty strings in time field
CREATE OR REPLACE FUNCTION handle_events_time() RETURNS TRIGGER AS $$
BEGIN
    -- If time is empty string, set to NULL
    IF NEW.time = '' THEN
        NEW.time := NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to run this function before insert/update
DROP TRIGGER IF EXISTS events_time_trigger ON events;
CREATE TRIGGER events_time_trigger
BEFORE INSERT OR UPDATE ON events
FOR EACH ROW
EXECUTE FUNCTION handle_events_time();

-- 11. Create a trigger for updated_at
CREATE OR REPLACE FUNCTION update_events_timestamp() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER events_timestamp_trigger
BEFORE UPDATE ON events
FOR EACH ROW
EXECUTE FUNCTION update_events_timestamp();

-- 12. Drop backup tables (optional - you may want to keep them for safety)
-- DROP TABLE events_backup;
-- DROP TABLE event_staff_backup;

-- 13. Test query
SELECT * FROM events LIMIT 5;