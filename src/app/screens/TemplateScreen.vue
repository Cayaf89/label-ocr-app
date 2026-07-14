<script setup lang="ts">
import { computed, onMounted, ref } from "vue";
import {
    Settings as SettingsIcon,
    CheckCircle2 as CheckCircle2Icon,
    ScanLine,
    ImagePlus,
    Zap,
    ChevronDown,
} from "@lucide/vue";
import ConfidencePill from "../components/ConfidencePill.vue";
import EmojiPicker from "../components/EmojiPicker.vue";
import { API_FIELDS, DETECTED_TEXTS, Template, TEMPLATES } from "../data/constants";
import { useRoute } from "vue-router";
import { fileToDataUrl } from "../../services/file.ts";

// Rendered list: always the OCR-detected texts, enriched with parsed bbox coordinates.
interface DisplayItem {
    id: number;
    text: string;
    confidence: number;
    x?: number;
    y?: number;
}

interface OcrTextResult {
    id: number;
    text: string;
    confidence: number;
    bbox: string;
}

const route = useRoute();

const saved = ref(false);
const template = ref<Template>({
    id: 0,
    name: "",
    description: "",
    labelPhoto: "",
    icon: "",
    fieldsCount: 0,
    lastUsed: "",
    color: "",
    accent: "",
    fields: [],
});
const mappings = ref<Record<number, string>>({});
const detectedTexts = ref<OcrTextResult[]>([]);
const hasImage = ref(false);
const imageUrl = ref();

function parseBbox(bbox: string): { x: number; y: number } | null {
    const m = bbox.match(/x:(\d+)\s*y:(\d+)/);
    return m ? { x: Number(m[1]), y: Number(m[2]) } : null;
}

// Match a detected text to the closest template field by coordinate proximity.
function findMatchingField(fieldX: number, fieldY: number, threshold = 15): Template["fields"][number] | undefined {
    return template.value.fields.find(
        (f) => Math.abs(f.x - fieldX) <= threshold && Math.abs(f.y - fieldY) <= threshold,
    );
}

// Get the active list of detected texts (reactive OCR results, fallback to static data).
const activeDetectedTexts = computed(() => (detectedTexts.value.length > 0 ? detectedTexts.value : DETECTED_TEXTS));

// Reverse lookup: find a detected text that matches a given coordinate.
function findMatchingDetectedText(
    fieldX: number,
    fieldY: number,
    threshold = 15,
): OcrTextResult | (typeof DETECTED_TEXTS)[number] | undefined {
    return activeDetectedTexts.value.find((t) => {
        const p = parseBbox(t.bbox);
        return !!p && Math.abs(p.x - fieldX) <= threshold && Math.abs(p.y - fieldY) <= threshold;
    });
}

// Pre-populate mappings when editing an existing template: each detected text tries to snap to the matching field by coords.
function populateMappingsFromFields() {
    for (const t of DETECTED_TEXTS) {
        const parsed = parseBbox(t.bbox);
        if (!parsed) {
            mappings.value[t.id] = "-- Sélectionner --";
            continue;
        }
        const match = findMatchingField(parsed.x, parsed.y);
        mappings.value[t.id] = match ? match.apiField : "-- Sélectionner --";
    }
}

// Alias for use in the template.
function getMatchedText(field: Template["fields"][number]): (typeof DETECTED_TEXTS)[number] | undefined {
    return findMatchingDetectedText(field.x, field.y);
}

onMounted(() => {
    const existing = TEMPLATES.find((tpl) => tpl.id == Number(route.params.id));
    if (existing) {
        template.value = { ...existing };
        // Match detected texts to fields by coordinate proximity.
        populateMappingsFromFields();
    } else {
        // New template — start with no mappings so every row shows "-- Sélectionner --".
        for (const t of DETECTED_TEXTS) {
            mappings.value[t.id] = "-- Sélectionner --";
        }
    }
});

const displayItems = computed<DisplayItem[]>(() =>
    DETECTED_TEXTS.map((t) => ({
        id: t.id,
        text: t.text,
        confidence: t.confidence,
        ...(parseBbox(t.bbox) ?? {}),
    })),
);

const activeCount = computed(() => Object.values(mappings.value).filter((v) => v !== "-- Sélectionner --").length);

