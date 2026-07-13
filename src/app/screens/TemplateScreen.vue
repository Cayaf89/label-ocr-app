<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import {
    ArrowLeft,
    Camera,
    Settings as SettingsIcon,
    CheckCircle2 as CheckCircle2Icon,
    ScanLine,
    ImagePlus,
    Zap,
    ChevronDown,
} from "@lucide/vue";
import ConfidencePill from "../components/ConfidencePill.vue";
import { API_FIELDS, DETECTED_TEXTS } from "../data/constants";

const router = useRouter();

const mappings = ref<Record<number, string>>(
    Object.fromEntries(DETECTED_TEXTS.map((t) => [t.id, "-- Sélectionner --"])),
);
const hasImage = ref(false);
const saved = ref(false);

const handleSave = () => {
    saved.value = true;
    setTimeout(() => (saved.value = false), 2000);
};

const handleBack = () => router.back();
const handleNavigate = () => router.push("/scan");
</script>

<template>
    <div class="flex flex-col h-full bg-background overflow-hidden">
        <!-- App bar -->
        <div class="bg-[#111218] px-4 pb-4 pt-2">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <button @click="handleBack" class="text-white/60 p-1 -ml-1"><ArrowLeft :size="18" /></button>
                    <div>
                        <p
                            class="text-[10px] text-white/50 tracking-widest uppercase"
                            :style="{ fontFamily: 'var(--font-mono)' }"
                        >
                            OCR Mapper
                        </p>
                        <h1
                            class="text-white text-base font-semibold leading-tight mt-0.5"
                            :style="{ fontFamily: 'var(--font-sans)' }"
                        >
                            Configuration template
                        </h1>
                    </div>
                </div>
                <div class="flex items-center gap-2">
                    <button
                        @click="handleNavigate"
                        class="flex items-center gap-1.5 bg-primary text-primary-foreground text-xs font-medium px-3 py-1.5 rounded-sm"
                    >
                        <Camera :size="12" /> Scanner
                    </button>
                </div>
            </div>
        </div>
        <!-- Scrollable content -->
        <div class="flex-1 overflow-y-auto" style="scrollbar-width: none">
            <!-- Title & description -->
            <div class="px-4 pt-4 pb-2 flex flex-col gap-3">
                <div>
                    <label
                        class="text-[10px] text-muted-foreground font-medium tracking-widest uppercase block mb-1.5"
                        :style="{ fontFamily: 'var(--font-mono)' }"
                        >Titre</label
                    >
                    <input
                        type="text"
                        value="Produit laitier"
                        class="w-full bg-card border border-border rounded-sm text-sm text-foreground px-3 py-2 focus:outline-none focus:ring-1 focus:ring-ring placeholder:text-muted-foreground"
                        style="font-family: var(--font-sans)"
                    />
                </div>
                <div>
                    <label
                        class="text-[10px] text-muted-foreground font-medium tracking-widest uppercase block mb-1.5"
                        :style="{ fontFamily: 'var(--font-mono)' }"
                        >Description</label
                    >
                    <textarea
                        value="Lait, yaourts, fromages"
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
                <button
                    @click="hasImage = !hasImage"
                    class="w-full border-2 border-dashed border-border rounded-sm overflow-hidden transition-all"
                    style="min-height: 140px"
                >
                    <template v-if="hasImage">
                        <div class="relative w-full" style="height: 140px">
                            <img
                                src="https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600&h=280&fit=crop&auto=format"
                                alt="Étiquette produit laitier scannée"
                                class="w-full h-full object-cover"
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
                        <div class="flex flex-col items-center justify-center gap-2 py-8 text-muted-foreground">
                            <div class="w-10 h-10 rounded-full bg-muted flex items-center justify-center">
                                <ImagePlus :size="18" class="text-muted-foreground" />
                            </div>
                            <div class="text-center">
                                <p class="text-xs font-medium text-foreground">Photographier une étiquette</p>
                                <p class="text-[10px] text-muted-foreground mt-0.5">
                                    L'OCR détectera automatiquement les textes
                                </p>
                            </div>
                        </div>
                    </template>
                </button>
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
                    >{{ DETECTED_TEXTS.length }}</span
                >
            </div>

            <!-- Mapping rows -->
            <div class="px-4 flex flex-col gap-2 pb-4">
                <div
                    v-for="item in DETECTED_TEXTS"
                    :key="item.id"
                    class="bg-card border border-border rounded-sm overflow-hidden"
                >
                    <div class="px-3 pt-2.5 pb-2 border-b border-border bg-muted/40">
                        <div class="flex items-center justify-between mb-1">
                            <span
                                class="text-[9px] text-muted-foreground tracking-wider uppercase"
                                :style="{ fontFamily: 'var(--font-mono)' }"
                                >Texte détecté</span
                            >
                            <ConfidencePill :value="item.confidence" />
                        </div>
                        <div class="flex items-center gap-2">
                            <ScanLine :size="11" class="text-primary shrink-0" />
                            <span
                                class="text-xs text-foreground font-medium flex-1"
                                :style="{ fontFamily: 'var(--font-mono)' }"
                                >{{ item.text }}</span
                            >
                        </div>
                        <p class="text-[9px] text-muted-foreground mt-1" :style="{ fontFamily: 'var(--font-mono)' }">
                            {{ item.bbox }}
                        </p>
                    </div>
                    <div class="px-3 py-2">
                        <span
                            class="text-[9px] text-muted-foreground tracking-wider uppercase block mb-1"
                            :style="{ fontFamily: 'var(--font-mono)' }"
                            >Champ API</span
                        >
                        <div class="relative">
                            <select
                                :value="mappings[item.id]"
                                @change="(e: Event) => (mappings[item.id] = (e.target as HTMLSelectElement).value)"
                                class="w-full appearance-none bg-background border border-border rounded-sm text-xs px-2.5 py-1.5 pr-7 text-foreground focus:outline-none focus:ring-1 focus:ring-ring"
                            >
                                <option v-for="f in API_FIELDS" :key="f" :value="f">{{ f }}</option>
                            </select>
                            <ChevronDown
                                :size="12"
                                class="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none"
                            />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bottom save bar -->
        <div class="bg-card border-t border-border px-4 py-3 flex items-center gap-3">
            <div class="flex-1">
                <p class="text-[10px] text-muted-foreground">
                    {{ Object.values(mappings).filter((v) => v !== "-- Sélectionner --").length }}/{{
                        DETECTED_TEXTS.length
                    }}
                    champs liés
                </p>
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
