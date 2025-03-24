-- SQL Migration to fix time column in events table to properly handle NULL values

-- 1. Check if the time column allows NULL values
DO $$
DECLARE
    column_nullable boolean;
BEGIN
    SELECT is_nullable = 'YES' INTO column_nullable
    FROM information_schema.columns
    WHERE table_name = 'events' AND column_name = 'time';
    
    -- If time column doesn't allow NULL, alter it
    IF NOT column_nullable THEN
        ALTER TABLE events ALTER COLUMN time DROP NOT NULL;
        RAISE NOTICE 'Modified time column to allow NULL values';
    ELSE
        RAISE NOTICE 'Time column already allows NULL values';
    END IF;
END $$;

-- 2. Update any rows with empty string time values to NULL
UPDATE events
SET time = NULL
WHERE time = '';

-- 3. Add a trigger to automatically handle empty string time values
CREATE OR REPLACE FUNCTION handle_empty_time_values()
RETURNS TRIGGER AS $$
BEGIN
    -- Convert empty strings to NULL for time column
    IF NEW.time = '' THEN
        NEW.time := NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create or replace the trigger
DROP TRIGGER IF EXISTS handle_empty_time_trigger ON events;
CREATE TRIGGER handle_empty_time_trigger
BEFORE INSERT OR UPDATE ON events
FOR EACH ROW
EXECUTE FUNCTION handle_empty_time_values();

-- Verify changes
SELECT 
    column_name, 
    data_type, 
    is_nullable 
FROM 
    information_schema.columns 
WHERE 
    table_name = 'events' 
    AND column_name = 'time';

-- Done! 