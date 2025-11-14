# Usta Takip – Offline Construction Finance Companion

Usta Takip is a Flutter-based mobile companion for **construction masters (ustas)** who manage teams, patrons, projects, wages, and field expenses without internet access. The app keeps every financial record (wage entries, expenses, patron balances) locally, lets masters archive finished work, recover deleted data from a trash bin, and export encrypted backups. Phase 3 will introduce multi-device sync, but today everything runs offline-first.

---

## Contents
1. [Introduction](#introduction)
2. [Architecture Overview](#architecture-overview)
3. [Technology Stack](#technology-stack)
4. [Folder Structure](#folder-structure)
5. [Data Models](#data-models)
6. [Use Cases](#use-cases)
7. [Repositories](#repositories)
8. [UI / Screen Overview](#ui--screen-overview)
9. [Dashboard Features](#dashboard-features)
10. [Soft Delete, Archive & Trash](#soft-delete-archive--trash)
11. [Backup System](#backup-system)
12. [Testing Infrastructure](#testing-infrastructure)
13. [Roadmap](#roadmap)
14. [AI-Friendly Reference](#ai-friendly-reference)

---

## Introduction
**Persona:** Construction master (usta) who hires workers, works for patrons, and pays wages daily on site.

**Goals:**
- Replace notebooks and calculators with an offline-first app.
- Track how much is owed to workers, spent on materials, and expected from patrons.
- Avoid losing data even without internet.
- Provide quick insights (dashboard), searchable records, and lifecycle management (archive/trash).

---

## Architecture Overview
The project follows Clean Architecture. UI never talks to Hive directly; everything flows through Cubits and repositories.

```
UI → Cubit/Bloc → UseCase → Repository → Hive (encrypted)
```

- **Bootstrap (`lib/src/bootstrap/`)** – initializes Hive, registers adapters, opens encrypted boxes, and wires repositories into `AppDependencies`.
- **Data Layer (`lib/src/data/`)** – Hive models/adapters, repository implementations, services (encryption helper, backup service).
- **Domain Layer (`lib/src/domain/`)** – Entities, repository interfaces, use cases (RecordWorkDay, ApproveWagePayment, etc.).
- **Presentation Layer (`lib/src/presentation/`)** – Feature folders with pages, Cubits, and widgets; 5-tab navigation.

---

## Technology Stack
| Component | Detail |
|-----------|--------|
| Framework | Flutter 3.x (Dart null-safety) |
| Storage | Hive + AES (`HiveAesCipher`) |
| Encryption key store | `flutter_secure_storage` |
| Architecture | Clean Architecture + DI via `AppDependencies` |
| State management | Bloc/Cubit |
| Dashboard charts | `fl_chart` |
| Backup/Restore | Local encrypted JSON/ZIP |
| Testing | `flutter_test`, widget & integration tests, performance bench |
| Packages (core) | `hive`, `hive_flutter`, `uuid`, `fl_chart`, `flutter_secure_storage` |

---

## Folder Structure
```
lib/
├── main.dart
└── src/
    ├── bootstrap/       # Hive init, encryption helper, dependency graph
    ├── data/            # Models, adapters, repositories, services
    ├── domain/          # Entities, use cases, repository interfaces
    └── presentation/    # Features, cubits, views, widgets
```

- `bootstrap/` – `bootstrap.dart`, `app_dependencies.dart`, `encryption_helper.dart`.
- `data/models/` – Hive objects (`*.dart` + manual adapters `*.g.dart`).
- `data/repositories/` – Hive implementations of domain repository contracts.
- `domain/usecases/` – `RecordWorkDay`, `ApproveWagePayment`, etc.
- `presentation/features/` – Each feature (dashboard, employees, patrons, projects, archive, settings, trash) contains its own views and cubits.

---

## Data Models
Every entity mixes in `TrackableEntity`, providing lifecycle flags and timestamps.

| Model | Key Fields | Notes |
|-------|------------|-------|
| `Employee` | `id`, `name`, `dailyWage`, `phone`, `projectId` | assigned project optional |
| `Patron` | `id`, `name`, `phone`, `description` | linked via `project.patronId` |
| `Project` | `id`, `name`, `patronId`, `totalBudget`, `defaultDailyWage`, `startDate`, `endDate?` | archived/completed states |
| `WageEntry` | `id`, `employeeId`, `projectId`, `date`, `amount`, `status (recorded|approved|paid)` |
| `Expense` | `id`, `projectId`, `description`, `amount`, `isPaid`, `category` |
| `TrackableEntity` | `isDeleted`, `isArchived`, `createdAt`, `updatedAt?`, `deletedAt?` |

- IDs are UUID strings (`uuid` package).
- Hive adapters (`*.g.dart`) are handwritten to include lifecycle fields.
- Intentionally no remote IDs—makes offline storage easier.

---

## Use Cases
| Use Case | Description |
|----------|-------------|
| **RecordWorkDay** | For each daily work entry, creates a `WageEntry(status='recorded')` and matching `Expense(category='yevmiye', isPaid=false)`. |
| **ApproveWagePayment** | Marks the wage entry as `paid` and toggles `Expense.isPaid=true`. |
| **ArchiveProject** | Sets `Project.isArchived=true`, hiding it from active lists. |
| **SoftDeleteEmployee** | Marks employee (and optionally related wages) as deleted while keeping history. |
| **RestoreFromTrash** | Restores any soft-deleted entity (project, employee, wage, expense). |
| **CRUD for Employees/Patrons/Projects** | UI forms call repository methods to add/update/soft-delete. |
| **Ledger summary** | Calculates pending vs paid wages, outstanding patron payments, and available income for dashboard cards. |

Ledger logic:
- `pendingWages` = sum of `WageEntry.amount` where `status != paid` and `!isDeleted`.
- `totalExpenses` = paid expenses + paid wages.
- `outstandingPatronPayments` = `totalIncome - totalExpenses` clipped at zero.

---

## Repositories
Domain layer defines interfaces; data layer provides Hive-backed implementations.

| Repository | Responsibilities |
|------------|------------------|
| `ProjectRepository` | CRUD, archive/restore, hard delete, search active vs archived. |
| `EmployeeRepository` | CRUD, soft delete, restore, include/exclude deleted lists. |
| `PatronRepository` | CRUD for employers; used to populate selectors and dashboards. |
| `WageRepository` | Manage wage entries, pending totals, soft/hard delete. |
| `ExpenseRepository` | Expense CRUD, mark-paid, link to projects. |
| `LedgerRepository` | Aggregates data for dashboard (income, expenses, pending, reminder data). |

All repositories accept Hive boxes in constructors; they convert Hive objects to immutable copies before returning to upper layers.

---

## UI / Screen Overview
Bottom navigation (Material 3) includes five tabs:

| Tab | File | Purpose |
|-----|------|---------|
| **Employees** | `lib/src/presentation/features/employees/view/employees_page.dart` | CRUD workers, search, soft delete. |
| **Patrons** | `.../patrons_page.dart` | Manage patrons, filter by active projects. |
| **Dashboard** | `.../dashboard_page.dart` | Metrics, charts, reminders, quick-add. |
| **Projects** | `.../projects_page.dart` | List with patron badges, archive toggle, new project dialog. |
| **Archive** | `.../archive_page.dart` | Browse archived projects and employees. |

Trash bin lives inside **Settings → Trash**.

---

## Dashboard Features
- **Metric cards** (GridView): Total Income, Total Expenses, Pending Wages, Active Projects.
- **Weekly Chart**: `fl_chart` line chart built from ledger summary.
- **Reminders**: Pending wages, outstanding patron balances, “add project” prompts.
- **Quick-add buttons**: “➕ Employee” and “➕ Project” open bottom-sheet forms.
- **Settings icon**: opens tabbed settings (backup, trash, about).

---

## Soft Delete, Archive & Trash
Lifecycle of any entity:

1. **Active** – default view.
2. **Archived** – still accessible but marked as complete (projects).
3. **Deleted (Trash)** – `isDeleted=true`, hidden from active screens.
4. **Restore** – resets `isDeleted`/`isArchived` as applicable.
5. **Hard Delete** – permanently removed via trash actions.

Trash UI is accessed under Settings → “Çöp Kutusu”.

---

## Backup System
- `LocalBackupService` serializes Projects, Employees, Patrons, WageEntries, Expenses into JSON, encrypts with AES (same key as Hive), and stores in app docs directory.
- Users trigger “Backup Now” or “Restore Latest” under Settings → Backup tab.
- Timestamps stored in `settings` box, displayed on dashboard and settings.

---

## Testing Infrastructure

| Test Type | Coverage |
|-----------|----------|
| Unit | Models (`models_test.dart`), repository CRUD (`repositories_test.dart`), archive/trash flows (`archive_test.dart`, `trash_restore_test.dart`), new `employees_crud_test.dart`, `patrons_crud_test.dart`, ledger summary test. |
| Widget | `dashboard_ui_test.dart` ensures cards/chart/reminders render. |
| Integration | `integration_test/workflow_test.dart` (record workday → pay → archive → restore). |
| Performance | `test/performance/wage_performance_test.dart` (500 wage entries). |

Commands:

```
flutter test
flutter test test/widget/dashboard_ui_test.dart
flutter drive --target=integration_test/workflow_test.dart
```

---

## Roadmap

| Phase | Status | Highlights |
|-------|--------|-----------|
| Phase 1 – MVP | ✅ | Hive storage, basic CRUD, wage ledger. |
| Phase 2 – Full Release | ✅ | Archive & trash system, dashboard metrics, backup. |
| Phase 2.5 – UI Revamp | ✅ | Five-tab nav, patron module, modern dashboard, fl_chart visuals. |
| Phase 3 – Premium Sync | 🟡 Planned | Firebase auth, cloud sync, push notifications, subscription (RevenueCat/Remote Config). |

---

## AI-Friendly Reference
This README doubles as an AI prompt:

- Codex/ChatGPT can read architecture sections to propose refactors.
- Use flow diagram and folder breakdown to locate files quickly.
- The testing section outlines how to validate new modules.
- Roadmap clarifies what’s next (Phase 3 features).
- When you ask an AI to “implement a new premium feature,” it should follow the clean architecture flow documented above.

Trigger example:

> “Analyze Usta Takip using the README architecture. Suggest performance optimizations before Phase 3.”

---

Ready to extend Usta Takip? Follow the layers, respect repositories, keep Hive encrypted, and ensure every UI change travels through its cubit/use-case pipeline.
