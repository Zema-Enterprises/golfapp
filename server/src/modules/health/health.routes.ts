import { FastifyInstance, FastifyPluginAsync } from 'fastify';
import { prisma } from '../../config/database.js';

const healthRoutes: FastifyPluginAsync = async (app: FastifyInstance) => {
  // Basic health check
  app.get(
    '/',
    {
      schema: {
        tags: ['Health'],
        summary: 'Health check',
        description: 'Returns the health status of the API',
        response: {
          200: {
            type: 'object',
            properties: {
              status: { type: 'string', enum: ['ok', 'degraded', 'down'] },
              timestamp: { type: 'string', format: 'date-time' },
              uptime: { type: 'number' },
            },
          },
        },
      },
    },
    async () => {
      return {
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
      };
    }
  );

  // Detailed health check with database status
  app.get(
    '/ready',
    {
      schema: {
        tags: ['Health'],
        summary: 'Readiness check',
        description: 'Returns detailed health status including database connection',
        response: {
          200: {
            type: 'object',
            properties: {
              status: { type: 'string' },
              timestamp: { type: 'string' },
              checks: {
                type: 'object',
                properties: {
                  database: { type: 'string' },
                },
              },
            },
          },
        },
      },
    },
    async () => {
      let databaseStatus = 'ok';

      try {
        await prisma.$queryRaw`SELECT 1`;
      } catch {
        databaseStatus = 'down';
      }

      const overallStatus = databaseStatus === 'ok' ? 'ok' : 'degraded';

      return {
        status: overallStatus,
        timestamp: new Date().toISOString(),
        checks: {
          database: databaseStatus,
        },
      };
    }
  );
};

export { healthRoutes };
