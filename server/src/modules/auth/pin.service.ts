import { prisma } from '../../config/database.js';
import { hashPin, verifyPin } from './auth.utils.js';
import type { VerifyPinInput, ChangePinInput, PinInput } from './auth.schema.js';

// ============================================
// PIN Service (GolfApp Extension)
// ============================================

export class PinService {
  /**
   * Set initial PIN for a parent
   */
  async setPin(userId: string, input: PinInput): Promise<void> {
    const parent = await this.getParentByUserId(userId);

    if (parent.pinHash) {
      throw new Error('PIN already set. Use change-pin endpoint.');
    }

    const pinHash = await hashPin(input.pin);
    await prisma.parent.update({
      where: { id: parent.id },
      data: { pinHash },
    });
  }

  /**
   * Verify parent PIN
   */
  async verifyPin(userId: string, input: VerifyPinInput): Promise<boolean> {
    const parent = await this.getParentByUserId(userId);

    if (!parent.pinHash) {
      throw new Error('PIN not set. Please set a PIN first.');
    }

    const isValid = await verifyPin(input.pin, parent.pinHash);
    if (!isValid) {
      throw new Error('Invalid PIN');
    }

    return true;
  }

  /**
   * Change existing PIN
   */
  async changePin(userId: string, input: ChangePinInput): Promise<void> {
    const parent = await this.getParentByUserId(userId);

    if (!parent.pinHash) {
      throw new Error('PIN not set. Use set-pin endpoint.');
    }

    // Verify current PIN
    const isValid = await verifyPin(input.currentPin, parent.pinHash);
    if (!isValid) {
      throw new Error('Current PIN is incorrect');
    }

    // Hash and save new PIN
    const newPinHash = await hashPin(input.newPin);
    await prisma.parent.update({
      where: { id: parent.id },
      data: { pinHash: newPinHash },
    });
  }

  /**
   * Check if parent has PIN set
   */
  async hasPin(userId: string): Promise<boolean> {
    const parent = await this.getParentByUserId(userId);
    return !!parent.pinHash;
  }

  // ============================================
  // Private Helpers
  // ============================================

  private async getParentByUserId(userId: string) {
    const parent = await prisma.parent.findUnique({
      where: { userId },
    });

    if (!parent) {
      throw new Error('Parent profile not found');
    }

    return parent;
  }
}

// Export singleton instance
export const pinService = new PinService();
