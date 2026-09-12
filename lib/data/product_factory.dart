import '../models/product.dart';
import 'catalog_taxonomy.dart';

/// Turns a raw asset (a folder + an image path) into a fully described
/// [Product]: readable name, realistic price for its category, a short
/// description and a handful of seeded reviews — all deterministic so the
/// catalogue stays stable across app restarts.
class ProductFactory {
  ProductFactory._();

  static Product build({
    required int id,
    required String folder,
    required int indexInFolder,
    required String assetPath,
  }) {
    final brand = CatalogTaxonomy.displayNameFor(folder);
    final (category, subCategory) = CatalogTaxonomy.classify(folder);
    final seed = (folder.hashCode & 0x7fffffff) + indexInFolder;

    return Product(
      id: id,
      name: _nameFor(category, subCategory, brand, indexInFolder),
      brand: brand,
      category: category,
      subCategory: subCategory,
      description: _descriptionFor(subCategory, brand),
      price: _priceFor(subCategory, seed).toDouble(),
      gallery: [assetPath],
      accent: CatalogTaxonomy.colorFor(category),
      reviews: _reviewsFor(seed),
      isFeatured: seed % 9 == 0,
    );
  }

  static const Map<String, List<String>> _itemWords = {
    'Équipes nationales': ['Domicile 2025/26', 'Extérieur 2025/26', 'Third', 'Entraînement'],
    'Clubs européens': ['Domicile 2025/26', 'Extérieur 2025/26', 'Third', 'Entraînement'],
    'Clubs sud-américains': ['Domicile 2025/26', 'Extérieur 2025/26', 'Third', 'Entraînement'],
    'Compétitions & Éditions': ['Édition Collector', 'Match Ball Edition', 'Série limitée'],
    'Vêtements techniques': ['Performance', 'Training Fit', 'Pro Series'],
    'Sneakers': ['Runner', 'Court Classic', 'Street Edition', 'Retro', 'Zenith', 'Nova'],
    'Running': ['Speed', 'Trail Pro', 'Endurance', 'Flex Boost'],
    'Football': ['Predator Grip', 'Precision', 'Control Fit'],
    'Confort & Sandales': ['Comfort Fit', 'Summer Edition', 'Classic'],
    'Souliers de luxe': ['Édition signature', 'Modèle iconique', 'Collection Prestige'],
    'Maisons de luxe': ['Veste signature', 'Pull structuré', 'Ensemble couture', 'Manteau long', 'Chemise soie'],
    'Streetwear': ['Hoodie oversize', 'T-shirt graphique', 'Cargo pants', 'Coupe-vent'],
    'Manteaux & Vestes': ['Parka', 'Doudoune', 'Trench', 'Blouson'],
    'Sacs à main': ['Sac cabas', 'Sac bandoulière', 'Pochette soirée', 'Mini sac'],
    'Sacs de voyage': ['Sac week-end', 'Cartable cuir', 'Sac de voyage'],
    'Maisons emblématiques': ['Sac iconique', 'Édition signature', 'Pièce collector'],
    'Bijoux': ['Collier', 'Bracelet', 'Bague', "Boucles d'oreilles"],
    'Montres': ['Montre automatique', 'Chronographe', 'Montre acier'],
    'Lunettes': ['Lunettes de soleil', 'Monture optique'],
    'Ceintures': ['Ceinture cuir', 'Ceinture réversible'],
    'Autres accessoires': ['Article signature', 'Pièce exclusive'],
  };

  static String _nameFor(String category, String subCategory, String brand, int index) {
    final words = _itemWords[subCategory] ?? const ['Édition'];
    final word = words[index % words.length];
    final ref = (index + 1).toString().padLeft(3, '0');
    final isJersey = category == 'Maillots & Sport';
    final base = isJersey ? 'Maillot $brand $word' : '$brand $word';
    return '$base · Réf $ref';
  }