const handleSave = () => {
    saved.value = true;
    setTimeout(() => (saved.value = false), 2000);
};

const openImagePicker = () => {
    document.getElementById("template-image")?.click();
};

const startOcr = async (e: Event) => {
    const input = e.target as HTMLInputElement;
    if (!input.files?.length) return;

    const image = input.files[0];
    imageUrl.value = fileToDataUrl(image);
    hasImage.value = true;
};
</script>

<template>
    <div class="flex flex-col h-full bg-background overflow-hidden">
        <!-- Scrollable content -->
        <div class="flex-1 overflow-y-auto" style="scrollbar-width: none">
            <!-- Title & description -->
            <div class="px-4 pt-4 pb-2 flex flex-col gap-3">
                <div>
                    <label
                        class="text-[10px] text-muted-foreground font-medium tracking-widest uppercase block mb-1.5"
                        :style="{ fontFamily: 'var(--font-mono)' }"
                    >
                        Icône & Titre
                    </label>
                    <!-- Inline emoji picker + title -->
                    <div class="flex items-center gap-2">
                        <EmojiPicker v-model="template.icon" />
                        <input
                            type="text"
                            v-model="template.name"
                            placeholder="Nom de l'étiquette…"
                            class="flex-1 bg-card border border-border rounded-sm text-sm text-foreground px-3 py-2 focus:outline-none focus:ring-1 focus:ring-ring placeholder:text-muted-foreground"
                            style="font-family: var(--font-sans)"
                        />
                    </div>
                </div>
                <div>
                    <label
                        class="text-[10px] text-muted-foreground font-medium tracking-widest uppercase block mb-1.5"
                        :style="{ fontFamily: 'var(--font-mono)' }"
                    >
                        Description
                    </label>
                    <textarea
                        v-model="template.description"
                        rows="{2}"
                        class="w-full bg-card border border-border rounded-sm text-sm text-foreground px-3 py-2 focus:outline-none focus:ring-1 focus:ring-ring placeholder:text-muted-foreground resize-none"
                        style="font-family: var(--font-sans)"
                    />
                </div>
            </div>

            <!-- Image zone -->
            <div class="px-4 pt-2 pb-2">
                <p
                    class="text-[10px] text-muted-foreground font-medium tracking-widest uppercase mb-2"
                    :style="{ fontFamily: 'var(--font-mono)' }"
                >
                    Étiquette de référence
                </p>
                <div
                    class="w-full border-2 border-dashed border-border rounded-sm overflow-hidden transition-all min-h-36"
                >
                    <template v-if="hasImage">
                        <div class="relative w-full min-h-36">
                            <img
                                :src="imageUrl"
                                alt="Étiquette produit laitier scannée"
                                class="w-full h-full object-contain"
                            />
                            <div class="absolute inset-0">
                                <div
                                    v-for="(box, i) in [
                                        { top: '12%', left: '12%', w: '55%', h: '14%' },
                                        { top: '34%', left: '12%', w: '46%', h: '12%' },
                                        { top: '54%', left: '12%', w: '38%', h: '12%' },
                                        { top: '72%', left: '12%', w: '42%', h: '12%' },
                                    ]"
                                    :key="i"
                                    class="absolute border border-primary bg-primary/10"
                                    :style="{ top: box.top, left: box.left, width: box.w, height: box.h }"
                                ></div>
                            </div>
                            <div
                                class="absolute bottom-2 right-2 bg-[#111218]/80 text-white text-[9px] px-2 py-1 rounded-sm flex items-center gap-1"
                            >
                                <Zap :size="9" /> 6 zones détectées
                            </div>
                            <button
                                @click.stop="hasImage = false"
                                class="absolute top-2 right-2 bg-[#111218]/80 text-white text-[9px] px-2 py-1 rounded-sm"
                            >
                                Changer
                            </button>
                        </div>
                    </template>
                    <template v-else>
                        <input class="hidden" type="file" id="template-image" @change="startOcr" />
                        <button
                            @click="openImagePicker"
                            class="w-full flex flex-col items-center justify-center gap-2 py-8 text-muted-foreground"
                        >
                            <div class="w-10 h-10 rounded-full bg-muted flex items-center justify-center">
                                <ImagePlus :size="18" class="text-muted-foreground" />
                            </div>
                            <div class="text-center">
                                <p class="text-xs font-medium text-foreground">Photographier une étiquette</p>
                                <p class="text-[10px] text-muted-foreground mt-0.5">
                                    L'OCR détectera automatiquement les textes
                                </p>
                            </div>
                        </button>
                    </template>
                </div>
            </div>

            <!-- Divider + section label -->
            <div class="px-4 pt-3 pb-2 flex items-center gap-3">
                <p
                    class="text-[10px] text-muted-foreground font-medium tracking-widest uppercase whitespace-nowrap"
                    :style="{ fontFamily: 'var(--font-mono)' }"
                >
                    Textes détectés → Champs API
                </p>
                <div class="flex-1 h-px bg-border"></div>
                <span
                    class="text-[9px] text-muted-foreground bg-muted px-1.5 py-0.5 rounded-sm"
                    :style="{ fontFamily: 'var(--font-mono)' }"
                >
                    {{ displayItems.length }}
                </span>
            </div>

            <!-- Mapping rows: loop over template fields, each paired with its matched detected OCR text -->
            <div class="px-4 flex flex-col gap-2 pb-4">
                <template v-for="(field, idx) in template.fields" :key="idx">
                    <div class="bg-card border border-border rounded-sm overflow-hidden">
                        <div class="px-3 pt-2.5 pb-2 border-b border-border bg-muted/40">
                            <div class="flex items-center justify-between mb-1">
                                <span
                                    class="text-[9px] text-muted-foreground tracking-wider uppercase"
                                    :style="{ fontFamily: 'var(--font-mono)' }"
                                >
                                    Texte détecté
                                </span>
                                <ConfidencePill
                                    v-if="getMatchedText(field)"
                                    :value="getMatchedText(field)!.confidence"
                                />
                            </div>
                            <template v-if="getMatchedText(field)">
                                <div class="flex items-center gap-2">
                                    <ScanLine :size="11" class="text-primary shrink-0" />
                                    <span
                                        class="text-xs text-foreground font-medium flex-1"
                                        :style="{ fontFamily: 'var(--font-mono)' }"
                                    >
                                        {{ getMatchedText(field)!.text }}
                                    </span>
                                </div>
                            </template>
                            <template v-else>
                                <p class="text-[9px] text-muted-foreground italic mt-1">
                                    Aucun texte détecté à cette position
                                </p>
                            </template>
                            <p
                                class="text-[9px] text-muted-foreground mt-1"
                                :style="{ fontFamily: 'var(--font-mono)' }"
                            >
                                x : {{ field.x }} / y : {{ field.y }}
                            </p>
                        </div>
                        <div class="px-3 py-2">
                            <span
                                class="text-[9px] text-muted-foreground tracking-wider uppercase block mb-1"
                                :style="{ fontFamily: 'var(--font-mono)' }"
                            >
                                Champ API
                            </span>
                            <div class="relative">
                                <select
                                    v-model="field.apiField"
                                    class="w-full appearance-none bg-background border border-border rounded-sm text-xs px-2.5 py-1.5 pr-7 text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
                                >
                                    <option value="" disabled>-- Sélectionner --</option>
                                    <option v-for="f in API_FIELDS" :key="f" :value="f">{{ f }}</option>
                                </select>
                                <ChevronDown
                                    :size="12"
                                    class="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none"
                                />
                            </div>
                        </div>
                    </div>
                </template>
            </div>
        </div>

        <!-- Bottom save bar -->
        <div class="bg-card border-t border-border px-4 py-3 flex items-center gap-3">
            <div class="flex-1">
                <p class="text-[10px] text-muted-foreground">{{ activeCount }}/{{ displayItems.length }} champs liés</p>
            </div>
            <button
                @click="handleSave"
                :class="[
                    'flex items-center gap-2 px-4 py-2 rounded-sm text-sm font-semibold transition-all',
                    saved ? 'bg-emerald-600 text-white' : 'bg-primary text-primary-foreground',
                ]"
            >
                <template v-if="saved"><CheckCircle2Icon :size="14" /> Sauvegardé</template>
                <template v-else><SettingsIcon :size="14" /> Enregistrer</template>
            </button>
        </div>
    </div>
</template>
