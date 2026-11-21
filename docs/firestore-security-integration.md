# Firestore security integration — ALB-001

**Status: NOT DEPLOYED.** This is a reviewable security fragment, not a complete production ruleset. Do not paste this as the entire Firebase rules file: the deployed rules for attendance, teachers, students and other collections must be preserved and audited.

## Required integration

Inside the deployed `rules_version = '2'; service cloud.firestore { match /databases/{database} { ... } }` block, add the helper functions and integrate the **users match** with the existing user rules. All other `allow update` clauses for `users/{uid}` must be audited: Firestore ORs permissions from matching allow statements, so one broad rule bypasses a restrictive one.

```javascript
function signedIn() {
  return request.auth != null;
}

function actorPath() {
  return /databases/$(database)/documents/users/$(request.auth.uid);
}

function actorExists() {
  return signedIn() && exists(actorPath());
}

function actor() {
  return get(actorPath()).data;
}

function activeActor() {
  return actorExists() && actor().is_active == true &&
      actor().is_verified == true;
}

function adminActor() {
  return activeActor() && actor().role == 'superAdmin';
}

function managerOf(schoolId) {
  return activeActor() && actor().role == 'manager' &&
      actor().school_id is string &&
      actor().school_id.size() > 0 &&
      actor().school_id == schoolId;
}

function validPermissions(value) {
  return value is list && value.size() <= 4 &&
      value.hasOnly(['manageMedia', 'manageTechnical',
                     'manageFinance', 'manageActivities']);
}

function canAssignTeacher() {
  return resource.data.role == 'teacher' &&
      (adminActor() || managerOf(resource.data.school_id)) &&
      request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['permissions']) &&
      validPermissions(request.resource.data.permissions);
}

function canEditOwnProfile(uid) {
  return signedIn() && request.auth.uid == uid &&
      activeActor() &&
      request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['full_name', 'phone']) &&
      request.resource.data.full_name is string &&
      request.resource.data.full_name.size() > 0 &&
      request.resource.data.full_name.size() <= 200 &&
      (request.resource.data.phone == null ||
          request.resource.data.phone is string);
}

// Integrate within the EXISTING match /users/{uid} block:
// allow update: if canAssignTeacher() || canEditOwnProfile(uid)
//     || <separately audited privileged admin operations>;
//
// Do not add an unconditional allow update for authenticated users.
// Do not allow clients to create privileged accounts or set is_verified=true.
// Do not allow clients to modify their own role, permissions, school_id,
// is_active or is_verified.
//
// Registration and verification flows must be reviewed before finalizing
// create/update rules. In particular, the current application uses a custom
// Firestore is_verified field rather than Firebase Auth emailVerified.
```

## Department data access

For each real collection storing media, technical, finance, or activities data, use a **separate** rule that checks an active, verified actor, their school scope, and the matching permission. A Flutter `hasPermission` check is not sufficient. Do not guess collection paths: identify the actual paths and ownership fields first.

## Required emulator cases

1. Teacher updates their own permissions -> DENY.
2. Teacher changes own role or activation -> DENY.
3. Parent changes own permissions or role -> DENY.
4. Manager in school A updates school A teacher's permissions only -> ALLOW.
5. Manager in school A updates school B teacher -> DENY.
6. Manager updates school A teacher's role/status via permission flow -> DENY.
7. Super admin updates a teacher's permissions only -> ALLOW.
8. Inactive manager grants permissions -> DENY.
9. Invalid permission keys or more than four entries -> DENY.
10. Profile owner edits allowed name/phone fields only -> ALLOW.
11. All existing attendance/student/teacher flows remain functional.
12. Verify account registration, OTP verification and Google profile completion against the final deployed rules.

## Deployment gate

Before deployment, obtain the **currently deployed complete Firestore rules**, merge these checks into the existing `users` match, audit all overlapping allow statements, and run the emulator tests. A rules fragment cannot guarantee security while broader rules remain active. Do not deploy or merge without this review.
