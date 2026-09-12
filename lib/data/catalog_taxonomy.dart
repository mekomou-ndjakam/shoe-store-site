import 'package:flutter/material.dart';

/// Maps every real asset folder (`assets/products/store_images/<folder>`) to a
/// category and subcategory so the catalogue reflects what is actually in the
/// image library instead of a generic "shoe store" guess.
class CatalogTaxonomy {
  CatalogTaxonomy._();

  static const Map<String, Map<String, List<String>>> tree = {
    'Chaussures': {
      'Sneakers': ['Adidas', 'Adidas_Originals', 'Ascis', 'Converse', 'All', 'Gooden_Goose'],
      'Running': ['Adidas_Running_Shoes', 'Hoka_One_One'],
      'Football': ['Adidas_Super_Sala', 'Adidas_X'],
      'Confort & Sandales': ['Birkenstock', 'Crocs', 'Cat'],
      'Souliers de luxe': ['Christian_Louboutin', 'Ferragamo', 'Coach'],
    },
    'Maillots & Sport': {
      'Équipes nationales': [
        'Albania', 'Algeria', 'Argentina', 'Armenia', 'Australia', 'Austria', 'Belgium', 'Brazil',
        'Cameroon', 'Canada', 'Chile', 'China', 'Colombia', 'Costa_Rica', 'Croatia', 'Czech_Republic',
        'Denmark', 'Ecuador', 'Egypt', 'El_Salvador', 'England', 'Finland', 'France', 'Georgia',
        'Germany', 'Ghana', 'Greece', 'Guatemala', 'Guinea', 'Honduras', 'Hungary', 'Iceland',
        'Ireland', 'Italy', 'Ivory_Coast',
      ],
      'Clubs européens': [
        'AC_Monza', 'ATHLETIC_CLUB', 'Ajax', 'Athletic_Bilbao', 'Atletico_Madrid', 'Bayer_Leverkusen',
        'Bayern_Munich', 'Barcelona', 'Birmingham_City', 'Borussia_Dortmund', 'Borussia_Monchengladbach',
        'CA_OSASUNA', 'Celtic', 'Coventry_City', 'Coventry_FC', 'CÁDIZ_CF', 'DEPORTIVO_ALAVÉS',
        'Derby_County', 'Dynamo_Kyiv', 'Elche_CF', 'FC_Augsburg', 'FC_Copenhagen', 'FC_Heidenheim',
        'FC_Köln', 'FC_Red_Bull_Salzburg', 'FC_St._Pauli', 'FC_Twente', 'Fenerbahce', 'Feyenoord',
        'Fortuna_Düsseldorf', 'Frankfurt', 'Freiburg', 'GETAFE_CF', 'GRANADA_CF', 'Galatasaray',
        'Girona_FC', 'Glasgow_Rangers', 'Hamburger_SV', 'Hoffenheim',
      ],
      'Clubs sud-américains': [
        'Athletico_Paranaense', 'Atletico_Mineiro', 'Atletico_Nacional', 'Boca_Juniors', 'Botafogo',
        'CD_Olimpia', 'CD_Palestino', 'Ceará', 'Colo_Colo', 'Corinthians', 'Cruzeiro', 'Deportivo_Cali',
        'Esporte_Clube_Bahia', 'FC_Motagua', 'Flamengo', 'Fluminense', 'Fortaleza', 'Gremio',
        'Internacional_RS',
      ],
      'Compétitions & Éditions': [
        'Argentine_Primera_División', 'Brasileiro_Série_A', 'Bundesliga', 'Campeonato_Chileno',
        'Championship_League', 'Club_Teams', 'Colombia_League', 'Eredivisie', 'Euro_Clubs', 'FIFA',
        'FIFA_World_Cup_2026', 'CR7',
      ],
      'Vêtements techniques': ['ALO', 'Descente'],
    },
    'Mode & Streetwear': {
      'Maisons de luxe': [
        'Alexander_McQueen', 'Armani', 'Balenciaga', 'Balenciage', 'Bally', 'Balmain', 'Boss',
        'Bottega_Veneta', 'Burberry', 'Chanel', 'Celine', 'Chloe', 'D&G', 'Dior', 'DSQ', 'Fendi',
        'Givenchy', 'Gucci',
      ],
      'Streetwear': ['Amiri', 'Bape', 'Carhartt'],
      'Manteaux & Vestes': ['Canada_Goose', 'Helly_Hansen', "ARC'TERYX", 'Jacket', 'Jackets'],
    },
    'Sacs & Maroquinerie': {
      'Sacs à main': ['Handbags'],
      'Sacs de voyage': ['Bugatti'],
      'Maisons emblématiques': ['Goyard', 'Hermes', 'Hernes'],
    },
    'Accessoires': {
      'Bijoux': ['Cartier', 'Bulgari', 'Bvlgari', 'Fred', 'Chrome_Hearts', 'Goya', 'Bohemian'],
      'Montres': ['Chorpard', 'Hublot', 'Akoni'],
      'Lunettes': ['Cazal', 'Dita', 'Carin', 'Gentle_Monster'],
      'Ceintures': ['Belts'],
      'Autres accessoires': ['Accessories', 'Category_114'],
    },
  };

