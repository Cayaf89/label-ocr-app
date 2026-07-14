export interface Template {
    id: number;
    name: string;
    description: string;
    labelPhoto: string;
    icon: string;
    fieldsCount: number;
    lastUsed: string;
    color: string;
    accent: string;
    fields: TemplateField[];
}
export interface TemplateField {
    id: number;
    apiField: string;
    x: number;
    y: number;
    confidence: number;
}

export const TEMPLATES: Template[] = [
    {
        id: 1,
        name: "Produit laitier",
        description: "Lait, yaourts, fromages",
        labelPhoto: "",
        icon: "🥛",
        fieldsCount: 6,
        lastUsed: "Aujourd'hui, 09:14",
        color: "#E8F0FE",
        accent: "#0047CC",
        fields: [
            { id: 1, apiField: "product.name", x: 42, y: 18, confidence: 98 },
            { id: 2, apiField: "product.ean", x: 42, y: 56, confidence: 99 },
            { id: 3, apiField: "product.batch", x: 42, y: 94, confidence: 96 },
            { id: 4, apiField: "product.expiry_date", x: 42, y: 128, confidence: 97 },
            { id: 5, apiField: "product.weight", x: 42, y: 160, confidence: 94 },
            { id: 6, apiField: "product.origin", x: 42, y: 194, confidence: 95 },
        ],
    },
    {
        id: 2,
        name: "Conserves alimentaires",
        description: "Boîtes et bocaux",
        labelPhoto: "",
        icon: "🥫",
        fieldsCount: 5,
        lastUsed: "Hier, 14:32",
        color: "#FEF3E8",
        accent: "#CC5200",
        fields: [
            { id: 1, apiField: "product.name", x: 38, y: 22, confidence: 97 },
            { id: 2, apiField: "product.ean", x: 38, y: 54, confidence: 99 },
            { id: 3, apiField: "product.batch", x: 38, y: 86, confidence: 95 },
            { id: 4, apiField: "product.expiry_date", x: 38, y: 116, confidence: 98 },
            { id: 5, apiField: "product.weight", x: 38, y: 148, confidence: 93 },
        ],
    },
    {
        id: 3,
        name: "Surgelés",
        description: "Produits congelés",
        labelPhoto: "",
        icon: "🧊",
        fieldsCount: 7,
        lastUsed: "11/07/2026",
        color: "#E8F8FE",
        accent: "#0092CC",
        fields: [
            { id: 1, apiField: "product.name", x: 45, y: 16, confidence: 96 },
            { id: 2, apiField: "product.ean", x: 45, y: 50, confidence: 98 },
            { id: 3, apiField: "product.batch", x: 45, y: 84, confidence: 94 },
            { id: 4, apiField: "product.expiry_date", x: 45, y: 120, confidence: 97 },
            { id: 5, apiField: "product.weight", x: 45, y: 156, confidence: 95 },
            { id: 6, apiField: "product.origin", x: 45, y: 188, confidence: 92 },
            { id: 7, apiField: "product.category", x: 45, y: 220, confidence: 91 },
        ],
    },
    {
        id: 4,
        name: "Cosmétiques",
        description: "Soins et beauté",
        labelPhoto: "",
        icon: "🧴",
        fieldsCount: 8,
        lastUsed: "09/07/2026",
        color: "#F5E8FE",
        accent: "#7A00CC",
        fields: [
            { id: 1, apiField: "product.name", x: 35, y: 20, confidence: 97 },
            { id: 2, apiField: "product.ean", x: 35, y: 52, confidence: 98 },
            { id: 3, apiField: "product.batch", x: 35, y: 86, confidence: 95 },
            { id: 4, apiField: "product.expiry_date", x: 35, y: 120, confidence: 96 },
            { id: 5, apiField: "product.weight", x: 35, y: 152, confidence: 93 },
            { id: 6, apiField: "product.origin", x: 35, y: 184, confidence: 90 },
            { id: 7, apiField: "product.manufacturer", x: 35, y: 216, confidence: 94 },
            { id: 8, apiField: "product.category", x: 35, y: 250, confidence: 89 },
        ],
    },
    {
        id: 5,
        name: "Médicaments OTC",
        description: "Sans ordonnance",
        labelPhoto: "",
        icon: "💊",
        fieldsCount: 9,
        lastUsed: "07/07/2026",
        color: "#FEE8E8",
        accent: "#CC0022",
        fields: [
            { id: 1, apiField: "product.name", x: 40, y: 14, confidence: 98 },
            { id: 2, apiField: "product.ean", x: 40, y: 46, confidence: 99 },
            { id: 3, apiField: "product.sku", x: 40, y: 78, confidence: 96 },
            { id: 4, apiField: "product.batch", x: 40, y: 112, confidence: 95 },
            { id: 5, apiField: "product.expiry_date", x: 40, y: 146, confidence: 97 },
            { id: 6, apiField: "product.weight", x: 40, y: 178, confidence: 93 },
            { id: 7, apiField: "product.origin", x: 40, y: 210, confidence: 91 },
            { id: 8, apiField: "product.manufacturer", x: 40, y: 242, confidence: 94 },
            { id: 9, apiField: "product.category", x: 40, y: 276, confidence: 88 },
        ],
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
    { apiField: "product.name", x: 42, y: 18, confidence: 98 },
    { apiField: "product.ean", x: 42, y: 58, confidence: 99 },
    { apiField: "product.batch", x: 42, y: 96, confidence: 96 },
    { apiField: "product.expiry_date", x: 42, y: 128, confidence: 97 },
    { apiField: "product.weight", x: 42, y: 160, confidence: 94 },
    { apiField: "product.origin", x: 42, y: 194, confidence: 95 },
];

export const ROUTE_LABELS = {
    "template-list": "Mes Templates",
    "template-new": "Nouveau template",
    "template-update": "Configuration du template",
    scan: "Scanner une étiquette",
} as const;
