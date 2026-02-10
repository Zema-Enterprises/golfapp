import { PrismaClient, AgeBand, ItemType, Rarity } from '@prisma/client';

const prisma = new PrismaClient();

async function seed(): Promise<void> {
  console.log('🌱 Seeding database...');

  // Create sample drills
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
  console.log(`   Created ${drills.length} drills`);

  // Create sample avatar items (costs aligned with wireframes)
  const avatarItems = [
    // Starter items (free)
    { type: ItemType.HAT, name: 'Golf Cap', unlockStars: 0, rarity: Rarity.COMMON },
    { type: ItemType.SHIRT, name: 'Green Polo', unlockStars: 0, rarity: Rarity.COMMON },
    { type: ItemType.SHOES, name: 'White Sneakers', unlockStars: 0, rarity: Rarity.COMMON },
    { type: ItemType.CLUB_SKIN, name: 'Classic Putter', unlockStars: 0, rarity: Rarity.COMMON },
    // Low tier (10-15 stars)
    { type: ItemType.ACCESSORY, name: 'Golf Glove', unlockStars: 10, rarity: Rarity.COMMON },
    { type: ItemType.HAT, name: 'Bucket Hat', unlockStars: 15, rarity: Rarity.COMMON },
    // Mid tier (20-25 stars)
    { type: ItemType.SHIRT, name: 'Striped Polo', unlockStars: 20, rarity: Rarity.UNCOMMON },
    { type: ItemType.HAT, name: 'Sun Visor', unlockStars: 25, rarity: Rarity.UNCOMMON },
    { type: ItemType.SHOES, name: 'Golf Shoes', unlockStars: 25, rarity: Rarity.UNCOMMON },
    // High tier (35-50 stars)
    { type: ItemType.ACCESSORY, name: 'Cool Sunglasses', unlockStars: 35, rarity: Rarity.RARE },
    { type: ItemType.SHIRT, name: 'Pro Jersey', unlockStars: 40, rarity: Rarity.RARE },
    { type: ItemType.HAT, name: 'Champion Cap', unlockStars: 50, rarity: Rarity.RARE },
    // Premium tier (100 stars)
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
  console.log(`   Created ${avatarItems.length} avatar items`);

  console.log('✅ Seeding complete');
}

seed()
  .catch((error) => {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