  static const Map<String, String> _displayNameOverrides = {
    'AC_Monza': 'AC Monza',
    'ALO': 'Alo Yoga',
    "ARC'TERYX": "Arc'teryx",
    'ATHLETIC_CLUB': 'Athletic Club',
    'Accessories': 'Aurora Essentials',
    'Ascis': 'Asics',
    'Athletico_Paranaense': 'Athletico Paranaense',
    'Atletico_Madrid': 'Atlético Madrid',
    'Atletico_Mineiro': 'Atlético Mineiro',
    'Atletico_Nacional': 'Atlético Nacional',
    'Argentine_Primera_División': 'Primera División Argentine',
    'Balenciage': 'Balenciaga',
    'Bayer_Leverkusen': 'Bayer Leverkusen',
    'Borussia_Monchengladbach': 'Borussia Mönchengladbach',
    'Brasileiro_Série_A': 'Brasileiro Série A',
    'CA_OSASUNA': 'CA Osasuna',
    'CD_Olimpia': 'CD Olimpia',
    'CD_Palestino': 'CD Palestino',
    'CR7': 'CR7 Collection',
    'Campeonato_Chileno': 'Campeonato Chileno',
    'Canada_Goose': 'Canada Goose',
    'Category_114': 'Sélection Aurora',
    'Championship_League': 'Champions League',
    'Chorpard': 'Chopard',
    'Christian_Louboutin': 'Christian Louboutin',
    'Chrome_Hearts': 'Chrome Hearts',
    'Club_Teams': 'Clubs internationaux',
    'Colo_Colo': 'Colo-Colo',
    'Colombia_League': 'Ligue Colombienne',
    'Costa_Rica': 'Costa Rica',
    'Coventry_City': 'Coventry City',
    'Coventry_FC': 'Coventry FC',
    'Czech_Republic': 'République Tchèque',
    'CÁDIZ_CF': 'Cádiz CF',
    'D&G': 'Dolce & Gabbana',
    'DEPORTIVO_ALAVÉS': 'Deportivo Alavés',
    'DSQ': 'Dsquared2',
    'Deportivo_Cali': 'Deportivo Cali',
    'Derby_County': 'Derby County',
    'Dynamo_Kyiv': 'Dynamo Kyiv',
    'El_Salvador': 'Salvador',
    'Elche_CF': 'Elche CF',
    'Esporte_Clube_Bahia': 'EC Bahia',
    'Euro_Clubs': 'Clubs Européens',
    'FC_Copenhagen': 'FC Copenhague',
    'FC_Köln': 'FC Köln',
    'FC_Red_Bull_Salzburg': 'RB Salzburg',
    'FC_St._Pauli': 'FC St. Pauli',
    'FIFA': 'FIFA Collection',
    'FIFA_World_Cup_2026': 'Coupe du Monde 2026',
    'Fenerbahce': 'Fenerbahçe',
    'Fortuna_Düsseldorf': 'Fortuna Düsseldorf',
    'Frankfurt': 'Eintracht Frankfurt',
    'Freiburg': 'SC Freiburg',
    'GETAFE_CF': 'Getafe CF',
    'GRANADA_CF': 'Granada CF',
    'Gentle_Monster': 'Gentle Monster',
    'Girona_FC': 'Girona FC',
    'Gooden_Goose': 'Golden Goose',
    'Gremio': 'Grêmio',
    'Hamburger_SV': 'Hamburger SV',
    'Helly_Hansen': 'Helly Hansen',
    'Hermes': 'Hermès',
    'Hernes': 'Hermès',
    'Hoffenheim': 'TSG Hoffenheim',
    'Hoka_One_One': 'Hoka One One',
    'Internacional_RS': 'Internacional',
    'Ivory_Coast': "Côte d'Ivoire",
    'Albania': 'Albanie',
    'Algeria': 'Algérie',
    'Argentina': 'Argentine',
    'Armenia': 'Arménie',
    'Australia': 'Australie',
    'Austria': 'Autriche',
    'Belgium': 'Belgique',
    'Brazil': 'Brésil',
    'Cameroon': 'Cameroun',
    'Chile': 'Chili',
    'China': 'Chine',
    'Colombia': 'Colombie',
    'Croatia': 'Croatie',
    'Denmark': 'Danemark',
    'Ecuador': 'Équateur',
    'Egypt': 'Égypte',
    'England': 'Angleterre',
    'Finland': 'Finlande',
    'Georgia': 'Géorgie',
    'Germany': 'Allemagne',
    'Greece': 'Grèce',
    'Guinea': 'Guinée',
    'Hungary': 'Hongrie',
    'Iceland': 'Islande',
    'Ireland': 'Irlande',
    'Italy': 'Italie',
  };

