import { prisma } from '../config/database.js';

interface RoleDefinition {
  name: string;
  description: string;
  permissions: string[];
}

const ROLES: RoleDefinition[] = [
  {
    name: 'admin',
    description: 'Full system administrator',
    permissions: ['admin:all'],
  },
  {
    name: 'parent',
    description: 'Parent user with access to manage children',
    permissions: [
      'children:read',
      'children:write',
      'children:delete',
      'drills:read',
      'sessions:read',
      'sessions:write',
      'settings:read',
      'settings:write',
    ],
  },
];

const ALL_PERMISSIONS = [
  { name: 'admin:all', description: 'Full administrative access' },
  { name: 'children:read', description: 'View children profiles' },
  { name: 'children:write', description: 'Create and update children' },
  { name: 'children:delete', description: 'Delete children profiles' },
  { name: 'drills:read', description: 'View drills' },
  { name: 'drills:write', description: 'Create and update drills' },
  { name: 'sessions:read', description: 'View practice sessions' },
  { name: 'sessions:write', description: 'Create and complete sessions' },
  { name: 'settings:read', description: 'View user settings' },
  { name: 'settings:write', description: 'Update user settings' },
];

export async function seedRolesAndPermissions(): Promise<void> {
  console.log('🌱 Seeding roles and permissions...');

  // Create all permissions
  for (const perm of ALL_PERMISSIONS) {
    await prisma.permission.upsert({
      where: { name: perm.name },
      update: { description: perm.description },
      create: perm,
    });
  }
  console.log(`   ✅ Created ${ALL_PERMISSIONS.length} permissions`);

  // Create roles and assign permissions
  for (const roleDef of ROLES) {
    const role = await prisma.role.upsert({
      where: { name: roleDef.name },
      update: { description: roleDef.description },
      create: {
        name: roleDef.name,
        description: roleDef.description,
      },
    });

    // Get permission IDs
    const permissions = await prisma.permission.findMany({
      where: { name: { in: roleDef.permissions } },
    });

    // Clear existing role permissions and add new ones
    await prisma.rolePermission.deleteMany({
      where: { roleId: role.id },
    });

    for (const perm of permissions) {
      await prisma.rolePermission.create({
        data: {
          roleId: role.id,
          permissionId: perm.id,
        },
      });
    }

    console.log(`   ✅ Role '${roleDef.name}' with ${permissions.length} permissions`);
  }

  console.log('✅ Seeding complete!');
}

// Run if executed directly
const isMainModule = import.meta.url === `file://${process.argv[1]}`;
if (isMainModule) {
  seedRolesAndPermissions()
    .then(() => process.exit(0))
    .catch((e) => {
      console.error(e);
      process.exit(1);
    });
}
