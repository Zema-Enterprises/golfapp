# AI Development Agent Guidelines

## Project Overview
**Project:** Junior Golf Playbook
**** I want to build a mobile app for parents of junior golfers to run short, structured practice sessions with their kids and keep them motivated over time. The app guides parents through age-appropriate drills, verifies completion with a Parent PIN, and rewards kids with stars and avatar items so practice feels like a game instead of homework.

Project Name:
Junior Golf Playbook

Target Audience:
- Parents of kids ages 4–10 who are learning golf
- Coaches and academies who may recommend the app to parents
- Non-golfer parents who want “press play” structure without needing golf expertise

Core Features:
1. Parent & Child Profiles with Parent PIN
- Parent account with secure 4–6 digit PIN
- Multiple child profiles (name, age, skill level, avatar state)

2. Guided Practice Sessions (Kid Mode + Parent Mode)
- Auto-generated 10–20 minute sessions with 3–4 drills
- Kid Mode: large buttons, simple instructions, drill visuals
- Parent Mode: access to details, controls, settings

3. Age-Based Skill Pathways & Drill Library
- Drills grouped into three age bands: 4–6, 6–8, 8–10
- Each drill includes setup, kid action, parent cue, common mistakes, success criteria, and a visual

4. PIN-Verified Drill Completion & Honest Tracking
- Every drill completion gated by Parent PIN
- Session summary showing drills completed, stars earned, streak changes

5. Stars & Avatar Reward System
- Stars awarded per drill and per session, plus streak bonuses
- Unlockable hats, shirts, shoes, club skins, and mystery items
- Avatar equip screen so kids can customize their golfer

6. Progress & Streak Tracking
- Stars earned and available balance
- Sessions completed this week
- Daily/weekly streak indicator
- Simple “Suggested Focus” based on recent drill history (e.g., “Work on putting next”)

7. Settings & Help for Parents
- Edit child info (name, age, skill level)
- Change Parent PIN and manage account
- Help/FAQ explaining how to run sessions and use the app

Tech Stack (Recommended Defaults):
- Platforms: iOS & Android
- Mobile: React Native (TypeScript)
- Backend & Storage: Supabase or Firebase Auth (email/password), Drill content and versions, Child/session data, stars, streaks, avatar unlocks
- Analytics: Firebase Analytics or equivalent for tracking sessions, drill completion, reward usage

Design Preferences:
- Kid-friendly but parent-respectful: clean, playful, not cartoon chaos
- Bright, sporty color palette inspired by golf courses (greens, blues, warm accents)
- Clear separation between Parent Mode and Kid Mode
- Kid Mode: large tappable cards, minimal text, bold visuals, single primary action per screen
- Parent Mode: compact stats, lists, and controls without clutter
- Simple avatar with clear equipment slots (hat, shirt, shoes, club)
- Large, readable typography for both adults and kids (high contrast, accessible)
- Micro-animations for earning stars, unlocking items, and opening mystery rewards to reinforce the game loop without overwhelming the experience

## CodeGuide CLI Usage Instructions

This project is managed using CodeGuide CLI. The AI agent should follow these guidelines when working on this project.

### Essential Commands

#### Project Setup & Initialization
```bash
# Login to CodeGuide (first time setup)
codeguide login

# Start a new project (generates title, outline, docs, tasks)
codeguide start "project description prompt"

# Initialize current directory with CLI documentation
codeguide init
```

#### Task Management
```bash
# List all tasks
codeguide task list

# List tasks by status
codeguide task list --status pending
codeguide task list --status in_progress
codeguide task list --status completed

# Start working on a task
codeguide task start <task_id>

# Update task with AI results
codeguide task update <task_id> "completion summary or AI results"

# Update task status
codeguide task update <task_id> --status completed
```

#### Documentation Generation
```bash
# Generate documentation for current project
codeguide generate

# Generate documentation with custom prompt
codeguide generate --prompt "specific documentation request"

# Generate documentation for current codebase
codeguide generate --current-codebase
```

#### Project Analysis
```bash
# Analyze current project structure
codeguide analyze

# Check API health
codeguide health
```

### Workflow Guidelines

1. **Before Starting Work:**
   - Run `codeguide task list` to understand current tasks
   - Identify appropriate task to work on
   - Use `codeguide task update <task_id> --status in_progress` to begin work

2. **During Development:**
   - Follow the task requirements and scope
   - Update progress using `codeguide task update <task_id>` when significant milestones are reached
   - Generate documentation for new features using `codeguide generate`

3. **Completing Work:**
   - Update task with completion summary: `codeguide task update <task_id> "completed work summary"`
   - Mark task as completed: `codeguide task update <task_id> --status completed`
   - Generate any necessary documentation

### AI Agent Best Practices

- **Task Focus**: Work on one task at a time as indicated by the task management system
- **Documentation**: Always generate documentation for new features and significant changes
- **Communication**: Provide clear, concise updates when marking task progress
- **Quality**: Follow existing code patterns and conventions in the project
- **Testing**: Ensure all changes are properly tested before marking tasks complete

### Project Configuration
This project includes:
- `codeguide.json`: Project configuration with ID and metadata
- `documentation/`: Generated project documentation
- `AGENTS.md`: AI agent guidelines

### Getting Help
Use `codeguide --help` or `codeguide <command> --help` for detailed command information.

---
*Generated by CodeGuide CLI on 2025-12-12T11:55:16.412Z*
