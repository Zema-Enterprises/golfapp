import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { getTestApp, closeTestApp, createTestUser, authHeader } from './helpers.js';
import { FastifyInstance } from 'fastify';

describe('Settings Module', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = await getTestApp();
  });

  afterAll(async () => {
    await closeTestApp();
  });

  describe('GET /api/v1/settings', () => {
    it('should return default settings for new user', async () => {
      const testUser = await createTestUser('settings@example.com');

      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/settings',
        headers: authHeader(testUser.accessToken),
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.success).toBe(true);
      expect(body.data.settings.notificationsEnabled).toBe(true);
      expect(body.data.settings.theme).toBe('light');
      expect(body.data.settings.language).toBe('en');
    });
  });

  describe('PATCH /api/v1/settings', () => {
    it('should update settings', async () => {
      const testUser = await createTestUser('updatesettings@example.com');

      const response = await app.inject({
        method: 'PATCH',
        url: '/api/v1/settings',
        headers: authHeader(testUser.accessToken),
        payload: {
          theme: 'dark',
          notificationsEnabled: false,
        },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.data.settings.theme).toBe('dark');
      expect(body.data.settings.notificationsEnabled).toBe(false);
    });

    it('should reject invalid theme', async () => {
      const testUser = await createTestUser('invalidtheme@example.com');

      const response = await app.inject({
        method: 'PATCH',
        url: '/api/v1/settings',
        headers: authHeader(testUser.accessToken),
        payload: { theme: 'invalid-theme' },
      });

      expect(response.statusCode).toBe(400);
    });
  });
});
