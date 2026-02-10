import { prisma } from '../../config/database.js';
import {
  hashPassword,
  verifyPassword,
  generateAccessToken,
  generateRefreshToken,
  hashRefreshToken,
  getRefreshTokenExpiry,
  getAccessTokenExpirySeconds,
  TokenPayload,
} from './auth.utils.js';
import type {
  RegisterInput,
  LoginInput,
  ChangePasswordInput,
  UpdateProfileInput,
} from './auth.schema.js';
import type { AuthResponse, AuthUser, AuthTokens } from './auth.types.js';

// ============================================
// Auth Service
// ============================================

export class AuthService {
  /**
   * Register a new user
   */
  async register(input: RegisterInput): Promise<AuthResponse> {
    const { email, password } = input;

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    // Get default role (parent for GolfApp)
    let defaultRole = await prisma.role.findUnique({
      where: { name: 'parent' },
    });

    // Create role if it doesn't exist (first user setup)
    if (!defaultRole) {
      defaultRole = await prisma.role.create({
        data: {
          name: 'parent',
          description: 'Parent user with access to manage children',
        },
      });
    }

    // Hash password
    const passwordHash = await hashPassword(password);

    // Create user and parent profile in transaction
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        roleId: defaultRole.id,
        parent: {
          create: {
            settings: {},
          },
        },
      },
      include: {
        role: true,
        parent: true,
      },
    });

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      user: this.formatUser(user),
      tokens,
    };
  }

  /**
   * Login with email and password
   */
  async login(input: LoginInput): Promise<AuthResponse> {
    const { email, password } = input;

    // Find user with role
    const user = await prisma.user.findUnique({
      where: { email },
      include: {
        role: true,
        parent: true,
      },
    });

    if (!user) {
      throw new Error('Invalid email or password');
    }

    if (!user.isActive) {
      throw new Error('Account is deactivated');
    }

    // Verify password
    const isValid = await verifyPassword(password, user.passwordHash);
    if (!isValid) {
      throw new Error('Invalid email or password');
    }

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      user: this.formatUser(user),
      tokens,
    };
  }

  /**
   * Refresh access token
   */
  async refreshToken(refreshToken: string): Promise<AuthTokens> {
    // Hash the provided token to compare with stored hash
    const tokenHash = hashRefreshToken(refreshToken);

    // Find valid refresh token
    const storedToken = await prisma.refreshToken.findFirst({
      where: {
        token: tokenHash,
        revokedAt: null,
        expiresAt: { gt: new Date() },
      },
      include: {
        user: {
          include: {
            role: true,
          },
        },
      },
    });

    if (!storedToken) {
      throw new Error('Invalid or expired refresh token');
    }

    if (!storedToken.user.isActive) {
      throw new Error('Account is deactivated');
    }

    // Revoke old token
    await prisma.refreshToken.update({
      where: { id: storedToken.id },
      data: { revokedAt: new Date() },
    });

    // Generate new tokens
    return this.generateTokens(storedToken.user);
  }

  /**
   * Get current user by ID
   */
  async getCurrentUser(userId: string): Promise<AuthUser> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        role: true,
        parent: true,
      },
    });

    if (!user) {
      throw new Error('User not found');
    }

    return this.formatUser(user);
  }

  /**
   * Update user profile
   */
  async updateProfile(userId: string, input: UpdateProfileInput): Promise<AuthUser> {
    const user = await prisma.user.update({
      where: { id: userId },
      data: input,
      include: {
        role: true,
        parent: true,
      },
    });

    return this.formatUser(user);
  }

  /**
   * Change password
   */
  async changePassword(userId: string, input: ChangePasswordInput): Promise<void> {
    const { currentPassword, newPassword } = input;

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new Error('User not found');
    }

    // Verify current password
    const isValid = await verifyPassword(currentPassword, user.passwordHash);
    if (!isValid) {
      throw new Error('Current password is incorrect');
    }

    // Hash new password and update
    const passwordHash = await hashPassword(newPassword);
    await prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });

    // Revoke all refresh tokens (force re-login)
    await prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  /**
   * Logout (revoke refresh token)
   */
  async logout(refreshToken: string): Promise<void> {
    const tokenHash = hashRefreshToken(refreshToken);
    
    await prisma.refreshToken.updateMany({
      where: {
        token: tokenHash,
        revokedAt: null,
      },
      data: { revokedAt: new Date() },
    });
  }

  /**
   * Logout from all devices
   */
  async logoutAll(userId: string): Promise<void> {
    await prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  // ============================================
  // Private Helpers
  // ============================================

  private async generateTokens(
    user: { id: string; email: string; role: { id: string; name: string } }
  ): Promise<AuthTokens> {
    const payload: TokenPayload = {
      userId: user.id,
      email: user.email,
      roleId: user.role.id,
      roleName: user.role.name,
    };

    const accessToken = generateAccessToken(payload);
    const refreshToken = generateRefreshToken();

    // Store hashed refresh token
    await prisma.refreshToken.create({
      data: {
        token: hashRefreshToken(refreshToken),
        userId: user.id,
        expiresAt: getRefreshTokenExpiry(),
      },
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: getAccessTokenExpirySeconds(),
    };
  }

  private formatUser(user: {
    id: string;
    email: string;
    isActive: boolean;
    isVerified: boolean;
    role: { id: string; name: string };
    parent?: { id: string; pinHash: string | null } | null;
  }): AuthUser {
    return {
      id: user.id,
      email: user.email,
      isActive: user.isActive,
      isVerified: user.isVerified,
      role: {
        id: user.role.id,
        name: user.role.name,
      },
      parent: user.parent
        ? {
            id: user.parent.id,
            hasPin: !!user.parent.pinHash,
          }
        : null,
    };
  }
}

// Export singleton instance
export const authService = new AuthService();
