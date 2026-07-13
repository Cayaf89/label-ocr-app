<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { ArrowLeft, Camera, SendIcon, CheckCircle2Icon, ScanLine } from "@lucide/vue";
import ConfidencePill from "../components/ConfidencePill.vue";
import { SCAN_DATA } from "../data/constants";

const router = useRouter();

const scanned = ref(false);
const sent = ref(false);
const scanning = ref(false);

const handleScan = () => {
    scanning.value = true;
    setTimeout(() => {
        scanning.value = false;
        scanned.value = true;
    }, 1400);
};

const handleBack = () => router.back();
</script>

<template>
    <div class="flex flex-col h-full bg-background overflow-hidden">
        <!-- App bar -->
        <div class="bg-[#111218] px-4 pb-4 pt-2">
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
                        Scanner une étiquette
                    </h1>
                </div>
            </div>
        </div>

        <div class="flex-1 overflow-y-auto" style="scrollbar-width: none">
            <!-- Camera / scan zone -->
            <div class="px-4 pt-4 pb-2">
                <div class="relative w-full rounded-sm overflow-hidden bg-[#111218]" style="height: 180px">
                    <template v-if="scanned">
                        <img
                            src="https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600&h=360&fit=crop&auto=format"
                            alt="Étiquette scannée"
                            class="w-full h-full object-cover opacity-80"
                        />
                        <div class="absolute inset-0">
                            <div
                                v-for="(item, i) in SCAN_DATA"
                                :key="i"
                                class="absolute border border-primary bg-primary/15"
                                :style="{
                                    top: `${12 + i * 13}%`,
                                    left: '10%',
                                    width: `${45 + (i % 3) * 8}%`,
                                    height: '9%',
                                }"
                            >
                                <span
                                    class="absolute -top-3.5 left-0 text-[7px] bg-primary text-white px-1 py-0.5 leading-none"
                                    :style="{ fontFamily: 'var(--font-mono)' }"
                                    >{{ item.apiField }}</span
                                >
                            </div>
                        </div>
                        <div
                            class="absolute bottom-2 left-2 bg-[#111218]/80 text-white text-[9px] px-2 py-1 rounded-sm flex items-center gap-1"
                        >
                            <CheckCircle2Icon :size="9" class="text-emerald-400" /> {{ SCAN_DATA.length }} champs
                            reconnus
                        </div>
                    </template>
                    <template v-else-if="scanning">
                        <div class="w-full h-full flex flex-col items-center justify-center gap-3">
                            <div class="relative w-32 h-32 border-2 border-white/20 rounded-sm">
                                <div class="absolute top-0 left-0 w-4 h-4 border-t-2 border-l-2 border-primary" />
                                <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-primary" />
                                <div class="absolute bottom-0 left-0 w-4 h-4 border-b-2 border-l-2 border-primary" />
                                <div class="absolute bottom-0 right-0 w-4 h-4 border-b-2 border-r-2 border-primary" />
                                <div
                                    class="absolute left-0 right-0 h-0.5 bg-primary/80 scan-line"
                                    :style="{ top: '50%' }"
                                ></div>
                            </div>
                            <p class="text-white/60 text-xs" :style="{ fontFamily: 'var(--font-mono)' }">
                                Analyse en cours…
                            </p>
                        </div>
                    </template>
                    <template v-else>
                        <div class="w-full h-full flex flex-col items-center justify-center gap-3">
                            <div class="relative w-28 h-28 border border-white/20 rounded-sm">
                                <div class="absolute top-0 left-0 w-4 h-4 border-t-2 border-l-2 border-white/50" />
                                <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-white/50" />
                                <div class="absolute bottom-0 left-0 w-4 h-4 border-b-2 border-l-2 border-white/50" />
                                <div class="absolute bottom-0 right-0 w-4 h-4 border-b-2 border-r-2 border-white/50" />
                                <Camera :size="24" class="absolute inset-0 m-auto text-white/30" />
                            </div>
                            <p class="text-white/50 text-xs" :style="{ fontFamily: 'var(--font-mono)' }">
                                Pointez vers une étiquette
                            </p>
                        </div>
                    </template>
                </div>

                <!-- Scan trigger -->
                <button
                    v-if="!scanned"
                    @click="handleScan"
                    :disabled="scanning"
                    class="mt-3 w-full flex items-center justify-center gap-2 border border-border bg-card text-foreground text-sm font-semibold py-2.5 rounded-sm disabled:opacity-50"
                >
                    <Camera :size="15" /> {{ scanning ? "Analyse…" : "Prendre une photo" }}
                </button>
                <button
                    v-if="scanned && !sent"
                    @click="scanned = false"
                    class="mt-3 w-full flex items-center justify-center gap-2 border border-border bg-card text-foreground text-xs font-medium py-2 rounded-sm"
                >
                    <Camera :size="13" /> Rescanner
                </button>
            </div>

            <!-- Section divider -->
            <div v-if="scanned" class="px-4 pt-3 pb-2 flex items-center gap-3">
                <p
                    class="text-[10px] text-muted-foreground font-medium tracking-widest uppercase whitespace-nowrap"
                    :style="{ fontFamily: 'var(--font-mono)' }"
                >
                    Données extraites
                </p>
                <div class="flex-1 h-px bg-border"></div>
            </div>

            <!-- Extracted data fields -->
            <div v-if="scanned" class="px-4 flex flex-col gap-2 pb-4">
                <div
                    v-for="(item, i) in SCAN_DATA"
                    :key="i"
                    class="bg-card border border-border rounded-sm overflow-hidden"
                >
                    <div class="px-3 pt-2 pb-1.5 border-b border-border bg-muted/30">
                        <span
                            class="text-[9px] text-primary font-medium tracking-wider"
                            :style="{ fontFamily: 'var(--font-mono)' }"
                            >{{ item.apiField }}</span
                        >
                    </div>
                    <div class="px-3 py-2 flex items-center justify-between">
                        <span class="text-xs text-foreground font-medium" :style="{ fontFamily: 'var(--font-mono)' }">{{
                            item.value
                        }}</span>
                        <div class="flex items-center gap-2">
                            <ConfidencePill :value="item.confidence" />
                            <div class="w-2 h-2 rounded-full bg-emerald-500"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Empty state -->
            <div v-if="!scanned" class="px-4 pb-4">
                <div class="bg-card border border-border rounded-sm p-4 flex flex-col items-center gap-2 text-center">
                    <ScanLine :size="20" class="text-muted-foreground" />
                    <p class="text-xs text-muted-foreground">
                        Scannez une étiquette pour afficher les données extraites selon le template configuré.
                    </p>
                </div>
            </div>
        </div>

        <!-- Send button -->
        <div class="bg-card border-t border-border px-4 py-3">
            <template v-if="sent">
                <div class="flex items-center justify-center gap-2 bg-emerald-600 text-white py-3 rounded-sm">
                    <CheckCircle2Icon :size="16" /><span class="font-semibold text-sm"
                        >Données envoyées avec succès</span
                    >
                </div>
            </template>
            <button
                v-else
                @click="sent = true"
                :disabled="!scanned"
                class="w-full flex items-center justify-center gap-2 bg-primary text-primary-foreground font-semibold text-sm py-3 rounded-sm disabled:opacity-30 transition-opacity"
            >
                <SendIcon :size="15" /> Envoyer
            </button>
        </div>
    </div>
</template>

<style scoped>
@keyframes scan-line {
    0% {
        top: 10%;
    }
    50% {
        top: 85%;
    }
    100% {
        top: 10%;
    }
}
.scan-line {
    animation: scan-line 1.4s ease-in-out infinite;
}
</style>
