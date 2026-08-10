# Volunteer Connect — Project Blueprint

## 1. Project Overview

Volunteer Connect is a Flutter mobile application designed to help people
discover volunteering opportunities that match their skills, interests,
location, availability, and preferred volunteering duration.

The application is designed as a polished two-week MVP.

The goal is NOT to build a complete NGO management ecosystem.

The goal is to provide a focused and useful volunteer experience centered
around personalized opportunity discovery.

---

## 2. Core Value Proposition

### "Find volunteering opportunities that fit YOU."

Instead of simply showing a large list of volunteer opportunities,
Volunteer Connect helps users discover opportunities that are relevant
to their individual profile.

Each opportunity receives a Match Percentage based on:

- Skills
- Interests
- Location
- Availability
- Preferred duration

Example:

94% Match

Beach Cleanup Drive

Karachi · Saturday · 9:00 AM
Environment · 4 hours

Why this matches:
- Your location matches
- Your environmental interest matches
- Your availability matches
- Your skills match

---

## 3. Target Users

### Primary User

Volunteer

The MVP is primarily focused on the volunteer experience.

### Organization

Organizations are represented as the providers of volunteering
opportunities.

A full organization management dashboard is NOT part of the two-week MVP.

---

# 4. MVP Features

## 4.1 Authentication

Implement:

- Sign up
- Login
- Logout
- Forgot password
- Authentication state persistence

Use Firebase Authentication.

---

## 4.2 Onboarding

New volunteers complete a short profile setup.

Collect:

### Basic Information
- Name
- City
- Short bio
- Optional profile image

### Skills
Examples:
- Graphic Design
- Programming
- Teaching
- Content Writing
- Social Media
- Event Management
- Photography
- Fundraising

### Interests / Causes
Examples:
- Education
- Environment
- Healthcare
- Children
- Elderly
- Community Development
- Disaster Relief
- Animals

### Availability
Examples:
- Weekdays
- Weekends
- Morning
- Afternoon
- Evening

### Preferred Duration
Examples:
- Under 2 hours
- 2–4 hours
- 4–6 hours
- 6+ hours

### Volunteering Type
- On-site
- Remote
- Either

---

# 5. Home Screen

The home screen should provide a personalized experience.

Display:

- Greeting
- Recommended opportunities
- Match percentages
- Upcoming application
- Basic volunteer impact statistics

Example:

Good morning, Usawir 👋

Recommended for You

94% Match
Beach Cleanup Drive

89% Match
Teaching Assistant

82% Match
Social Media Volunteer

The home screen should prioritize recommended opportunities rather than
simply showing random listings.

---

# 6. Explore Screen

Users can browse all available opportunities.

Implement:

### Search
Search by:
- Opportunity title
- Organization
- Cause
- Skill

### Filters
- Location
- Cause
- Date
- Skills
- Remote / On-site
- Duration

Filters should be simple and mobile-friendly.

---

# 7. Opportunity Details

Each opportunity should display:

- Opportunity title
- Organization name
- Organization information
- Description
- Cause
- Required skills
- Location
- Date
- Start time
- End time
- Duration
- Volunteers needed
- Current volunteer count
- Remote / On-site
- Match percentage
- Why the opportunity matches the user

Primary action:

Apply Now

---

# 8. Personalized Matching System

## IMPORTANT

The MVP will NOT use AI for matching.

Use a transparent rule-based matching algorithm.

Maximum score = 100 points.

### Scoring

Skills match:
30 points

Interests / causes match:
25 points

Location match:
20 points

Availability match:
15 points

Preferred duration match:
10 points

Total:
100 points

Convert the score into a percentage.

Example:

Volunteer:

- Graphic Design
- Environment
- Karachi
- Saturday
- 3–4 hours

Opportunity:

- Social Media Volunteer
- Environment
- Karachi
- Saturday
- 4 hours

Result:

94% Match

---

## Matching Architecture

The matching logic MUST be separate from UI code.

Do not calculate match scores directly inside widgets.

Create a reusable matching service/utility so that the algorithm can
be improved or replaced later without rewriting the UI.

---

# 9. Applications

Users can apply to opportunities.

Application statuses:

- Applied
- Under Review
- Accepted
- Rejected
- Completed

Users should be able to view their applications.

Example:

My Applications

Beach Cleanup
Green Pakistan
Accepted

Teaching Drive
Education Foundation
Under Review

Food Distribution
Helping Hands
Completed

---

# 10. Volunteer Passport

The Volunteer Passport is one of the signature features of the MVP.

It provides a summary of the user's volunteering history and impact.

Display:

- Total volunteer hours
- Completed activities
- Causes supported
- Organizations participated with
- Skills used
- Volunteer badges

Example:

VOLUNTEER PASSPORT

24
Volunteer Hours

6
Activities

3
Causes

2
Organizations

Badges:

- First Activity
- Community Helper
- Environment Hero

The passport should feel like a personal record of social impact.

---

# 11. Volunteer Impact

Show simple statistics such as:

- Total hours
- Activities completed
- Causes supported
- Organizations participated with

Do not build advanced analytics in the MVP.

The purpose is to make volunteering progress visible and meaningful.

---

# 12. Profile

Users can view and edit:

- Profile image
- Name
- Bio
- City
- Skills
- Interests
- Availability
- Preferred duration
- Volunteering type

---

# 13. Data Model

The initial Firestore structure should remain simple.

Recommended collections:

users
opportunities
applications

Optional later collections:

volunteer_hours
certificates
notifications

Do NOT create unnecessary collections during the MVP.