  static const Map<String, String> _descriptions = {
    'Équipes nationales': 'Maillot officiel, tissu respirant et coupe athlétique pour supporter aux couleurs du pays.',
    'Clubs européens': 'Maillot de club, technologie respirante et finitions brodées fidèles au modèle porté sur le terrain.',
    'Clubs sud-américains': 'Maillot de club, coupe moderne et matière technique pour un look authentique.',
    'Compétitions & Éditions': 'Pièce collector à tirage limité, pensée pour les passionnés de football.',
    'Vêtements techniques': 'Tenue technique respirante conçue pour l’entraînement comme pour la ville.',
    'Sneakers': 'Silhouette signature, amorti confortable et finition premium pour un usage quotidien.',
    'Running': 'Chaussure de course légère, amorti réactif et maintien optimal sur longue distance.',
    'Football': 'Chaussure à crampons pensée pour le contrôle du ballon et l’accélération.',
    'Confort & Sandales': 'Confort longue durée, semelle souple et maintien étudié pour toute la journée.',
    'Souliers de luxe': 'Modèle iconique, cuir sélectionné et savoir-faire artisanal reconnu.',
    'Maisons de luxe': 'Pièce signature, matières nobles et finitions haute couture.',
    'Streetwear': 'Silhouette urbaine, coupe contemporaine et esprit rue assumé.',
    'Manteaux & Vestes': 'Protection premium contre le froid, isolation performante et style hivernal.',
    'Sacs à main': 'Maroquinerie soignée, cuir sélectionné et structure pensée pour le quotidien.',
    'Sacs de voyage': 'Sac spacieux et robuste, pensé pour les déplacements fréquents.',
    'Maisons emblématiques': 'Pièce iconique de la maison, savoir-faire artisanal transmis depuis des décennies.',
    'Bijoux': 'Bijou raffiné, finition soignée pour sublimer chaque tenue.',
    'Montres': 'Garde-temps de précision, boîtier soigné et mouvement fiable.',
    'Lunettes': 'Monture au design étudié, protection UV et confort de port.',
    'Ceintures': 'Ceinture en cuir véritable, boucle métal et finition durable.',
    'Autres accessoires': 'Accessoire signature qui complète chaque tenue avec élégance.',
  };

  static String _descriptionFor(String subCategory, String brand) {
    final base = _descriptions[subCategory] ?? 'Article sélectionné par AURORA pour sa qualité et son style.';
    return '$brand — $base';
  }

  static const Map<String, List<int>> _priceLadders = {
    'Équipes nationales': [69, 79, 89, 94, 99, 109, 119],
    'Clubs européens': [69, 79, 89, 94, 99, 109, 119],
    'Clubs sud-américains': [69, 79, 89, 94, 99, 109, 119],
    'Compétitions & Éditions': [99, 129, 149, 179, 219],
    'Vêtements techniques': [59, 79, 99, 119, 139],
    'Sneakers': [79, 89, 99, 109, 119, 129, 149],
    'Running': [99, 119, 139, 159, 179],
    'Football': [89, 109, 129, 149],
    'Confort & Sandales': [49, 59, 69, 79, 89],
    'Souliers de luxe': [390, 490, 590, 690, 790],
    'Maisons de luxe': [349, 429, 520, 650, 790, 990, 1290],
    'Streetwear': [89, 119, 149, 189, 229],
    'Manteaux & Vestes': [199, 259, 320, 390, 460],
    'Sacs à main': [190, 250, 320, 420],
    'Sacs de voyage': [220, 280, 350],
    'Maisons emblématiques': [590, 780, 950, 1200, 1490],
    'Bijoux': [120, 180, 250, 350, 490],
    'Montres': [350, 490, 690, 950, 1400],
    'Lunettes': [95, 120, 150, 190, 230],
    'Ceintures': [59, 79, 99, 129],
    'Autres accessoires': [39, 59, 79, 99],
  };

  static int _priceFor(String subCategory, int seed) {
    final ladder = _priceLadders[subCategory] ?? const [49, 69, 89, 109];
    return ladder[seed % ladder.length];
  }

  static const List<String> _authors = [
    'Sami', 'Léa', 'Nicolas', 'Chloé', 'Imad', 'Aurélie', 'Thomas', 'Inès',
    'Paul', 'Mila', 'Emma', 'Léo', 'Sarah', 'Hugo', 'Camille', 'Yanis',
  ];

  static const List<String> _comments = [
    'Qualité au rendez-vous, exactement comme sur les photos.',
    'Très belle finition, livraison rapide.',
    'Coupe parfaite et matière agréable.',
    'Au-dessus de mes attentes, je recommande.',
    'Look premium, je suis conquise.',
    'Correspond parfaitement à la description.',
  ];

  static List<ProductReview> _reviewsFor(int seed) {
    final reviewCount = seed % 5;
    if (reviewCount == 0) return const [];
    return List.generate(reviewCount, (i) {
      final authorIndex = (seed + i * 7) % _authors.length;
      final commentIndex = (seed + i * 3) % _comments.length;
      final rating = 3 + ((seed + i) % 3);
      return ProductReview(
        author: _authors[authorIndex],
        rating: rating,
        comment: _comments[commentIndex],
      );
    });
  }
}
