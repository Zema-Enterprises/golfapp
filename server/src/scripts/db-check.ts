import { prisma } from '../config/database.js';

async function checkDatabaseConnection(): Promise<void> {
  console.log('Checking database connection...');

  try {
    const result = await prisma.$queryRaw<[{ now: Date }]>`SELECT NOW() as now`;
    console.log('✅ Database connection successful');
    console.log(`   Server time: ${result[0].now}`);

    // Check table existence
    const tables = await prisma.$queryRaw<{ tablename: string }[]>`
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = 'public'
    `;

    if (tables.length === 0) {
      console.log('⚠️  No tables found. Run migrations with: npm run db:migrate');
    } else {
      console.log(`   Tables found: ${tables.map((t: { tablename: string }) => t.tablename).join(', ')}`);
    }
  } catch (error) {
    console.error('❌ Database connection failed:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

checkDatabaseConnection();
