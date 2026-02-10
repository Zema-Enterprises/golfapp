# App Flowchart

flowchart TD
    Start[Welcome Screen]
    Start --> SignUp[Tap Sign Up]
    Start --> SignIn[Tap Sign In]
    SignUp --> EnterCredentials[Enter Email Password]
    EnterCredentials --> CreatePIN[Create Parent PIN]
    CreatePIN --> AddChild[Add Child Profiles]
    SignIn --> Auth[Enter Email Password]
    Auth --> Dashboard[Main Dashboard Parent Mode]
    AddChild --> Onboarding[Onboarding Tutorial]
    Onboarding --> Dashboard
    Dashboard --> StartPractice[Tap Start Practice]
    StartPractice --> SessionGen[Generate Practice Session]
    SessionGen --> ParentReview[Review Drills Parent Mode]
    ParentReview --> KidModeSwitch[Switch to Kid Mode]
    KidModeSwitch --> Drill1[Display Drill]
    Drill1 --> CompleteDrill[Tap Drill Complete]
    CompleteDrill --> PINEntry[Enter Parent PIN]
    PINEntry --> AwardStar[Award Star and Next Drill]
    AwardStar --> NextDrill{More Drills Left}
    NextDrill -->|Yes| Drill1
    NextDrill -->|No| SessionSummary[Display Session Summary]
    SessionSummary --> UnlockAvatar[Unlock Avatar Items]
    UnlockAvatar --> AvatarScreen[Avatar Customization]
    AvatarScreen --> Dashboard

---
**Document Details**
- **Project ID**: bc0ded31-54a9-4f61-91a5-233ceb4d22e3
- **Document ID**: ccb911dc-62f8-4b9d-8e04-d6f297a6068d
- **Type**: custom
- **Custom Type**: app_flowchart
- **Status**: completed
- **Generated On**: 2025-12-12T00:20:10.013Z
- **Last Updated**: 2025-12-12T00:20:12.196Z
