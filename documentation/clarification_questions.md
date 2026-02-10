# Clarification Questions & Requests

> Questions and requests that need answers before/during development

---

## 🔴 High Priority

### Business & Product

1. **Drill Content Source** - ✅ ANSWERED: Using 9 seeded drills (3 per age band) for MVP. Will expand content library post-MVP.

2. **In-App Purchases** - 🔄 DEFERRED: Not in MVP scope. Will revisit for v1.1.

3. **MVP Drill Count** - ✅ ANSWERED: 9 drills (3 per age band: 4-6, 6-8, 8-10) is sufficient for MVP.

4. **Skill Progression** - ✅ ANSWERED: Parent-controlled. Parents can edit child's skill level in Settings.

### Technical

5. **Offline Duration** - ✅ ANSWERED: 7 days max offline before requiring sync. Server timestamp wins on conflicts.

6. **Multi-Device Conflict** - ✅ ANSWERED: Server timestamp wins (last write wins). Sessions sync when online.

7. **Session Persistence** - ✅ ANSWERED: Yes, sessions persist until completed or abandoned. IN_PROGRESS sessions can be resumed.

8. **Cheating Prevention** - ✅ ANSWERED: PIN-per-drill is sufficient for MVP. Trust parent to verify.

9. **Push Notifications** - 🔄 DEFERRED: Not in MVP scope. Will add in v1.1.

### Design Requests

10. **UI Mockups Needed** - ✅ ANSWERED: Wireframes provided in `Junior_Golf_Playbook_MVP_Wireframes.html`
    - Kid Mode drill screen ✅
    - Parent dashboard ✅
    - Avatar customization ✅
    - Session summary with rewards ✅

11. **Brand Assets** - ✅ ANSWERED: Colors from wireframes - Green (#2E7D32), Blue (#03A9F4), Orange (#FF9800)

12. **Animation Style** - 🔄 DEFERRED: Will use simple CSS animations for MVP. Polish in v1.1.

---

## 🟡 Medium Priority

### User Experience

13. **Session Customization** - ✅ ANSWERED: Parent selects duration (10/15/20 min). System selects appropriate drill count.

14. **Mid-Session Changes** - ✅ ANSWERED: No mid-session changes for MVP. Complete or abandon session.

15. **Profile Switching** - ✅ ANSWERED: Dashboard shows all children as cards. Tap to select child for session.

16. **Audio for Young Kids** - 🔄 DEFERRED: Not in MVP scope. Visual instructions only.

17. **Skip Drill Option** - 🔄 DEFERRED: Not in MVP. Child can ask parent to abandon session.

### Content & Rewards

18. **Unlock Mechanics** - ✅ ANSWERED: Spending-based. Stars are currency. Purchasing items deducts from available balance.

19. **Star Economy** - ✅ ANSWERED: Fixed 2 stars per drill. Stars add to both `totalStars` (lifetime) and `availableStars` (spendable).

20. **Streak Definition** - ✅ ANSWERED: Parent-configurable goal (Daily, 5x/week, 3x/week, 2x/week). Streak = weeks meeting goal.

21. **Achievements** - 🔄 DEFERRED: Stars and streaks only for MVP. Badges in v1.1.

22. **Difficulty Progression** - 🔄 DEFERRED: Not in MVP. Drills stay same difficulty within age band.

---

## 🟢 Low Priority

### Future Planning

23. **Coach Access** - 🔄 FUTURE: Not planned for MVP or v1.1.

24. **Multi-Language** - 🔄 FUTURE: English only for MVP.

25. **Custom Drills** - 🔄 FUTURE: Not in MVP scope.

---

**Document Details**
- **Project ID**: bc0ded31-54a9-4f61-91a5-233ceb4d22e3
- **Last Updated**: 2026-02-05
