
## 1. Architecture and Code Organization
- **Modular Structure**: Organize code in `lib/core/` (theme, constants), `lib/features/` (auth, transactions, bills, insights), and `lib/providers/` (state management).
- **Clean Architecture**: Separate data (API services), domain (models), and presentation (screens/widgets).
- **State Management**: Use `provider` for MVP, with `ChangeNotifierProvider` for global state (e.g., AuthProvider).
- **Dependency Injection**: Use `get_it` in `lib/core/di.dart` for services (e.g., AuthService).

## 2. UI/UX Design
- **Native Design**: Follow Material Design for Android, Cupertino for iOS.
- **Typography**: Use Inter for body text/labels (14–16sp), Poppins for headings/buttons (20–24sp), defined in `lib/core/theme/app_theme.dart`.
- **Responsive Design**: Use `flutter_screenutil` with design size 375x812 for all widgets.
- **Animations**: Add subtle animations (e.g., FadeTransition) for key actions like bill splitting.
- **Accessibility**: Include `semanticsLabel` for buttons/icons, ensure ≥4.5:1 contrast ratio.
- **Accessibility**: Use const keyword whenever possible 

## 3. Performance Optimization
- **Caching**: Cache API responses in `shared_preferences` or `sqflite` for transactions and bills.
- **Widget Rebuilds**: Use `const` constructors, `Consumer` for `provider` to limit rebuilds.
- **App Size**: Limit font weights (e.g., Inter Regular/Medium, Poppins Medium/SemiBold), use `--split-per-abi` for Android builds.

## 4. Security
- **API Security**: Use HTTPS for all Laravel API calls (e.g., `/api/login`).
- **Storage**: Store tokens in `flutter_secure_storage`.
- **Input Validation**: Validate all form inputs client-side and server-side (e.g., positive bill amounts).

## 5. Testing and Quality Assurance
- **Tests**: Write unit tests for services, widget tests for screens in `test/`.
- **Mocking**: Use `mockito` for API tests.
- **Beta Testing**: Test with 50–100 users via TestFlight/Google Play Beta, focusing on bill-splitting virality.

## 6. Backend Integration
- **API Contracts**: Define clear JSON structures for `/api/transactions`, `/api/bills`, `/api/insights`.
- **Error Handling**: Show user-friendly errors with `ScaffoldMessenger`.

## 7. Accessibility
- **Screen Readers**: Add `semanticsLabel` to all interactive elements.
- **Contrast**: Use high-contrast colors (e.g., dark text on white) in `app_theme.dart`.

## 8. CI/CD
- **Automation**: Use GitHub Actions for testing and building in `.github/workflows/ci.yml`.
- **Scripts**: Add build scripts in `scripts/` for manual tasks.

## Usage with AI Agent
- Reference this file in AI prompts: "Follow the best practices in github-instructions.md."
- Ensure generated code adheres to these standards, manually verifying architecture, typography, and security. -->



1. Architecture and Code Organization

Modular Structure: Organize code in lib/core/ (theme, constants), lib/features/ (auth, transactions, bills, insights), and lib/providers/ (state management).
Clean Architecture: Separate data (API services), domain (models), and presentation (screens/widgets).
State Management: Use provider for MVP, with ChangeNotifierProvider for global state (e.g., AuthProvider).
Dependency Injection: Use get_it in lib/core/di.dart for services (e.g., AuthService).

2. Data Models

Centralized Models Directory:
Location: Define all data models (e.g., User, Group, Bill, Transaction) in a centralized lib/models/ directory.
Rationale:
Simplifies management for the MVP, with a small set of models shared across features (e.g., User in auth, dashboard, profile; Group in bills, dashboard).
Ensures reusability and consistency by defining each model once, avoiding duplication.
Aligns with Flutter conventions for small-to-medium apps, reducing complexity for solo developers or small teams.


