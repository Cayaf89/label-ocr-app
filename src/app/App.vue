<script setup lang="ts">
import { RouterView } from "vue-router";
import Navbar from "./components/Navbar.vue";
</script>

<template>
    <div class="min-h-screen bg-background text-foreground" style="font-family: var(--font-sans)">
        <!-- Top navigation bar -->
        <Navbar />

        <!-- Screen content -->
        <main class="h-[calc(100vh-64px)] overflow-hidden">
            <RouterView />
        </main>
    </div>
</template>
