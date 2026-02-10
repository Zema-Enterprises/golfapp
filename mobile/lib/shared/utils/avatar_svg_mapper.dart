import '../../features/avatar/data/avatar.dart';

/// All 6 base avatar keys
const avatarBaseKeys = [
  'boy_light', 'girl_light',
  'boy_dark', 'girl_dark',
  'boy_medium', 'girl_medium',
];

/// Maps an AvatarItem to its SVG asset filename (without path/extension).
String itemSvgAssetName(AvatarItem item) {
  switch (item.name.toLowerCase()) {
    case 'golf cap':
      return 'hat_golf_cap';
    case 'bucket hat':
      return 'hat_bucket_hat';
    case 'sun visor':
      return 'hat_sun_visor';
    case 'champion cap':
      return 'hat_champion_cap';
    case 'green polo':
      return 'shirt_green_polo';
    case 'striped polo':
      return 'shirt_striped_polo';
    case 'pro jersey':
      return 'shirt_pro_jersey';
    case 'white sneakers':
      return 'shoes_white_sneakers';
    case 'golf shoes':
      return 'shoes_golf_shoes';
    case 'classic putter':
      return 'club_classic_putter';
    case 'golden putter':
      return 'club_golden_putter';
    case 'golf glove':
      return 'acc_golf_glove';
    case 'cool sunglasses':
      return 'acc_cool_sunglasses';
    default:
      return 'hat_golf_cap';
  }
}

/// Returns the asset path for a base avatar SVG.
String avatarBaseSvgPath(String avatarKey) =>
    'assets/avatars/base/$avatarKey.svg';

/// Returns the asset path for an item SVG.
String avatarItemSvgPath(AvatarItem item) =>
    'assets/avatars/items/${itemSvgAssetName(item)}.svg';
