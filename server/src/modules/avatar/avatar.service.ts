import { prisma } from '../../config/database.js';
import type { ItemType, Rarity } from '@prisma/client';

// ============================================
// Avatar Service
// ============================================

export interface AvatarItemResponse {
  id: string;
  name: string;
  type: ItemType;
  imageUrl: string;
  unlockStars: number;
  isPremium: boolean;
  rarity: Rarity;
}

export interface ChildAvatarResponse {
  childId: string;
  equippedItems: AvatarItemResponse[];
  ownedItems: AvatarItemResponse[];
  avatarState: Record<string, unknown>;
}

export class AvatarService {
  /**
   * Get all avatar items (shop)
   */
  async getShop(type?: string): Promise<AvatarItemResponse[]> {
    const where = type ? { type: type as ItemType } : {};

    const items = await prisma.avatarItem.findMany({
      where,
      orderBy: [{ type: 'asc' }, { unlockStars: 'asc' }],
    });

    return items.map((item) => this.formatItem(item));
  }

  /**
   * Get child's avatar info
   */
  async getChildAvatar(parentId: string, childId: string): Promise<ChildAvatarResponse | null> {
    const child = await prisma.child.findFirst({
      where: { id: childId, parentId },
      include: {
        unlockedItems: {
          include: { item: true },
        },
      },
    });

    if (!child) return null;

    const avatarState = (child.avatarState as Record<string, unknown>) || {};
    const equippedItemIds = child.unlockedItems
      .filter((ui) => ui.equipped)
      .map((ui) => ui.itemId);

    const equippedItems = child.unlockedItems
      .filter((ui) => equippedItemIds.includes(ui.itemId))
      .map((ui) => this.formatItem(ui.item));

    return {
      childId: child.id,
      equippedItems,
      ownedItems: child.unlockedItems.map((ui) => this.formatItem(ui.item)),
      avatarState,
    };
  }

  /**
   * Purchase/unlock an avatar item
   */
  async purchaseItem(parentId: string, childId: string, itemId: string): Promise<void> {
    const child = await prisma.child.findFirst({
      where: { id: childId, parentId },
    });

    if (!child) throw new Error('Child not found');

    const item = await prisma.avatarItem.findUnique({
      where: { id: itemId },
    });

    if (!item) throw new Error('Item not found');

    // Check if already owned
    const owned = await prisma.childAvatarItem.findFirst({
      where: { childId, itemId },
    });

    if (owned) throw new Error('Item already owned');

    // Check available stars (spending balance)
    if (child.availableStars < item.unlockStars) {
      throw new Error('Not enough stars');
    }

    // Deduct from availableStars only (totalStars is lifetime earned, never decreases)
    await prisma.$transaction([
      prisma.child.update({
        where: { id: childId },
        data: { availableStars: { decrement: item.unlockStars } },
      }),
      prisma.childAvatarItem.create({
        data: { childId, itemId },
      }),
    ]);
  }

  /**
   * Equip an avatar item
   */
  async equipItem(parentId: string, childId: string, itemId: string): Promise<Record<string, unknown>> {
    const child = await prisma.child.findFirst({
      where: { id: childId, parentId },
      include: {
        unlockedItems: { include: { item: true } },
      },
    });

    if (!child) throw new Error('Child not found');

    // Check if owned
    const owned = child.unlockedItems.find((ui) => ui.itemId === itemId);
    if (!owned) throw new Error('Item not owned');

    const itemType = owned.item.type;

    // Unequip any current item of same type
    await prisma.childAvatarItem.updateMany({
      where: {
        childId,
        item: { type: itemType },
        equipped: true,
      },
      data: { equipped: false },
    });

    // Equip the new item
    await prisma.childAvatarItem.update({
      where: { id: owned.id },
      data: { equipped: true },
    });

    // Update avatarState
    const avatarState = (child.avatarState as Record<string, string>) || {};
    avatarState[itemType] = itemId;

    await prisma.child.update({
      where: { id: childId },
      data: { avatarState },
    });

    return avatarState;
  }

  /**
   * Unequip item by type
   */
  async unequipItem(parentId: string, childId: string, itemType: string): Promise<Record<string, unknown>> {
    const child = await prisma.child.findFirst({
      where: { id: childId, parentId },
    });

    if (!child) throw new Error('Child not found');

    // Unequip all items of this type
    await prisma.childAvatarItem.updateMany({
      where: {
        childId,
        item: { type: itemType as ItemType },
        equipped: true,
      },
      data: { equipped: false },
    });

    // Update avatarState
    const avatarState = (child.avatarState as Record<string, string>) || {};
    delete avatarState[itemType];

    await prisma.child.update({
      where: { id: childId },
      data: { avatarState },
    });

    return avatarState;
  }

  // ============================================
  // Private
  // ============================================

  private formatItem(item: {
    id: string;
    name: string;
    type: ItemType;
    imageUrl: string;
    unlockStars: number;
    isPremium: boolean;
    rarity: Rarity;
  }): AvatarItemResponse {
    return {
      id: item.id,
      name: item.name,
      type: item.type,
      imageUrl: item.imageUrl,
      unlockStars: item.unlockStars,
      isPremium: item.isPremium,
      rarity: item.rarity,
    };
  }
}

export const avatarService = new AvatarService();
