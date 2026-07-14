<script setup>
import { computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ROUTE_LABELS } from "../data/constants.ts";
import { ArrowLeft, Plus } from "@lucide/vue";

const route = useRoute();
const router = useRouter();

const handleBack = () => router.back();

const currentLabel = computed(() => {
    return ROUTE_LABELS[route.name] || "Label OCR App";
});
</script>
<template>
    <header class="bg-[#111218] px-4 py-3 flex items-center justify-between">
        <div class="flex items-center gap-1.5">
            <button v-if="route.name != 'template-list'" @click="handleBack" class="text-white/60 p-1 -ml-1">
                <ArrowLeft :size="18" />
            </button>

            <div>
                <p
                    class="text-[10px] text-white/50 tracking-widest uppercase"
                    :style="{ fontFamily: 'var(--font-mono)' }"
                >
                    Label Scanner
                </p>
                <h1
                    class="text-white text-sm font-semibold leading-tight mt-0.5"
                    :style="{ fontFamily: 'var(--font-sans)' }"
                >
                    {{ currentLabel }}
                </h1>
            </div>
        </div>

        <RouterLink
            v-if="route.name === 'template-list'"
            :to="{ name: 'template-new' }"
            class="flex items-center gap-1.5 bg-primary text-primary-foreground text-xs font-medium px-3 py-1.5 rounded-sm"
        >
            <Plus :size="12" /> Nouveau
        </RouterLink>
    </header>
</template>
