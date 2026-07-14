const List<String> API_FIELDS = [
  '-- Sélectionner --',
  'product.name',
  'product.sku',
  'product.ean',
  'product.batch',
  'product.expiry_date',
  'product.weight',
  'product.origin',
  'product.manufacturer',
  'product.category',
];

const Map<String, String> routeLabels = {
  '/': 'Mes Templates',
  '/templates/new': 'Nouveau template',
  '/scan': "Scanner une étiquette",
};

const Map<String, List<Map<String, dynamic>>> sampleFieldMappings = {
  'Produit laitier': [
    {'api_field': 'product.name', 'x': 42.0, 'y': 18.0},
    {'api_field': 'product.ean', 'x': 42.0, 'y': 65.0},
    {'api_field': 'product.expiry_date', 'x': 42.0, 'y': 120.0},
    {'api_field': 'product.weight', 'x': 42.0, 'y': 175.0},
    {'api_field': 'product.origin', 'x': 42.0, 'y': 230.0},
  ],
  'Conserves alimentaires': [
    {'api_field': 'product.name', 'x': 30.0, 'y': 15.0},
    {'api_field': 'product.ean', 'x': 30.0, 'y': 80.0},
    {'api_field': 'product.batch', 'x': 30.0, 'y': 140.0},
    {'api_field': 'product.weight', 'x': 30.0, 'y': 200.0},
  ],
};

const String appName = 'Label OCR Mapper';
const double navbarHeight = 64.0;
const double cameraZoneHeight = 180.0;
