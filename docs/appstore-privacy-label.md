# App Store Privacy Nutrition Label

Reference for filling out the "App Privacy" section in App Store Connect.

## Data Collection Summary

| Category | Collected? | Details |
|----------|-----------|---------|
| Data Used to Track You | No | IDFA not collected |
| Data Linked to You | No | All data is anonymous |
| Data Not Linked to You | Yes | See below |

## Data Not Linked to You

### 1. Diagnostics

- **Crash Data**: Crash logs collected via Firebase Analytics
- **Performance Data**: App launch time, screen rendering metrics
- **Purpose**: App functionality improvement
- **Linked to identity**: No
- **Used for tracking**: No

### 2. Usage Data

- **Product Interaction**: Screen views, feature usage frequency (e.g., photos cleaned, sessions completed)
- **Purpose**: Analytics for app improvement
- **Linked to identity**: No
- **Used for tracking**: No

### 3. Other Data

- **Device Model**: e.g., iPhone 15 Pro
- **OS Version**: e.g., iOS 17.4
- **App Version**: e.g., 1.0.0
- **Purpose**: Analytics for app improvement
- **Linked to identity**: No
- **Used for tracking**: No

## Data NOT Collected

- Contact Info (name, email, phone)
- Location
- Photos or Videos (content)
- Identifiers (IDFA, user ID)
- Financial Info
- Health & Fitness
- Browsing History
- Search History
- Purchases

## App Store Connect Questionnaire Answers

1. **Do you or your third-party partners collect data from this app?** Yes
2. **Advertising Identifier (IDFA)?** No
3. **Data types collected:** Diagnostics, Usage Data, Other Data
4. **Is each data type linked to the user's identity?** No (all anonymous)
5. **Is each data type used for tracking?** No

## Third-Party SDKs

| SDK | Data Collected | Purpose |
|-----|---------------|---------|
| Firebase Analytics (Google) | Device info, usage patterns, crash data | Analytics |

## Notes

- Firebase Analytics uses an app instance ID (not linked to personal identity)
- No IDFA collection (ATT framework not integrated)
- No user accounts or login = no way to link data to identity
- All analytics data auto-expires after 14 months (Google default)
