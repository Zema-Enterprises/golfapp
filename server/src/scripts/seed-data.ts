import { prisma } from '../config/database.js';
import { AgeBand, ItemType, Rarity } from '@prisma/client';

export async function seedData(): Promise<void> {
  console.log('🌱 Seeding drills and avatar items...');

  const drills = [
    {
      title: 'Putt to a Cone',
      ageBand: AgeBand.AGE_4_6,
      skillCategory: 'putting',
      durationMinutes: 5,
      setup: 'Place a cone or target 3 feet away from the starting position.',
      childAction: 'Roll the ball to try and hit the cone!',
      parentCue: 'Encourage a smooth back-and-forth motion like a pendulum.',
      commonMistakes: 'Lifting head before contact, gripping too tight.',
      successCriteria: 'Ball stops within 1 foot of the target.',
    },
    {
      title: 'Happy Feet Balance',
      ageBand: AgeBand.AGE_4_6,
      skillCategory: 'balance',
      durationMinutes: 3,
      setup: 'Find a flat grassy area.',
      childAction: 'Stand on one foot like a flamingo for 10 seconds!',
      parentCue: 'Count together and cheer them on.',
      commonMistakes: 'Looking down instead of ahead.',
      successCriteria: 'Balance for 10 seconds without putting foot down.',
    },
    // AGE_4_6 — additional drills
    {
      title: 'Tee Target Toss',
      ageBand: AgeBand.AGE_4_6,
      skillCategory: 'accuracy',
      durationMinutes: 4,
      setup: 'Place 3 tees in a line, each 2 feet apart.',
      childAction: 'Try to roll the ball so it stops near each tee!',
      parentCue: 'Encourage gentle pushes, not big swings.',
      commonMistakes: 'Hitting too hard, ball rolls past all tees.',
      successCriteria: 'Ball stops within 6 inches of at least 1 tee.',
    },
    {
      title: 'Swing Like a Clock',
      ageBand: AgeBand.AGE_4_6,
      skillCategory: 'swing',
      durationMinutes: 5,
      setup: 'Open grassy area. Stand facing the child to demonstrate.',
      childAction: 'Swing the club back to 9 o\'clock and through to 3 o\'clock!',
      parentCue: 'Say "tick" on the backswing and "tock" on the follow-through.',
      commonMistakes: 'Swinging too far back, losing balance.',
      successCriteria: 'Complete 5 smooth tick-tock swings in a row.',
    },
    {
      title: 'Ball Roll Race',
      ageBand: AgeBand.AGE_4_6,
      skillCategory: 'putting',
      durationMinutes: 4,
      setup: 'Mark a start and finish line 5 feet apart on a flat surface.',
      childAction: 'Putt the ball from start to finish — try to stop it on the line!',
      parentCue: 'Focus on speed control, not power.',
      commonMistakes: 'Hitting too hard or too soft.',
      successCriteria: 'Ball stops within 1 foot of the finish line 3 out of 5 tries.',
    },

    // AGE_6_8 — existing + additional drills
    {
      title: 'Chip and Land',
      ageBand: AgeBand.AGE_6_8,
      skillCategory: 'chipping',
      durationMinutes: 7,
      setup: 'Set up a hula hoop or circle marker 10 yards away.',
      childAction: 'Chip the ball and try to land it inside the circle!',
      parentCue: 'Watch for a descending strike and follow through.',
      commonMistakes: 'Scooping the ball instead of hitting down.',
      successCriteria: 'Land 3 out of 5 balls in the target area.',
    },
    {
      title: 'Pitch to the Circle',
      ageBand: AgeBand.AGE_6_8,
      skillCategory: 'pitching',
      durationMinutes: 6,
      setup: 'Place a towel or circle 15 yards away as a target.',
      childAction: 'Hit a high pitch shot and land it on the towel!',
      parentCue: 'Encourage opening the clubface slightly for loft.',
      commonMistakes: 'Hitting with a closed face, low trajectory.',
      successCriteria: 'Land 2 out of 5 balls on or near the target.',
    },
    {
      title: 'Bunker Splash',
      ageBand: AgeBand.AGE_6_8,
      skillCategory: 'bunker',
      durationMinutes: 7,
      setup: 'Find a practice bunker. Draw a circle in the sand around the ball.',
      childAction: 'Splash the sand out of the circle — the ball rides the sand!',
      parentCue: 'Aim 2 inches behind the ball, hit the sand not the ball.',
      commonMistakes: 'Hitting the ball directly instead of the sand.',
      successCriteria: 'Get the ball out of the bunker 3 out of 5 tries.',
    },
    {
      title: 'Fairway Aim',
      ageBand: AgeBand.AGE_6_8,
      skillCategory: 'accuracy',
      durationMinutes: 6,
      setup: 'Set two cones 10 feet apart as a "fairway" 20 yards away.',
      childAction: 'Hit the ball so it goes between the cones!',
      parentCue: 'Focus on alignment — feet, hips, shoulders all pointing at target.',
      commonMistakes: 'Aiming body one way and swinging another.',
      successCriteria: 'Hit 3 out of 5 balls between the cones.',
    },
    {
      title: 'Putting Ladder',
      ageBand: AgeBand.AGE_6_8,
      skillCategory: 'putting',
      durationMinutes: 5,
      setup: 'Place tees at 3, 6, 9, and 12 feet from the starting spot.',
      childAction: 'Putt to the first tee, then the second, and keep going up the ladder!',
      parentCue: 'Celebrate each rung completed. Restart if they want.',
      commonMistakes: 'Rushing the stroke on longer distances.',
      successCriteria: 'Reach the 9-foot tee within 2 feet on 2 attempts.',
    },

    // AGE_8_10 — all new drills
    {
      title: 'Iron Accuracy',
      ageBand: AgeBand.AGE_8_10,
      skillCategory: 'iron_play',
      durationMinutes: 8,
      setup: 'Set up 3 targets at 30, 50, and 70 yards on a range.',
      childAction: 'Hit 5 balls to each target — score 1 point for each ball within 10 feet!',
      parentCue: 'Emphasize consistent contact over distance.',
      commonMistakes: 'Trying to swing too hard, losing balance.',
      successCriteria: 'Score at least 5 points out of 15.',
    },
    {
      title: 'Drive for Distance',
      ageBand: AgeBand.AGE_8_10,
      skillCategory: 'driving',
      durationMinutes: 8,
      setup: 'Tee up on a driving range. Place markers at 50-yard intervals.',
      childAction: 'Hit 10 drives and try to beat your personal best distance!',
      parentCue: 'Smooth tempo matters more than swinging hard.',
      commonMistakes: 'Over-swinging, topping the ball.',
      successCriteria: 'Hit 5 out of 10 drives past their average marker.',
    },
    {
      title: 'Short Game Challenge',
      ageBand: AgeBand.AGE_8_10,
      skillCategory: 'short_game',
      durationMinutes: 10,
      setup: 'Set up 3 stations: chip from 10 yards, pitch from 20 yards, putt from 15 feet.',
      childAction: 'Score at each station: 3 points for holing it, 2 for inside 3 feet, 1 for inside 6 feet!',
      parentCue: 'This builds competition skills. Keep it fun, track scores together.',
      commonMistakes: 'Getting frustrated instead of adjusting technique.',
      successCriteria: 'Score at least 12 points across all 3 stations (5 balls each).',
    },
    {
      title: 'Course Management',
      ageBand: AgeBand.AGE_8_10,
      skillCategory: 'strategy',
      durationMinutes: 7,
      setup: 'On a practice area, create an imaginary hole: tee, fairway, green.',
      childAction: 'Play the imaginary hole — pick the right club for each shot!',
      parentCue: 'Ask "What club would you use here?" before each shot.',
      commonMistakes: 'Always reaching for the driver instead of thinking strategically.',
      successCriteria: 'Complete the imaginary hole making smart club choices.',
    },
    {
      title: 'Putting Pressure',
      ageBand: AgeBand.AGE_8_10,
      skillCategory: 'putting',
      durationMinutes: 6,
      setup: 'Set up 5 putts in a circle around a hole, each 4 feet away.',
      childAction: 'Make all 5 putts in a row — if you miss, start over!',
      parentCue: 'Teach a pre-putt routine: read, aim, breathe, stroke.',
      commonMistakes: 'Rushing through putts without a routine.',
      successCriteria: 'Complete the circle once without missing.',
    },
  ];

  for (const drill of drills) {
    await prisma.drill.upsert({
      where: { id: drill.title.toLowerCase().replace(/\s+/g, '-') },
      update: drill,
      create: {
        id: drill.title.toLowerCase().replace(/\s+/g, '-'),
        ...drill,
      },
    });
  }
  console.log(`   ✅ ${drills.length} drills`);

  const avatarItems = [
    { type: ItemType.HAT, name: 'Golf Cap', unlockStars: 0, rarity: Rarity.COMMON },
    { type: ItemType.SHIRT, name: 'Green Polo', unlockStars: 0, rarity: Rarity.COMMON },
    { type: ItemType.SHOES, name: 'White Sneakers', unlockStars: 0, rarity: Rarity.COMMON },
    { type: ItemType.CLUB_SKIN, name: 'Classic Putter', unlockStars: 0, rarity: Rarity.COMMON },
    { type: ItemType.ACCESSORY, name: 'Golf Glove', unlockStars: 10, rarity: Rarity.COMMON },
    { type: ItemType.HAT, name: 'Bucket Hat', unlockStars: 15, rarity: Rarity.COMMON },
    { type: ItemType.SHIRT, name: 'Striped Polo', unlockStars: 20, rarity: Rarity.UNCOMMON },
    { type: ItemType.HAT, name: 'Sun Visor', unlockStars: 25, rarity: Rarity.UNCOMMON },
    { type: ItemType.SHOES, name: 'Golf Shoes', unlockStars: 25, rarity: Rarity.UNCOMMON },
    { type: ItemType.ACCESSORY, name: 'Cool Sunglasses', unlockStars: 35, rarity: Rarity.RARE },
    { type: ItemType.SHIRT, name: 'Pro Jersey', unlockStars: 40, rarity: Rarity.RARE },
    { type: ItemType.HAT, name: 'Champion Cap', unlockStars: 50, rarity: Rarity.RARE },
    { type: ItemType.CLUB_SKIN, name: 'Golden Putter', unlockStars: 100, rarity: Rarity.LEGENDARY },
  ];

  for (const item of avatarItems) {
    await prisma.avatarItem.upsert({
      where: { id: item.name.toLowerCase().replace(/\s+/g, '-') },
      update: item,
      create: {
        id: item.name.toLowerCase().replace(/\s+/g, '-'),
        imageUrl: `/assets/avatar/${item.type.toLowerCase()}/${item.name.toLowerCase().replace(/\s+/g, '-')}.png`,
        ...item,
      },
    });
  }
  console.log(`   ✅ ${avatarItems.length} avatar items`);
}
