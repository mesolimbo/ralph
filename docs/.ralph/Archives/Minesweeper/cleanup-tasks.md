# Cleanup Tasks

## Minor Issues from QA Report

### 1. Fix Smiley Face on First Click - ✅ COMPLETED
**Owner:** software-developer
**Description:** Update smiley face to show ":-O" (surprised) during the very first click
**Priority:** Low
**Source:** BUG-003 from QA report
**Fix:** Updated condition to show surprised face for all non-won/lost states

### 2. Remove Redundant Code - ✅ COMPLETED
**Owner:** software-developer
**Description:** Simplify redundant ternary operator in mine counter code
**Priority:** Trivial
**Source:** BUG-004 from QA report
**Fix:** Removed redundant ternary, simplified to direct assignment

### 3. Remove Timer Display - ✅ COMPLETED
**Owner:** software-developer
**Description:** Remove the "000" timer placeholder since timer functionality is out of scope
**Priority:** Low
**Source:** BUG-001 from QA report - prevents user confusion
**Fix:** Removed timer HTML element and updated CSS selectors

## Notes
- BUG-002 (cannot flag before first click) is a valid design choice - no action needed
- BUG-005 (flag showing "X" only) is acceptable simplification - no action needed
