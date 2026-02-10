import { buildApp } from './app.js';
import { env } from './config/env.js';
import { connectDatabase, disconnectDatabase } from './config/database.js';

async function main(): Promise<void> {
  const app = await buildApp();

  // Connect to database
  await connectDatabase();

  // Graceful shutdown
  const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM'];
  signals.forEach((signal) => {
    process.on(signal, async () => {
      console.log(`\n${signal} received, shutting down gracefully...`);
      await app.close();
      await disconnectDatabase();
      process.exit(0);
    });
  });

  // Start server
  try {
    await app.listen({ port: env.API_PORT, host: env.API_HOST });
    console.log(`🚀 Server running at http://${env.API_HOST}:${env.API_PORT}`);
    console.log(`📚 API docs at http://localhost:${env.API_PORT}/docs`);
  } catch (error) {
    app.log.error(error);
    await disconnectDatabase();
    process.exit(1);
  }
}

main();
