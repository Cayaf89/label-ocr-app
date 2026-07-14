<script setup lang="ts">
import { ref } from "vue";
import EmojiPicker from "vue3-emoji-picker";
import "vue3-emoji-picker/css";

const props = defineProps<{
    modelValue: string;
}>();

const emit = defineEmits<{
    (e: "update:modelValue", value: string): void;
}>();

const isOpen = ref(false);

function onSelectEmoji(emoji: { i: string }) {
    emit("update:modelValue", emoji.i);
}
</script>

<template>
    <div class="relative inline-block" data-emoji-picker>
        <!-- Toggle button -->
        <button
            type="button"
            @click.stop="isOpen = !isOpen"
            class="w-9 h-9 flex items-center justify-center rounded-sm border border-border bg-card hover:border-primary transition-colors text-base select-none cursor-pointer"
        >
            {{ props.modelValue || "😀" }}
        </button>

        <!-- Dropdown -->
        <div
            v-if="isOpen"
            class="absolute top-full left-0 mt-1 z-50 bg-card rounded-sm shadow-lg overflow-hidden w-fit"
        >
            <EmojiPicker :native="true" @select="onSelectEmoji" />
        </div>
    </div>
</template>
