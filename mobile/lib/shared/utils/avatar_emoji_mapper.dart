import '../../features/avatar/data/avatar.dart';

/// Base avatar emoji map — 6 characters representing gender × skin tone
const baseAvatarEmojis = <String, String>{
  'boy_light': '\u{1F466}\u{1F3FB}',
  'girl_light': '\u{1F467}\u{1F3FB}',
  'boy_dark': '\u{1F466}\u{1F3FF}',
  'girl_dark': '\u{1F467}\u{1F3FF}',
  'boy_medium': '\u{1F466}\u{1F3FD}',
  'girl_medium': '\u{1F467}\u{1F3FD}',
};

/// Returns the emoji for a base avatar key, defaulting to boy_medium.
String baseAvatarEmoji(String? avatarKey) {
  return baseAvatarEmojis[avatarKey] ?? baseAvatarEmojis['boy_medium']!;
}

/// Maps an AvatarItem to its emoji representation.
/// Used by both AvatarDisplay and AvatarShopScreen.
String itemEmoji(AvatarItem item) {
  return itemNameEmoji(item.name);
}

/// Maps item names to emoji characters.
String itemNameEmoji(String itemName) {
  switch (itemName.toLowerCase()) {
    // Hats
    case 'golf cap':
      return '\u{1F9E2}';
    case 'bucket hat':
      return '\u{1F452}';
    case 'sun visor':
      return '\u{1F31E}';
    case 'champion cap':
      return '\u{1F3C6}';
    // Shirts
    case 'green polo':
      return '\u{1F455}';
    case 'striped polo':
      return '\u{1F3BD}';
    case 'pro jersey':
      return '\u{1F947}';
    // Shoes
    case 'white sneakers':
      return '\u{1F45F}';
    case 'golf shoes':
      return '\u{1F45E}';
    // Clubs
    case 'classic putter':
      return '\u{1F3CC}';
    case 'golden putter':
      return '\u2728';
    // Accessories
    case 'golf glove':
      return '\u{1F9E4}';
    case 'cool sunglasses':
      return '\u{1F60E}';
    default:
      return '\u{1F3CC}';
  }
}
