# Implementation Plan - New Wander Genie Screens

Integrate four new native Flutter screens based on the provided HTML designs: Destination Selection, Itinerary Loading, Travel Planner (Itinerary), and Expenses.

## User Review Required

> [!IMPORTANT]
> The designs use specific fonts (`Playfair Display` and `DM Sans`). I will check if these are already configured in the project or if I should use standard system fonts/Google Fonts package.
> I will use the `google_fonts` package if it's available or add it to `pubspec.yaml` to match the design perfectly.

## Proposed Changes

### Configuration

#### [MODIFY] [pubspec.yaml](file:///E:/ADL_PROJECT/travel_app/pubspec.yaml)
- Add `google_fonts` dependency for design-accurate typography.

#### [MODIFY] [app_constants.dart](file:///E:/ADL_PROJECT/travel_app/lib/app_constants.dart)
- Add new image URLs and design tokens (colors, text styles).

---

### Screens

#### [NEW] [plan_trip_destination_screen.dart](file:///E:/ADL_PROJECT/travel_app/lib/screens/plan_trip_destination_screen.dart)
- Implements Step 1: Destination input and Trending Inspirations.

#### [NEW] [generating_itinerary_screen.dart](file:///E:/ADL_PROJECT/travel_app/lib/screens/generating_itinerary_screen.dart)
- Implements the loading state with animated progress and rotating status messages.

#### [NEW] [wander_genie_travel_planner_screen.dart](file:///E:/ADL_PROJECT/travel_app/lib/screens/wander_genie_travel_planner_screen.dart)
- Implements the detailed itinerary view with timeline and activity cards.

#### [NEW] [expenses_screen.dart](file:///E:/ADL_PROJECT/travel_app/lib/screens/expenses_screen.dart)
- Implements the trip expenses dashboard with the budget ring and categories.

---

### Navigation & Integration

#### [MODIFY] [third_screen.dart](file:///E:/ADL_PROJECT/travel_app/lib/screens/third_screen.dart)
- Link "Plan" button to `PlanTripDestinationScreen`.
- Update Bottom Navigation to include `ExpensesScreen`.

#### [MODIFY] [main.dart](file:///E:/ADL_PROJECT/travel_app/lib/main.dart)
- Global theme updates to include the new font families.

## Verification Plan

### Automated Tests
- N/A for UI layout at this stage.

### Manual Verification
- Navigate through the full flow: Home -> Plan -> Destination -> Generating -> Itinerary.
- Check the Expenses screen from the bottom navigation.
- Verify responsive behavior (especially the itinerary list).
