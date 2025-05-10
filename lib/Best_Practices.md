# Best Practices for SavvySplit Development

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
- Reference this file in AI prompts: "Follow the best practices in BEST_PRACTICES.md."
- Ensure generated code adheres to these standards, manually verifying architecture, typography, and security.