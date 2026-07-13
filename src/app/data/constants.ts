export const TEMPLATES = [
    {
        id: 1,
        name: "Produit laitier",
        description: "Lait, yaourts, fromages",
        icon: "🥛",
        fieldsCount: 6,
        lastUsed: "Aujourd'hui, 09:14",
        color: "#E8F0FE",
        accent: "#0047CC",
    },
    {
        id: 2,
        name: "Conserves alimentaires",
        description: "Boîtes et bocaux",
        icon: "🥫",
        fieldsCount: 5,
        lastUsed: "Hier, 14:32",
        color: "#FEF3E8",
        accent: "#CC5200",
    },
    {
        id: 3,
        name: "Surgelés",
        description: "Produits congelés",
        icon: "🧊",
        fieldsCount: 7,
        lastUsed: "11/07/2026",
        color: "#E8F8FE",
        accent: "#0092CC",
    },
    {
        id: 4,
        name: "Cosmétiques",
        description: "Soins et beauté",
        icon: "🧴",
        fieldsCount: 8,
        lastUsed: "09/07/2026",
        color: "#F5E8FE",
        accent: "#7A00CC",
    },
    {
        id: 5,
        name: "Médicaments OTC",
        description: "Sans ordonnance",
        icon: "💊",
        fieldsCount: 9,
        lastUsed: "07/07/2026",
        color: "#FEE8E8",
        accent: "#CC0022",
    },
];

export const API_FIELDS = [
    "-- Sélectionner --",
    "product.name",
    "product.sku",
    "product.ean",
    "product.batch",
    "product.expiry_date",
    "product.weight",
    "product.origin",
    "product.manufacturer",
    "product.category",
] as const;

export const DETECTED_TEXTS = [
    { id: 1, text: "LAIT ENTIER BIO", bbox: "x:42 y:18 w:210 h:24", confidence: 98 },
    { id: 2, text: "3760123456789", bbox: "x:42 y:58 w:180 h:20", confidence: 99 },
    { id: 3, text: "LOT: A2024-07", bbox: "x:42 y:96 w:150 h:20", confidence: 96 },
    { id: 4, text: "DLC: 22/07/2026", bbox: "x:42 y:128 w:165 h:20", confidence: 97 },
    { id: 5, text: "1L · 1030g", bbox: "x:42 y:160 w:120 h:18", confidence: 94 },
    { id: 6, text: "NORMANDIE, FRANCE", bbox: "x:42 y:194 w:200 h:20", confidence: 95 },
];

export const SCAN_DATA = [
    { apiField: "product.name", value: "LAIT ENTIER BIO", confidence: 98 },
    { apiField: "product.ean", value: "3760123456789", confidence: 99 },
    { apiField: "product.batch", value: "A2024-07", confidence: 96 },
    { apiField: "product.expiry_date", value: "22/07/2026", confidence: 97 },
    { apiField: "product.weight", value: "1030g", confidence: 94 },
    { apiField: "product.origin", value: "NORMANDIE, FRANCE", confidence: 95 },
];