---

# 14. User Model

Conceptually:

User
- id
- name
- email
- profileImageUrl
- bio
- city
- skills
- interests
- availability
- preferredDuration
- volunteeringType
- totalHours
- completedActivities
- createdAt

---

# 15. Opportunity Model

Conceptually:

Opportunity
- id
- title
- organizationName
- organizationDescription
- description
- cause
- requiredSkills
- location
- date
- startTime
- endTime
- duration
- volunteeringType
- volunteersNeeded
- currentVolunteerCount
- createdAt

---

# 16. Application Model

Conceptually:

Application
- id
- volunteerId
- opportunityId
- status
- appliedAt
- updatedAt

---

# 17. Technology Stack

Frontend:

Flutter / Dart

State Management:

Riverpod

Navigation:

GoRouter

Backend:

Firebase

Authentication:

Firebase Authentication

Database:

Cloud Firestore

Design:

Material 3

---

# 18. Architecture

Use a simple feature-first architecture.

lib/

    app/
        app.dart
        router.dart
        theme.dart

    core/
        constants/
        services/
        utils/

    features/
        auth/
        onboarding/
        profile/
        opportunities/
        applications/
        passport/

    shared/
        widgets/

The architecture should be clean but NOT over-engineered.

---

# 19. Architecture Rules

1. Keep features isolated.
2. Keep business logic separate from UI.
3. Do not place Firebase queries directly inside widgets.
4. Use Riverpod for application state and dependency injection.
5. Use GoRouter for navigation.
6. Use repositories/services for data access.
7. Reuse widgets instead of duplicating UI.
8. Centralize theme values.
9. Avoid hardcoded colors throughout the application.
10. Avoid unnecessary abstractions.
11. Avoid unnecessary packages.
12. Use proper loading states.
13. Use proper error states.
14. Use proper empty states.
15. Validate user input.
16. Keep Firebase security rules restrictive.
17. Never expose private credentials or secrets.
18. Do not rewrite working code without a reason.

---

# 20. Design Direction

The app should feel:

- Modern
- Clean
- Friendly
- Trustworthy
- Professional
- Community-focused
- Slightly premium

Use:

- Material 3
- Rounded cards
- Clear typography
- Generous spacing
- Consistent iconography
- Subtle animations
- Accessible contrast
- Consistent spacing
- Clear visual hierarchy

Avoid:

- Excessive gradients
- Excessive animations
- Cluttered screens
- Tiny text
- Overly complicated navigation
- Generic template-like UI
- Excessive decoration

The UI should prioritize usability and clarity.

---

# 21. MVP Screens

The initial MVP should contain:

1. Splash
2. Onboarding
3. Login
4. Sign Up
5. Forgot Password
6. Profile Setup
7. Home
8. Explore
9. Opportunity Details
10. Apply / Application Status
11. Volunteer Passport
12. Profile
13. Edit Profile

---

# 22. Future Features

The following are NOT part of the two-week MVP.

Potential future features:

- Organization dashboard
- Organization verification
- Team volunteering
- Volunteer groups
- Real-time chat
- Push notification system
- Leaderboards
- Volunteer streaks
- Advanced badges
- Digital certificates
- Calendar integration
- Saved opportunities
- Reviews
- Skill endorsements
- Volunteer references
- University integration
- Internship opportunities
- Advanced analytics
- Advanced recommendation system
- AI-assisted recommendations
- GPS tracking
- Emergency volunteer coordination
- Government integrations
- Social feed

---

# 23. Two-Week Development Principle

The application must remain realistically achievable within two weeks.

Priorities:

1. Working functionality
2. Stable architecture
3. Clean UI
4. Core user experience
5. Personalized matching
6. Volunteer Passport
7. Testing
8. Polish

Do NOT sacrifice stability for additional features.

Do NOT add features simply because they are technically possible.

---

# 24. Project Safety Rules

Volunteer Connect is completely independent from GlowCare.

IMPORTANT:

- Never access GlowCare files.
- Never modify GlowCare files.
- Never copy GlowCare code.
- Never copy GlowCare Firebase configuration.
- Never reuse GlowCare Firebase credentials.
- Never reuse GlowCare's firebase_options.dart.
- Never reuse GlowCare's google-services.json.
- Never connect Volunteer Connect to the GlowCare Firebase project.
- Never modify files outside the volunteer_connect project.

All Volunteer Connect development must remain inside:

C:\Development\Projects\volunteer_connect

Volunteer Connect must eventually have its own:

- Git repository
- Firebase project
- Authentication configuration
- Firestore database
- Android application configuration
- iOS application configuration

---

# 25. Definition of Done

The MVP is considered complete when a user can:

1. Create an account.
2. Complete their volunteer profile.
3. Select skills and interests.
4. Set location and availability.
5. Browse volunteer opportunities.
6. Search and filter opportunities.
7. See personalized match percentages.
8. Open opportunity details.
9. Apply to an opportunity.
10. Track application status.
11. View their Volunteer Passport.
12. View their volunteer impact statistics.
13. Edit their profile.
14. Log out securely.

The application must run successfully on an Android emulator/device
and should be stable enough for a project demonstration.

---

# 26. Core Product Statement

Volunteer Connect is not simply a list of volunteering opportunities.

It is a personalized mobile volunteering companion.

The key experience is:

Volunteer Profile
        ↓
Skills + Interests + Location + Availability
        ↓
Matching Algorithm
        ↓
Personalized Opportunities
        ↓
Apply
        ↓
Participate
        ↓
Track Impact
        ↓
Volunteer Passport