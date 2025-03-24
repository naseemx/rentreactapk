import { createClient } from '@supabase/supabase-js';

// Initialize Supabase client
const supabaseUrl = 'https://wncwlshtddeelkutqyrq.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InduY3dsc2h0ZGRlZWxrdXRxeXJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2NDQ3NTgsImV4cCI6MjA1ODIyMDc1OH0.BbT5O4rK8ShDwcpfLtqcm71ieCHwiBF6In1OTyvu8ns';
const supabase = createClient(supabaseUrl, supabaseKey);

// Sample employee data
const sampleEmployees = [
  {
    name: "David Miller",
    email: "david.m@example.com",
    phone: "(555) 123-7890",
    role: "Photographer",
    salary: "4500",
    start_date: "01/15/2022",
    address: "123 Main St, Anytown, USA 12345",
    emergency_contact: "Jane Miller (555) 987-6543",
    notes: "Specializes in outdoor and event photography. Prefers weekend assignments.",
    status: "Active",
  },
  {
    name: "Jessica Taylor",
    email: "jessica.t@example.com",
    phone: "(555) 456-7891",
    role: "Event Manager",
    salary: "5200",
    start_date: "03/10/2021",
    address: "456 Oak Ave, Somewhere, USA 54321",
    emergency_contact: "Mark Taylor (555) 765-4321",
    notes: "Excellent at coordinating large events. Has experience with weddings and corporate events.",
    status: "Active",
  },
  {
    name: "Ryan Cooper",
    email: "ryan.c@example.com",
    phone: "(555) 789-1234",
    role: "Equipment Technician",
    salary: "3800",
    start_date: "09/20/2022",
    address: "789 Pine St, Anytown, USA 12345",
    emergency_contact: "Sarah Cooper (555) 432-1098",
    notes: "Knowledgeable about maintaining and repairing all types of photography equipment.",
    status: "On Leave",
  },
  {
    name: "Amanda Wilson",
    email: "amanda.w@example.com",
    phone: "(555) 234-5678",
    role: "Assistant Photographer",
    salary: "3200",
    start_date: "05/05/2023",
    address: "101 Maple Dr, Somewhere, USA 54321",
    emergency_contact: "John Wilson (555) 876-5432",
    notes: "Excellent eye for detail. Learning to take on more complex photography assignments.",
    status: "Active",
  },
  {
    name: "Mark Johnson",
    email: "mark.j@example.com",
    phone: "(555) 876-5432",
    role: "Videographer",
    salary: "4800",
    start_date: "11/15/2021",
    address: "202 Elm St, Anytown, USA 12345",
    emergency_contact: "Lisa Johnson (555) 345-6789",
    notes: "Specializes in wedding videos and documentaries. Expert in video editing.",
    status: "Unavailable",
  }
];

async function seedEmployees() {
  console.log('Starting to seed employees...');
  
  try {
    console.log('Inserting employees to Supabase...');
    
    // Insert each employee directly without checking if table exists
    for (const employee of sampleEmployees) {
      try {
        const { data, error } = await supabase
          .from('employees')
          .upsert(
            employee,
            { 
              onConflict: 'email',
              ignoreDuplicates: false
            }
          );
        
        if (error) {
          console.error(`Error inserting employee ${employee.name}:`, error);
        } else {
          console.log(`Employee ${employee.name} inserted or updated successfully.`);
        }
      } catch (employeeError) {
        console.error(`Error processing employee ${employee.name}:`, employeeError);
      }
    }
    
    console.log('Employee seeding completed!');
  } catch (error) {
    console.error('An unexpected error occurred:', error);
  }
}

// Run the seed function
seedEmployees(); 