Implementation:
Use json_serializable for JSON serialization to integrate with Laravel APIs (e.g., /api/user, /api/bills).
Ensure models are immutable with const constructors and type-safe fields.
Document each model with its purpose (e.g., /// Represents a user in SavvySplit).
Example structure:lib/models/
├── user.dart
├── group.dart
├── bill.dart
├── transaction.dart


Run flutter pub run build_runner build --delete-conflicting-outputs to generate *.g.dart files for serialization.




Model Naming and Structure:
Naming: Use clear, domain-specific names (e.g., Bill instead of Item) to avoid conflicts and reflect the bill-splitting domain.
Fields: Include only necessary fields matching API responses and UI needs (e.g., User with id, name, email, profileImageUrl).
Serialization: Use @JsonSerializable() and define fromJson/toJson methods for API integration.


Future Scalability Plans:
When to Reassess: Transition to feature-specific models folders (e.g., features/auth/models/, features/bills/models/) if:
Model count exceeds 15, requiring finer organization.
New features (e.g., Chat, OCR, NLP) introduce many feature-specific models (e.g., ChatMessage, Goal).
Team grows beyond 3 developers, needing stricter modularity.


Transition Plan:
Move models to feature-specific folders (e.g., User to features/auth/models/user.dart, Bill to features/bills/models/bill.dart).
Update imports across providers and screens using an AI agent (e.g., GitHub Copilot, Cursor) to automate refactoring.
Retain shared models (e.g., User) in lib/models/ or create lib/models/shared/.
Example future structure:lib/
├── models/
│   ├── shared/
│   │   ├── user.dart
├── features/
│   ├── auth/
│   │   ├── models/
│   │   │   ├── auth_token.dart
│   ├── bills/
│   │   ├── models/
│   │   │   ├── group.dart
│   │   │   ├── bill.dart




Interim Scalability: For moderate growth (8–15 models), use subfolders in lib/models/ (e.g., models/auth/, models/bills/) to group related models.


Best Practices:
Type Safety: Use typed models instead of Map<String, dynamic> for compile-time safety.
Testing: Write unit tests for serialization (fromJson, toJson) and integration tests for providers (e.g., AuthProvider with User).
Consistency: Match model fields to API responses and UI requirements.
Accessibility: Provide semanticsLabel for model fields in UI (e.g., Bill.description).
Version Control: Commit model changes separately (e.g., “Add User model with json_serializable”).



3. UI/UX Design

Native Design: Follow Material Design for Android, Cupertino for iOS.
Typography: Use Inter for body text/labels (14–16sp), Poppins for headings/buttons (20–24sp), defined in lib/core/theme/app_theme.dart.
Responsive Design: Use flutter_screenutil with design size 375x812 for all widgets.
Animations: Add subtle animations (e.g., FadeTransition) for key actions like bill splitting.
Accessibility: Include semanticsLabel for buttons/icons, ensure ≥4.5:1 contrast ratio.

4. Performance Optimization

Caching: Cache API responses in shared_preferences or sqflite for transactions and bills.
Widget Rebuilds: Use const constructors, Consumer for provider to limit rebuilds.
App Size: Limit font weights (e.g., Inter Regular/Medium, Poppins Medium/SemiBold), use --split-per-abi for Android builds.

5. Security

API Security: Use HTTPS for all Laravel API calls (e.g., /api/login).
Storage: Store tokens in flutter_secure_storage.
Input Validation: Validate all form inputs client-side and server-side (e.g., positive bill amounts).

6. Testing and Quality Assurance

Tests: Write unit tests for services, widget tests for screens in test/.
Mocking: Use mockito for API tests.
Beta Testing: Test with 50–100 users via TestFlight/Google Play Beta, focusing on bill-splitting virality.

7. Backend Integration

API Contracts: Define clear JSON structures for /api/transactions, /api/bills, /api/insights.
Error Handling: Show user-friendly errors with ScaffoldMessenger.

8. Accessibility

Screen Readers: Add semanticsLabel to all interactive elements.
Contrast: Use high-contrast colors (e.g., dark text on white) in app_theme.dart.

9. CI/CD

Automation: Use GitHub Actions for testing and building in .github/workflows/ci.yml.
Scripts: Add build scripts in scripts/ for manual tasks.

Usage with AI Agent

Reference this file in AI prompts: "Follow the best practices in github-instructions.md."
Ensure generated code adheres to these standards, manually verifying architecture, typography, and security.

