<script setup lang="ts">
import { computed, ref } from "vue";
import { useRouter } from "vue-router";
import { ArrowLeft, Camera, SendIcon, CheckCircle2Icon, ScanLine } from "@lucide/vue";
import ConfidencePill from "../components/ConfidencePill.vue";
import { SCAN_DATA, TEMPLATES } from "../data/constants";
import { saveImage, takeNativePhoto, blobToBase64 } from "../../services/camera";

const router = useRouter();

const scanned = ref(false);
const sent = ref(false);
const scanning = ref(false);
const capturedSrc = ref<string | null>(null); // data URL of the captured image for preview.

// Use the first template's fields as default; fall back to SCAN_DATA when no image yet.
const activeFields = computed(() => (TEMPLATES.length > 0 ? TEMPLATES[0].fields : (SCAN_DATA as any[])));

// Simulated detected values paired with each field so the mapping rows show real text.
const detectedValues: Record<string, string> = {
    "product.name": "LAIT ENTIER BIO",
    "product.ean": "3760123456789",
    "product.sku": "FR-LAIT-001",
    "product.batch": "LOT: A2024-07",
    "product.expiry_date": "DLC: 22/07/2026",
    "product.weight": "1L · 1030g",
    "product.origin": "NORMANDIE, FRANCE",
    "product.manufacturer": "Crèmerie du Plateau",
    "product.category": "Produit laitier",
};

// ---------------------------------------------------------------------------
// Scan action — open native camera via HTML5 <input capture>, get Blob, then base64.
// On Android this opens the device's native camera app directly (no live preview).
// On desktop it falls back to a file picker.
// ---------------------------------------------------------------------------

const handleScan = async () => {
    scanning.value = true;
    capturedSrc.value = null;

    try {
        const blob = await takeNativePhoto();
        if (!blob) return; // user cancelled or timed out

        // Convert Blob to base64 data URL for preview.
        const base64Data = await blobToBase64(blob);
        capturedSrc.value = base64Data;

        // Save the image to disk via Rust backend (base64 without prefix).
        const cleaned = base64Data.replace(/^data:image\/\w+;base64,/, "");
        await saveImage(cleaned);
    } catch {
        console.warn("Failed to capture photo");
    } finally {
        scanning.value = false;
        scanned.value = true;
    }
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

          <!-- Scanned result with captured image preview -->
          <template v-if="scanned && !sent && capturedSrc">
            <img :src="capturedSrc" class="w-full h-full object-cover opacity-85" />
            <div class="absolute inset-0">
              <div
                v-for="(item, i) in activeFields"
                :key="i"
                class="absolute border border-primary bg-primary/15"
                :style="{
                  top: `${(item.y / 320) * 100}%`,
                  left: '10%',
                  width: '45%',
                  height: '8%',
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
              <CheckCircle2Icon :size="9" class="text-emerald-400" /> {{ activeFields.length }} champs reconnus
            </div>
          </template>

          <!-- Scanning / waiting for camera app -->
          <template v-if="scanning">
            <video
              id="camera-video-scanning"
              autoplay
              playsinline
              muted
              class="w-full h-full object-cover opacity-40 blur-sm"
              style="display: none"
            />
            <div class="w-full h-full flex flex-col items-center justify-center gap-3">
              <div class="relative w-32 h-32 border-2 border-white/20 rounded-sm">
                <div class="absolute top-0 left-0 w-4 h-4 border-t-2 border-l-2 border-primary" />
                <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-primary" />
                <div class="absolute bottom-0 left-0 w-3 h-3 border-b-2 border-l-2 border-primary" />
                <div class="absolute bottom-0 right-0 w-3 h-3 border-b-2 border-r-2 border-primary" />
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

          <!-- Empty state (no capture yet) -->
          <template v-if="!scanned && !sent && !capturedSrc">
            <video
              id="camera-video-placeholder"
              autoplay
              playsinline
              muted
              class="w-full h-full object-cover"
              style="display: none"
            />
            <div class="w-full h-full flex flex-col items-center justify-center gap-3">
              <div class="relative w-28 h-28 border border-white/20 rounded-sm">
                <div class="absolute top-0 left-0 w-4 h-4 border-t-2 border-l-2 border-white/50" />
                <div class="absolute top-0 right-0 w-4 h-4 border-t-2 border-r-2 border-white/50" />
                <div class="absolute bottom-0 left-0 w-3 h-3 border-b-2 border-l-2 border-white/50" />
                <div class="absolute bottom-0 right-0 w-3 h-3 border-b-2 border-r-2 border-white/50" />
                <Camera :size="24" class="absolute inset-0 m-auto text-white/30" />
              </div>
              <p class="text-white/50 text-xs" :style="{ fontFamily: 'var(--font-mono)' }">
                Appuyez sur le bouton ci-dessous pour ouvrir la caméra.
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
          @click="scanned = false; capturedSrc = null;"
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
          v-for="(item, i) in activeFields"
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
              detectedValues[item.apiField] || "—"
            }}</span>
            <div class="flex items-center gap-2">
              <ConfidencePill :value="item.confidence" />
              <div class="w-2 h-2 rounded-full bg-emerald-500"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty state -->
      <div v-if="!scanned && !sent" class="px-4 pb-4">
        <div class="bg-card border border-border rounded-sm p-4 flex flex-col items-center gap-2 text-center">
          <ScanLine :size="20" class="text-muted-foreground" />
          <p class="text-xs text-muted-foreground">
            Appuyez sur "Prendre une photo" pour ouvrir la caméra native.
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
  0% { top: 10%; }
  50% { top: 85%; }
  100% { top: 10%; }
}
.scan-line {
  animation: scan-line 1.4s ease-in-out infinite;
}
</style>
