# Teacher internal department permissions — implementation notes

## What is implemented

- Four optional duties: `manageMedia`, `manageTechnical`,
  `manageFinance`, `manageActivities`.
- New accounts default to `permissions: []`. The normal `teacher` role
  remains unchanged.
- Firestore stores `users/{uid}.permissions` as an array of strings;
  SQLite stores JSON text, migrated from schema v6 to v7 with `[]`.
- The manager can open an assignment dialog from a teacher's details. The
  super admin can use the action from Users Management.
- Saving requires a network connection, reads the acting and target users
  within a Firestore transaction, checks role/school, and updates only
  `permissions`.
- A live user document listener updates the signed-in user's cached
  permissions. Revoked permissions hide their navigation entry; the
  department placeholder also checks permission during rendering.
- Internal department *business features are not implemented yet*; their
  pages are explicitly marked as under development.

## Critical security deployment prerequisite

**No checked-in Firestore Security Rules file exists in this repository.**
The client transaction's role/school checks and hidden navigation are NOT a
security boundary. BEFORE production use, an administrator must **review and
merge** equivalent restrictions into the project's *currently deployed*
Firestore rules, test with the Firestore emulator, and deploy the updated
rules. Do not simply replace the existing complete ruleset with this fragment:
doing so can deny access to existing attendance/student/teacher workflows.

The following is a suggested `/users/{uid}` UPDATE branch. It must be
integrated with and audited alongside other existing `allow update`
conditions. Multiple `allow` rules are OR-ed, so a broad existing rule
can bypass this check.

```js
function isSignedIn() {
  return request.auth != null;
}
function callerExists() {
  return isSignedIn() &&
      exists(/databases/$(database)/documents/users/$(request.auth.uid));
}
function caller() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
}
function isActiveStaff() {
  return callerExists() && caller().is_active == true;
}
function mayAssignTeacher(target) {
  return isActiveStaff() &&
    (caller().role == 'superAdmin' ||
      (caller().role == 'manager' &&
       caller().school_id is string &&
       caller().school_id.size() > 0 &&
       caller().school_id == target.school_id));
}
function permissionValuesValid() {
  return request.resource.data.permissions is list &&
    request.resource.data.permissions.size() <= 4 &&
    request.resource.data.permissions.hasOnly([
      'manageMedia', 'manageTechnical', 'manageFinance', 'manageActivities'
    ]);
}

// Inside: match /users/{uid} { ... }
allow update: if
  resource.data.role == 'teacher' &&
  mayAssignTeacher(resource.data) &&
  request.resource.data.diff(resource.data)
    .affectedKeys().hasOnly(['permissions']) &&
  permissionValuesValid();
```

Also verify the other existing user-document write paths. In particular:

1. Account creation must assign no permissions; no self-registered user
   may select `manager` or `superAdmin`.
2. Profile updates by the user must not modify `permissions`, `is_active`,
   `is_verified`, `school_id`, or privileged `role` fields.
3. Changing roles, activating users, and deleting users must have their own
   server-side authorization checks, preserving current admin workflows.
4. Reading financial/media/activities data requires **resource-specific**
   rules, not only `hasPermission()` in Flutter. Check school scope for
   every document access and use a server-verified actor identity.
5. When a teacher loses permission while offline, cached local data may
   remain visible. Do not cache sensitive finance information without a
   separate protection policy.

## Manual verification scenarios

1. Register a teacher; `permissions` must be empty, with role still
   `teacher` and attendance features preserved.
2. As manager for school A, grant media and activities to a school-A
   teacher. Confirm Firestore array and SQLite JSON representation.
3. As manager for school A, attempt to edit a school-B teacher; reject.
4. As parent or teacher, attempt to update the `permissions` field directly
   via Firebase SDK or emulator; Firestore rules must reject it.
5. As super admin, grant and remove finance; teacher UI should reflect a
   live permission change without changing `UserRole`.
6. Offline: opening a previously cached account succeeds per existing
   offline policy, but changing assignments requires online access.
7. Edit a teacher's personal info after assigning duties; permissions must
   remain unchanged.
8. Verify old users without `permissions` deserialize to `[]` locally
   and remotely.

## Test commands

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

No Flutter/Dart SDK was available to execute these commands in the
editing environment. Run them in CI or on a developer machine before merge.
