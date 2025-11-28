# FoxScope Flutter Project

This document provides an overview of the FoxScope Flutter application structure, architecture, and development guidelines.

## 📌 Project Overview

FoxScope is a modular Flutter application built with clean architecture principles. The app uses GoRouter for navigation, GetIt for dependency injection, and maintains a consistent visual theme across all modules.

The project is structured to separate core functionality from feature-specific components, allowing for scalability and easy maintenance.

---

## 📁 Folder Structure

```
lib/
  main.dart
  app.dart

  core/
    constants/
      app_config.dart
      app_keys.dart
      app_router.dart

    di/
      service_locator.dart

    theme/
      app_colors.dart
      app_text_styles.dart
      app_theme.dart

    widgets/
      app_header.dart
      app_footer.dart
      app_loader.dart
      app_logo.dart
      rounded_button.dart
      ...

  features/
    home/
      presentation/
        pages/
        widgets/

    scope/
      presentation/
        pages/
          create_page.dart
          map_page.dart
          saved_page.dart
          scan_page.dart
          scope_page.dart
          send_page.dart
          status_page.dart

    settings/
      presentation/
        bloc/
          discover_bloc.dart
        pages/
          settings_page.dart
```

---

## 🧱 Architecture

The app follows a modular, feature-driven architecture:

### **Core Layer**

Contains shared logic:

* Theme & styles
* Reusable widgets
* App routing
* App configuration
* Dependency injection setup

### **Feature Layer**

Each feature is isolated under `features/` and contains:

* UI pages
* Widgets
* (Optional) BLoC or state management
* Domain logic

### **Routing**

Routing is done via **GoRouter**, configured in `core/constants/app_router.dart`.

### **Dependency Injection**

GetIt service locator is used to register and resolve dependencies across the project.

---

## 🎨 UI Components

All pages use:

* `AppHeader` → top navigation bar
* `AppFooter` → bottom action/navigation
* Shared colors & themes from `core/theme`

This ensures a consistent UI/UX.

---

## ⚙️ Build & Run

### Run the project:

```sh
deflutter pub get
flutter run
```

### Build release:

```sh
flutter build apk
flutter build ios
```

---

## 🚀 Planned Improvements

* Add detailed API layer documentation
* Add unit tests per feature module
* Improve page documentation (map, scan, scope)
* Add architecture diagram

---

## 👤 Author

Mahmoud Farag — Head of Implementation

Big Boss of FoxScope 🚀

---

If you need me to expand this README (badges, installation guide, architecture diagrams, environment setup, CI/CD), just tell me big boss.
