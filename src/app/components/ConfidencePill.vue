<script setup lang="ts">
interface Props {
    value: number;
}
const props = defineProps<Props>();
</script>

<template>
    <span
        :class="[
            'text-[9px] px-1.5 py-0.5 rounded font-medium',
            props.value >= 97
                ? 'bg-emerald-100 text-emerald-700'
                : props.value >= 94
                  ? 'bg-amber-100 text-amber-700'
                  : 'bg-red-100 text-red-700',
        ]"
        :style="{ fontFamily: 'var(--font-mono)' }"
        >{{ `${props.value}%` }}</span
    >
</template>
