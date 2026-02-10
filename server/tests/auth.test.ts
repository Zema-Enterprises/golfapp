import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { getTestApp, closeTestApp, createTestUser, authHeader } from './helpers.js';
import { FastifyInstance } from 'fastify';

describe('Auth Module', () => {
  let app: FastifyInstance;

  beforeAll(async () => {
    app = await getTestApp();
  });

  afterAll(async () => {
    await closeTestApp();
  });

  // ============================================
  // Registration Tests
  // ============================================

  describe('POST /api/v1/auth/register', () => {
    it('should register a new user successfully', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/register',
        payload: {
          email: 'newuser@example.com',
          password: 'SecurePass123',
        },
      });

      expect(response.statusCode).toBe(201);
      const body = JSON.parse(response.body);
      expect(body.success).toBe(true);
      expect(body.data.user.email).toBe('newuser@example.com');
      expect(body.data.tokens.accessToken).toBeDefined();
      expect(body.data.tokens.refreshToken).toBeDefined();
    });

    it('should reject duplicate email', async () => {
      // Register first user
      await app.inject({
        method: 'POST',
        url: '/api/v1/auth/register',
        payload: { email: 'duplicate@example.com', password: 'SecurePass123' },
      });

      // Try to register same email
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/register',
        payload: { email: 'duplicate@example.com', password: 'AnotherPass123' },
      });

      expect(response.statusCode).toBe(409);
      const body = JSON.parse(response.body);
      expect(body.success).toBe(false);
    });

    it('should reject weak password', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/register',
        payload: { email: 'weak@example.com', password: '123' },
      });

      expect(response.statusCode).toBe(400);
    });
  });

  // ============================================
  // Login Tests
  // ============================================

  describe('POST /api/v1/auth/login', () => {
    it('should login with valid credentials', async () => {
      // Create user first
      await createTestUser('login@example.com');

      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/login',
        payload: { email: 'login@example.com', password: 'TestPass123' },
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.success).toBe(true);
      expect(body.data.tokens.accessToken).toBeDefined();
    });

    it('should reject wrong password', async () => {
      await createTestUser('wrongpass@example.com');

      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/login',
        payload: { email: 'wrongpass@example.com', password: 'WrongPassword' },
      });

      expect(response.statusCode).toBe(401);
    });

    it('should reject non-existent user', async () => {
      const response = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/login',
        payload: { email: 'noexist@example.com', password: 'SomePass123' },
      });

      expect(response.statusCode).toBe(401);
    });
  });

  // ============================================
  // Protected Route Tests
  // ============================================

  describe('GET /api/v1/auth/me', () => {
    it('should return user with valid token', async () => {
      const testUser = await createTestUser('me@example.com');

      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/auth/me',
        headers: authHeader(testUser.accessToken),
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.success).toBe(true);
      expect(body.data.user.email).toBe('me@example.com');
    });

    it('should reject request without token', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/auth/me',
      });

      expect(response.statusCode).toBe(401);
    });

    it('should reject invalid token', async () => {
      const response = await app.inject({
        method: 'GET',
        url: '/api/v1/auth/me',
        headers: authHeader('invalid-token'),
      });

      expect(response.statusCode).toBe(401);
    });
  });
});