  static const Map<String, Color> categoryColors = {
    'Chaussures': Color(0xFFFF6B3D),
    'Maillots & Sport': Color(0xFF2E7D32),
    'Mode & Streetwear': Color(0xFF6D28D9),
    'Sacs & Maroquinerie': Color(0xFFB45309),
    'Accessoires': Color(0xFFB8860B),
  };

  static const Map<String, IconData> categoryIcons = {
    'Chaussures': Icons.directions_walk_rounded,
    'Maillots & Sport': Icons.sports_soccer_rounded,
    'Mode & Streetwear': Icons.checkroom_rounded,
    'Sacs & Maroquinerie': Icons.shopping_bag_rounded,
    'Accessoires': Icons.diamond_rounded,
  };

  static List<String> get categories => tree.keys.toList();

  static List<String> subcategoriesFor(String category) =>
      tree[category]?.keys.toList() ?? const <String>[];

  static Color colorFor(String category) => categoryColors[category] ?? const Color(0xFF111111);

  static IconData iconFor(String category) => categoryIcons[category] ?? Icons.category_rounded;

  static String displayNameFor(String folder) {
    final override = _displayNameOverrides[folder];
    if (override != null) return override;
    return folder.replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// folder -> (category, subcategory), computed once.
  static final Map<String, (String, String)> _byFolder = _buildIndex();

  static Map<String, (String, String)> _buildIndex() {
    final index = <String, (String, String)>{};
    tree.forEach((category, subcategories) {
      subcategories.forEach((subcategory, folders) {
        for (final folder in folders) {
          index[folder] = (category, subcategory);
        }
      });
    });
    return index;
  }

  static (String category, String subcategory) classify(String folder) {
    return _byFolder[folder] ?? ('Accessoires', 'Autres accessoires');
  }
}
