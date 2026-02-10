import { prisma } from '../config/database.js';
import type { AgeBand } from '@prisma/client';

interface DrillSeed {
  title: string;
  ageBand: AgeBand;
  skillCategory: string;
  durationMinutes: number;
  setup: string;
  childAction: string;
  parentCue: string;
  commonMistakes: string;
  successCriteria: string;
}

const DRILLS: DrillSeed[] = [
  // AGE_4_6 Drills
  {
    title: 'Putt to the Cup',
    ageBand: 'AGE_4_6',
    skillCategory: 'Putting',
    durationMinutes: 5,
    setup: 'Place ball 3 feet from cup on flat surface.',
    childAction: 'Roll the ball into the cup using putter.',
    parentCue: 'Say "Keep your eyes on the ball!"',
    commonMistakes: 'Lifting head too early, hitting too hard.',
    successCriteria: 'Make 3 out of 5 putts.',
  },
  {
    title: 'Chip and Chase',
    ageBand: 'AGE_4_6',
    skillCategory: 'Chipping',
    durationMinutes: 5,
    setup: 'Place ball on grass 10 feet from target.',
    childAction: 'Chip ball toward target, then chase and retrieve.',
    parentCue: 'Encourage them to "pop" the ball up gently.',
    commonMistakes: 'Scooping instead of hitting down.',
    successCriteria: 'Get 3 chips within 5 feet of target.',
  },
  {
    title: 'Golf Ball Bowling',
    ageBand: 'AGE_4_6',
    skillCategory: 'Coordination',
    durationMinutes: 5,
    setup: 'Set up plastic bottles as pins, ball 6 feet away.',
    childAction: 'Roll ball with putter to knock down pins.',
    parentCue: 'Count pins together, celebrate success!',
    commonMistakes: 'Hitting too soft, not aiming.',
    successCriteria: 'Knock down 3+ pins in one roll.',
  },
  // AGE_6_8 Drills
  {
    title: 'Ladder Putts',
    ageBand: 'AGE_6_8',
    skillCategory: 'Putting',
    durationMinutes: 5,
    setup: 'Place 5 balls at 2, 4, 6, 8, 10 feet from hole.',
    childAction: 'Putt each ball starting from closest.',
    parentCue: 'Watch their tempo - smooth stroke!',
    commonMistakes: 'Rushing, inconsistent stance.',
    successCriteria: 'Make 3 of 5 putts.',
  },
  {
    title: 'Target Practice',
    ageBand: 'AGE_6_8',
    skillCategory: 'Iron Play',
    durationMinutes: 10,
    setup: 'Place hula hoop 20 yards away as target.',
    childAction: 'Hit 5 balls trying to land in the hoop.',
    parentCue: 'Focus on smooth swing, not power.',
    commonMistakes: 'Swinging too hard, head movement.',
    successCriteria: 'Land 2 of 5 balls in or near hoop.',
  },
  {
    title: 'Bunker Splash',
    ageBand: 'AGE_6_8',
    skillCategory: 'Sand Play',
    durationMinutes: 5,
    setup: 'Place ball in sand bunker, rake smooth.',
    childAction: 'Splash the sand and ball out of bunker.',
    parentCue: 'Say "Hit the sand, not the ball!"',
    commonMistakes: 'Trying to pick ball clean.',
    successCriteria: 'Get ball out of bunker 3 of 5 times.',
  },
  // AGE_8_10 Drills
  {
    title: 'Clock Drill',
    ageBand: 'AGE_8_10',
    skillCategory: 'Putting',
    durationMinutes: 10,
    setup: 'Place 8 balls in circle 4 feet from hole.',
    childAction: 'Make all putts around the clock.',
    parentCue: 'Encourage consistent routine for each putt.',
    commonMistakes: 'Speeding up, breaking routine.',
    successCriteria: 'Make full circle without missing.',
  },
  {
    title: 'Driver Challenge',
    ageBand: 'AGE_8_10',
    skillCategory: 'Driving',
    durationMinutes: 10,
    setup: 'Tee up ball on driving range or open area.',
    childAction: 'Hit 5 drives focusing on tempo.',
    parentCue: 'Watch balance - finish facing target.',
    commonMistakes: 'Overswinging, loss of balance.',
    successCriteria: 'Hit 3 straight drives with good balance.',
  },
  {
    title: 'Up and Down',
    ageBand: 'AGE_8_10',
    skillCategory: 'Short Game',
    durationMinutes: 10,
    setup: 'Drop ball 15 yards from green, hole cut in middle.',
    childAction: 'Chip onto green and putt to hole.',
    parentCue: 'Read the green together before putting.',
    commonMistakes: 'Poor club selection, rushing putt.',
    successCriteria: 'Complete up-and-down 2 of 5 times.',
  },
];

export async function seedDrills(): Promise<void> {
  console.log('🌱 Seeding drills...');

  for (const drill of DRILLS) {
    await prisma.drill.upsert({
      where: {
        id: generateDrillId(drill.title, drill.ageBand),
      },
      update: drill,
      create: {
        id: generateDrillId(drill.title, drill.ageBand),
        ...drill,
      },
    });
  }

  console.log(`   ✅ Created/updated ${DRILLS.length} drills`);
  console.log('✅ Drill seeding complete!');
}

// Generate deterministic ID from title + ageBand
function generateDrillId(title: string, ageBand: string): string {
  const base = `${title}-${ageBand}`.toLowerCase().replace(/\s+/g, '-');
  // Create a UUID-like format from the base string
  const hash = Buffer.from(base).toString('base64').replace(/[^a-zA-Z0-9]/g, '').slice(0, 32);
  return `${hash.slice(0,8)}-${hash.slice(8,12)}-${hash.slice(12,16)}-${hash.slice(16,20)}-${hash.slice(20,32)}`.toLowerCase();
}

// Run if executed directly
const isMainModule = import.meta.url === `file://${process.argv[1]}`;
if (isMainModule) {
  seedDrills()
    .then(() => process.exit(0))
    .catch((e) => {
      console.error(e);
      process.exit(1);
    });
}
