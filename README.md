# TempHelo Rental Management App

A mobile application for managing equipment rentals, events, finances, and more. Built with React Native and Supabase.

## Getting Started

### Prerequisites

- Node.js (v14 or later)
- npm or yarn
- Expo CLI

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd apkreactv1
```

2. Install dependencies:
```bash
npm install
# or
yarn install
```

3. Start the development server:
```bash
npm run start
# or
yarn start
```

4. Run on the platform of your choice:
```bash
npm run android
# or
npm run ios
# or
npm run web
```

## Database Setup

The application uses Supabase as its backend database. The application will work with a fresh Supabase database, but it will show empty data. To populate the database with sample data:

1. Ensure you have Node.js installed
2. Navigate to the scripts directory:
```bash
cd temphelo/scripts
```

3. Run the seed script:
```bash
node seedDatabase.js
```

This will populate your Supabase database with sample data for:
- Customers
- Rentals
- Events
- Transactions
- Notifications
- Products
- System status

## Application Structure

- `temphelo/app`: Main application screens and navigation
- `temphelo/components`: Reusable UI components
- `temphelo/services`: API service functions for interacting with Supabase
- `temphelo/types`: TypeScript type definitions
- `temphelo/lib`: Utility libraries including Supabase client
- `temphelo/scripts`: Utility scripts, including database seeding

## Features

- Dashboard with business overview and statistics
- Active rentals management
- Event scheduling
- Financial transaction tracking
- Notification center

## Troubleshooting

If you encounter any issues with the application connecting to Supabase:

1. Verify your Supabase configuration in `temphelo/lib/supabase.ts`
2. Check that your Supabase tables match the expected schema
3. Run the seed script to ensure basic data is available
4. Check console logs for specific error messages