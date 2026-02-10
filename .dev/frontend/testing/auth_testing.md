# Auth Feature - Testing Scenarios

## Prerequisites
- Backend running: `docker compose up -d`
- Frontend running: `cd mobile && flutter run -d chrome --web-port=8103`

---

## Test Scenarios

### TS-01: Login Screen Loads
- **Action**: Navigate to `http://localhost:8103`
- **Expected**: Login screen displays with email/password fields and "Sign In" button
- **Status**: ✅ Passed

### TS-02: Login Validation - Empty Fields
- **Action**: Click "Sign In" with empty fields
- **Expected**: Validation errors appear for email and password
- **Status**: ✅ Passed

### TS-03: Login Validation - Invalid Email
- **Action**: Enter "invalid-email" in email field, click "Sign In"
- **Expected**: "Enter a valid email" error appears
- **Status**: ✅ Passed

### TS-04: Navigate to Register
- **Action**: Click "Sign Up" link at bottom of login screen
- **Expected**: Register screen displays
- **Status**: ✅ Passed

### TS-05: Register Screen Loads
- **Action**: Navigate to `/auth/register`
- **Expected**: Register screen displays with email, password, confirm password fields
- **Status**: ✅ Passed

### TS-06: Register Password Requirements
- **Action**: View register screen
- **Expected**: Password requirements list is visible (8 chars, uppercase, lowercase, number)
- **Status**: ✅ Passed

### TS-07: Register Validation - Password Mismatch
- **Action**: Enter different passwords in password and confirm fields
- **Expected**: "Passwords do not match" error appears
- **Status**: ✅ Passed

### TS-08: Register Validation - Weak Password
- **Action**: Enter "weak" as password
- **Expected**: "Password must be at least 8 characters" error appears
- **Status**: ✅ Passed

### TS-09: Navigate Back to Login
- **Action**: Click back arrow or "Sign In" link on register screen  
- **Expected**: Login screen displays
- **Status**: ✅ Passed

### TS-10: Successful Registration (requires backend)
- **Action**: Enter valid email/password and submit
- **Expected**: Redirects to home dashboard after success
- **Status**: ⏳ Pending (backend integration)

### TS-11: Successful Login (requires backend + existing user)
- **Action**: Enter valid credentials and submit
- **Expected**: Redirects to home dashboard after success
- **Status**: ⏳ Pending (backend integration)

### TS-12: Login Error Display
- **Action**: Enter invalid credentials
- **Expected**: Error message displays in red banner
- **Status**: ⏳ Pending (backend integration)

---

## Test Results

| Date | Tester | Passed | Failed | Notes |
|------|--------|--------|--------|-------|
| 2026-01-09 | Agent | 9 | 0 | UI validation tests complete; backend integration tests pending |
