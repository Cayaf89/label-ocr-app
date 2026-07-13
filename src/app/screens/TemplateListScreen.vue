<script setup lang="ts">
import { Plus, TagIcon, Settings as SettingsIcon, ScanLine, PackageSearch, LayersIcon } from "lucide-vue-next";
import { useRouter } from "vue-router";
import { TEMPLATES } from "../data/constants";

const router = useRouter();

const handleConfigure = (id: number) => {
    router.push(`/templates/${id}/configure`);
};

const handleScan = () => {
    router.push("/scan");
};
</script>

<template>
    <div class="flex flex-col h-full bg-background overflow-hidden">
        <!-- App bar -->
        <div class="bg-[#111218] px-4 pb-4 pt-2">
            <div class="flex items-center justify-between">
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
                        Mes templates
                    </h1>
                </div>
                <button
                    class="flex items-center gap-1.5 bg-primary text-primary-foreground text-xs font-medium px-3 py-1.5 rounded-sm"
                >
                    <Plus :size="12" /> Nouveau
                </button>
            </div>
        </div>
        <!-- Stats strip -->
        <div class="bg-card border-b border-border px-4 py-2.5 flex items-center gap-6">
            <div class="flex items-center gap-1.5">
                <LayersIcon :size="11" class="text-muted-foreground" />
                <span class="text-[10px] text-muted-foreground" :style="{ fontFamily: 'var(--font-mono)' }"
                    ><span class="text-foreground font-medium">{{ TEMPLATES.length }}</span> templates</span
                >
            </div>
            <div class="flex items-center gap-1.5">
                <PackageSearch :size="11" class="text-muted-foreground" />
                <span class="text-[10px] text-muted-foreground" :style="{ fontFamily: 'var(--font-mono)' }"
                    ><span class="text-foreground font-medium">312</span> scans ce mois</span
                >
            </div>
        </div>
        <!-- List -->
        <div class="flex-1 overflow-y-auto" style="scrollbar-width: none">
            <div class="px-4 pt-3 pb-4 flex flex-col gap-2">
                <div
                    v-for="tpl in TEMPLATES"
                    :key="tpl.id"
                    class="bg-card border border-border rounded-sm overflow-hidden"
                >
                    <div class="flex items-center gap-3 px-3 py-3">
                        <div
                            class="w-9 h-9 rounded-sm flex items-center justify-center text-lg shrink-0"
                            :style="{ background: tpl.color }"
                        >
                            {{ tpl.icon }}
                        </div>
                        <div class="flex-1 min-w-0">
                            <p class="text-sm font-semibold text-foreground leading-tight truncate">{{ tpl.name }}</p>
                            <p class="text-[10px] text-muted-foreground leading-tight mt-0.5 truncate">
                                {{ tpl.description }}
                            </p>
                        </div>
                        <span
                            class="text-[9px] font-medium px-1.5 py-0.5 rounded-sm shrink-0"
                            :style="{ background: tpl.color, color: tpl.accent, fontFamily: 'var(--font-mono)' }"
                            >{{ tpl.fieldsCount }} champs</span
                        >
                    </div>
                    <div class="border-t border-border flex items-center">
                        <div class="flex-1 px-3 py-2 flex items-center gap-1.5">
                            <TagIcon :size="9" class="text-muted-foreground shrink-0" />
                            <span
                                class="text-[9px] text-muted-foreground"
                                :style="{ fontFamily: 'var(--font-mono)' }"
                                >{{ tpl.lastUsed }}</span
                            >
                        </div>
                        <div class="flex items-stretch border-l border-border divide-x divide-border">
                            <button
                                @click="handleConfigure(tpl.id)"
                                class="flex items-center gap-1.5 px-4 py-2 text-xs font-medium text-muted-foreground hover:bg-muted/50 transition-colors"
                                title="Configurer le template"
                            >
                                <SettingsIcon :size="13" class="text-foreground" />
                            </button>
                            <button
                                @click="handleScan"
                                class="flex items-center gap-1.5 px-4 py-2 text-xs font-medium transition-colors"
                                :style="{ background: tpl.accent }"
                                title="Scanner avec ce template"
                            >
                                <ScanLine :size="13" class="text-white" />
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Empty state -->
            <div class="px-4 pb-6">
                <button
                    class="w-full border border-dashed border-border rounded-sm flex items-center justify-center gap-2 py-4 text-muted-foreground"
                >
                    <Plus :size="14" />
                    <span class="text-xs font-medium">Créer un nouveau template</span>
                </button>
            </div>
        </div>
    </div>
</template>
