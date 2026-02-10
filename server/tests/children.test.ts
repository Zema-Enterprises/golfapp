import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { getTestApp, closeTestApp, createTestUser, createTestChild, authHeader } from './helpers.js';
import { FastifyInstance } from 'fastify';

describe('Children Module', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = await getTestApp();
  });

  afterAll(async () => {
    await closeTestApp();
  });

  // ============================================
  // Create Child Tests
  // ============================================

  describe('POST /api/v1/children', () => {
    it('should create a child successfully', async () => {
      const testUser = await createTestUser('parent@example.com');

      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/children',
        headers: authHeader(testUser.accessToken),
        payload: { name: 'Emma', ageBand: 'AGE_4_6' },
      });

      expect(response.statusCode).toBe(201);
      const body = JSON.parse(response.body);
      expect(body.success).toBe(true);
      expect(body.data.child.name).toBe('Emma');
      expect(body.data.child.ageBand).toBe('AGE_4_6');
      expect(body.data.child.skillLevel).toBe('BEGINNER');
    });

    it('should reject without auth', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/children',
        payload: { name: 'Emma', ageBand: 'AGE_4_6' },
      });

      expect(response.statusCode).toBe(401);
    });

    it('should reject invalid ageBand', async () => {
      const testUser = await createTestUser('invalid@example.com');

      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/children',
        headers: authHeader(testUser.accessToken),
        payload: { name: 'Emma', ageBand: 'INVALID' },
      });

      expect(response.statusCode).toBe(400);
    });
  });

  // ============================================
  // List Children Tests
  // ============================================

  describe('GET /api/v1/children', () => {
    it('should list all children for parent', async () => {
      const testUser = await createTestUser('list@example.com');
      await createTestChild(testUser.parent.id, 'Child 1');
      await createTestChild(testUser.parent.id, 'Child 2');

      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/children',
        headers: authHeader(testUser.accessToken),
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.success).toBe(true);
      expect(body.data.children).toHaveLength(2);
    });

    it('should return empty array for new parent', async () => {
      const testUser = await createTestUser('nochildren@example.com');

      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/children',
        headers: authHeader(testUser.accessToken),
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.data.children).toHaveLength(0);
    });
  });

  // ============================================
  // Get Single Child Tests
  // ============================================

  describe('GET /api/v1/children/:id', () => {
    it('should get child by ID', async () => {
      const testUser = await createTestUser('getchild@example.com');
      const child = await createTestChild(testUser.parent.id, 'SingleChild');

      const response = await app.inject({
        method: 'GET',
        url: `/api/v1/children/${child.id}`,
        headers: authHeader(testUser.accessToken),
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.data.child.name).toBe('SingleChild');
    });

    it('should return 404 for non-existent child', async () => {
      const testUser = await createTestUser('notfound@example.com');

      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/children/00000000-0000-0000-0000-000000000000',
        headers: authHeader(testUser.accessToken),
      });

      expect(response.statusCode).toBe(404);
    });
  });

  // ============================================
  // Update Child Tests
  // ============================================

  describe('PATCH /api/v1/children/:id', () => {
    it('should update child name', async () => {
      const testUser = await createTestUser('update@example.com');
      const child = await createTestChild(testUser.parent.id, 'OldName');

      const response = await app.inject({
        method: 'PATCH',
        url: `/api/v1/children/${child.id}`,
        headers: authHeader(testUser.accessToken),
        payload: { name: 'NewName' },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.data.child.name).toBe('NewName');
    });
  });

  // ============================================
  // Delete Child Tests
  // ============================================

  describe('DELETE /api/v1/children/:id', () => {
    it('should delete child', async () => {
      const testUser = await createTestUser('delete@example.com');
      const child = await createTestChild(testUser.parent.id, 'ToDelete');

      const response = await app.inject({
        method: 'DELETE',
        url: `/api/v1/children/${child.id}`,
        headers: authHeader(testUser.accessToken),
      });

      expect(response.statusCode).toBe(204);
    });
  });
});
