# Aider Context: Payments

Use this file as the first file you pass to aider for payment work.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## How To Use This File

1. Add only this file first when the payment task is vague.
2. Pick exactly one pack below, unless the task explicitly crosses LeagueApps
	membership freshness or person-profile surfaces.
3. Use the LeagueApps payment freshness pack when payment status depends on fresh
	registration data.
4. Keep billing workflow details here as file-routing hints, not durable product
	policy.

## Payment Screen UI

Use for the Payments screen layout, filters, status chips, card display,
person actions, and recent-payment badges.

```text
/add frontend/js/screens/payments.js frontend/js/components/billing-badge.js frontend/js/components/FilterBar.js frontend/js/components/PersonActions.js
```

## Payments API

Use for `/api/payments/*` response shape, payment member rows, next-due updates,
and payment history returned to the frontend.

```text
/add backend/src/controllers/PaymentsController.cpp backend/src/controllers/PaymentsController.h backend/src/models/PersonPayments.cpp backend/src/models/PersonPayments.h
```

## LeagueApps Payment Freshness

Use when the task involves LeagueApps payment status, registration freshness,
or LA-derived member/payment reconciliation.

```text
/add backend/src/controllers/PaymentsController.cpp backend/src/models/PersonPayments.cpp backend/src/services/LaProgramSync.cpp backend/src/services/LaProgramSync.h backend/src/core/Controller.cpp backend/src/core/Controller.h
```

## Payment Schema And Next Due

Use for payment transaction storage, monthly due-date rules, and migration-level
changes.

```text
/add backend/src/models/PersonPayments.cpp backend/src/models/PersonPayments.h database/migrations/078-la-transactions.sql database/migrations/117-next-due-at.sql
```