# ParentHero — Full Architecture & Implementation Plan

## Overview
ParentHero is an AI-powered learning companion for kids (Grades 1-5). Parents subscribe, pin a curriculum topic, and get 5 days of structured content: teaching scripts, practice, quizzes, games, and certificates.

## Tech Stack
- **Frontend**: Flutter (Android + iOS + Web)
- **Backend**: Firebase (Firestore, Auth, Cloud Functions, Storage, Hosting)
- **Payments**: Razorpay (India) + Stripe (International)
- **State Management**: Riverpod
- **Analytics**: Firebase Analytics + Mixpanel
- **Design System**: Custom Material 3 theme (kid-friendly, colorful)

## Project Structure
```
parenthero/
├── lib/
│   ├── main.dart                     # App entry
│   ├── app.dart                      # MaterialApp, routing, theme
│   ├── core/
│   │   ├── theme/                    # Colors, typography, spacing, shapes
│   │   ├── constants/                # API keys, config, enums
│   │   ├── utils/                    # Helpers, date formatting, validators
│   │   ├── widgets/                  # Shared widgets (avatar, button, card, progress)
│   │   └── network/                  # API client, interceptors
│   ├── features/
│   │   ├── auth/                     # Sign up, login, forgot password, onboarding
│   │   │   ├── screens/              
│   │   │   ├── widgets/              
│   │   │   ├── providers/           
│   │   │   └── models/              
│   │   ├── dashboard/                # Home screen, child profiles, progress rings
│   │   ├── campaign/                 # Topic view, 5-day progression, day view
│   │   ├── teaching/                 # Teaching script slides/tabs
│   │   ├── practice/                 # Practice pad, interactive worksheet
│   │   ├── quiz/                     # MCQ quiz, difficulty levels, review
│   │   ├── beat_parent/              # Turn-based parent vs child game
│   │   ├── daily_spark/              # Daily nugget/surprise
│   │   ├── certificate/              # Certificate generation, sharing
│   │   ├── arcade/                   # Mini-games (Number Rush, Sort It!, Word Builder)
│   │   ├── parent_dashboard/         # Analytics, time tracking, performance
│   │   ├── settings/                 # Profile, subscription, notification prefs
│   │   ├── subscription/             # Plans, pricing, paywall, payment
│   │   └── search/                   # Topic library, search, filter
│   ├── providers/                    # Global providers (auth, subscription, child)
│   └── firebase/                     # Firebase initialization, analytics service
├── functions/                        # Firebase Cloud Functions
│   ├── src/
│   │   ├── payments/                 # Razorpay + Stripe webhooks
│   │   ├── certificates/             # PDF generation
│   │   ├── analytics/                # Event processing
│   │   └── content/                  # Content generation triggers
│   └── package.json
├── firebase.json                     # Firebase config
├── firestore.rules                   # Firestore security rules
└── firestore.indexes.json            # Composite indexes
```

## Firestore Schema

### users/{userId}
```
{ name, email, phone, createdAt, subscriptionTier, subscriptionEnd,
  authProvider, preferences{notifications, theme} }
```

### children/{childId}
```
{ parentId, name, age, grade, board, avatarIndex, createdAt,
  currentCampaignId, stats{streak, totalTopics, totalQuizzes, accuracy} }
```

### topics/{topicId}
```
{ grade, subject, board, quarter, title, description, 
  prerequisites[], difficulty, order, type, subTopics[],
  estimatedDays, tags[] }
```

### campaigns/{childId}_{topicId}
```
{ childId, topicId, startedAt, completedAt, status,
  days: {1:{completed,scriptWatched,quizScore}, 2:{...}, 3:{...}, 4:{...}, 5:{...}},
  certificatesGenerated[] }
```

### content/{topicId}_{day}_{type}
```
{ topicId, day, type(script|practice|quiz|beat_parent|spark),
  data: { ... structured content per type },
  generatedAt, version }
```

### certificates/{certId}
```
{ childId, topicId, completedAt, score, accuracy, timeSpent,
  pdfUrl, shared }
```

## Content Generation Pipeline
- 173 topics across Grades 1-5 (Math, Science/EVS, English)
- ~24,350 total content items (teaching scripts, practice questions, quiz items)
- AI-generated via Cloud Function trigger on topic pin
- Generated content cached in Firestore

## Key Screens & User Flows

### Onboarding Flow
Splash → Sign Up (email/Google/Apple) → Add Child (name, age, grade, board, avatar) → Plan Selection → Dashboard

### Weekly Learning Flow
Dashboard (see child's campaign) → Pin Topic → Day 1: Watch Teaching Script → Practice Pad → Quiz → Repeat Days 2-5 → Certificate (completion celebration) → Pin Next Topic

### Parent Dashboard
Child profiles → Progress overview → Time spent → Topic completion → Accuracy trends → Subscription management

## Payment Integration
- Monthly subscription (₹499/$9.99)
- Annual subscription (₹4,999/$99.99)  
- Family plan (up to 3 children)
- Razorpay for India (UPI, cards, netbanking)
- Stripe for international (cards, Apple Pay, Google Pay)
- 7-day free trial on all plans
