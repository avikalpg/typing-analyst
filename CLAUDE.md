# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Typing Analyst is a dual-platform application that tracks typing performance metrics (WPM, CPM, accuracy) across different environments:

1. **macOS Desktop App** (`/macos/`) - Swift/SwiftUI native application that captures keystrokes globally and displays real-time stats in the status bar
2. **Web Application** (`/web/`) - Next.js web app for user registration, authentication, and long-term statistics visualization

## Architecture

### macOS Application Structure
- **AppDelegate.swift** - Main app entry point, manages status bar item and global key monitoring
- **ViewModel.swift** - Core business logic for typing calculations and data management
- **Models/** - Data structures (Keystroke, TypingData, AppPreferences)
- **Utils/** - Helper classes (AuthManager, TypingDataSender, TypingCalculations)
- **Views/** - SwiftUI views (PopoverView for statistics display)

### Web Application Structure
- **Next.js 15** with App Router architecture
- **Database**: PostgreSQL with Supabase (schema in `db_setup.sql`)
- **API Routes**: `/src/app/api/` - Authentication and typing statistics endpoints
- **Frontend**: React components with Tailwind CSS styling
- **Charts**: Chart.js for data visualization

## Development Commands

### Web Application (in `/web/` directory)
```bash
npm run dev          # Start development server with Turbopack
npm run build        # Production build
npm run start        # Start production server
npm run lint         # Run ESLint
```

### macOS Application
- Use Xcode to build and run the macOS application
- Project file: `macos/Typing Analyst.xcodeproj`
- Requires macOS Ventura (13.0) or later
- Needs Input Monitoring and Accessibility permissions

## Key Technical Details

### Database Schema
- `typing_stats` table stores user typing data with JSONB fields for:
  - `per_second_data`: Granular keystroke data with timestamps
  - `chunk_stats`: Aggregated statistics (total keystrokes, words, accuracy, peak speed)
- Row Level Security (RLS) enabled for user data isolation

### macOS App Features
- Global keystroke monitoring using Carbon/Cocoa APIs
- Real-time typing metric calculations
- Status bar integration with popover for detailed stats
- Preferences system for customizable tracking settings
- Data synchronization with web backend (optional)

### Web App Features
- User authentication with Supabase Auth
- Statistical data visualization with Chart.js
- Responsive design with Tailwind CSS
- API endpoints for data ingestion from desktop apps

## Configuration Files
- **Web**: `tsconfig.json`, `tailwind.config.ts`, `next.config.ts`
- **Database**: `db_setup.sql` contains the complete schema
- **Environment**: Web app requires `.env.local` for Supabase configuration

## Testing
- macOS: Use Xcode's testing framework (test files in `Typing AnalystTests/`)
- Web: Standard Next.js testing setup (specific test commands not defined in package.json)

## Important Notes
- The macOS app is currently not notarized and requires manual security override
- Global keystroke monitoring requires explicit user permissions on macOS
- Web app uses Supabase for backend services (auth, database)
- Both applications can work independently, but web registration enables cross-device statistics