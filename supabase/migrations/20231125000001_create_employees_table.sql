-- Create a table for employees
CREATE TABLE IF NOT EXISTS public.employees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT NOT NULL,
  role TEXT NOT NULL,
  salary TEXT NOT NULL,
  startDate TEXT,
  address TEXT,
  emergencyContact TEXT,
  notes TEXT,
  status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'On Leave', 'Unavailable')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create a trigger to update the updated_at column
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_employees_updated_at
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Set up RLS policies for employees table
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users to read all employees
CREATE POLICY "Authenticated users can read all employees"
ON public.employees
FOR SELECT
USING (auth.role() = 'authenticated');

-- Create policy for authenticated users to insert employees
CREATE POLICY "Authenticated users can insert employees"
ON public.employees
FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- Create policy for authenticated users to update employees
CREATE POLICY "Authenticated users can update employees"
ON public.employees
FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Create policy for authenticated users to delete employees
CREATE POLICY "Authenticated users can delete employees"
ON public.employees
FOR DELETE
USING (auth.role() = 'authenticated'); 