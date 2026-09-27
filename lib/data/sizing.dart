import '../models/product.dart';

/// Who each product is shown to (Homme / Femme) and which sizes it comes in.
///
/// The image library has no gender information, so this is a rule of thumb:
/// everything is unisex unless its brand or subcategory is listed below.
/// Adjust these lists to move a brand into one universe only.
class Sizing {
  Sizing._();

  static const Set<String> _womenOnlyFolders = {
    'ALO', 'Chanel', 'Chloe', 'Celine', 'Christian_Louboutin', 'Handbags', 'Bohemian',
  };

  static const Set<String> _womenOnlySubcategories = {'Sacs à main'};

  static const Set<String> _menOnlyFolders = <String>{};

  static Set<Gender> gendersFor({required String folder, required String subCategory}) {
    if (_womenOnlyFolders.contains(folder) || _womenOnlySubcategories.contains(subCategory)) {
      return const {Gender.femme};
    }
    if (_menOnlyFolders.contains(folder)) return const {Gender.homme};
    return const {Gender.homme, Gender.femme};
  }

  static const _clothing = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _jerseys = ['S', 'M', 'L', 'XL', 'XXL', '3XL'];
  static const _belts = ['80', '85', '90', '95', '100', '105', '110'];

  static List<String> _shoes(Set<Gender> genders) {
    final start = genders.contains(Gender.homme) ? 36 : 35;
    final end = genders.contains(Gender.homme) ? 46 : 42;
    return [for (var size = start; size <= end; size++) '$size'];
  }

  /// Sizes to choose from; empty means "taille unique".
  static List<String> sizesFor({
    required String category,
    required String subCategory,
    required Set<Gender> genders,
  }) {
    switch (category) {
      case 'Chaussures':
        return _shoes(genders);
      case 'Maillots & Sport':
        return subCategory == 'Vêtements techniques' ? _clothing : _jerseys;
      case 'Mode & Streetwear':
        return _clothing;
    }
    if (subCategory == 'Ceintures') return _belts;
    return const [];
  }

  static SizeKind kindFor(String category, String subCategory) {
    if (category == 'Chaussures') return SizeKind.shoe;
    if (subCategory == 'Ceintures') return SizeKind.belt;
    if (category == 'Maillots & Sport' || category == 'Mode & Streetwear') return SizeKind.clothing;
    return SizeKind.oneSize;
  }
}
