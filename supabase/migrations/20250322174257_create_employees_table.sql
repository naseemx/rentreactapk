-- Create employees table
CREATE TABLE employees (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT NOT NULL,
  role TEXT NOT NULL,
  salary TEXT NOT NULL,
  start_date TEXT,
  address TEXT,
  emergency_contact TEXT,
  notes TEXT,
  status TEXT DEFAULT 'Active' CHECK (status IN ('Active', 'On Leave', 'Unavailable')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users to read all employees
CREATE POLICY "Authenticated users can read employees" 
  ON employees 
  FOR SELECT 
  TO authenticated 
  USING (true);

-- Create policy for authenticated users to insert employees
CREATE POLICY "Authenticated users can insert employees" 
  ON employees 
  FOR INSERT 
  TO authenticated 
  WITH CHECK (true);

-- Create policy for authenticated users to update employees
CREATE POLICY "Authenticated users can update employees" 
  ON employees 
  FOR UPDATE 
  TO authenticated 
  USING (true);

-- Create policy for authenticated users to delete employees
CREATE POLICY "Authenticated users can delete employees" 
  ON employees 
  FOR DELETE 
  TO authenticated 
  USING (true);

-- Create function to update updated_at automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update updated_at before each update
CREATE TRIGGER update_employees_updated_at
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
