<script setup lang="ts">
import { RouterLink, RouterView } from "vue-router";
</script>

<template>
    <div class="min-h-screen bg-background text-foreground" style="font-family: var(--font-sans)">
        <!-- Top navigation bar -->
        <header class="bg-[#111218] px-4 py-3 flex items-center justify-between">
            <div>
                <p
                    class="text-[10px] text-white/50 tracking-widest uppercase"
                    :style="{ fontFamily: 'var(--font-mono)' }"
                >
                    OCR Mapper
                </p>
                <h1
                    class="text-white text-sm font-semibold leading-tight mt-0.5"
                    :style="{ fontFamily: 'var(--font-sans)' }"
                >
                    Label OCR App
                </h1>
            </div>
            <nav class="flex items-center gap-2">
                <RouterLink
                    to="/"
                    class="text-xs font-medium px-3 py-1.5 rounded-sm transition-colors"
                    :class="[
                        $route.name === 'template-list'
                            ? 'bg-primary text-primary-foreground'
                            : 'text-muted-foreground hover:bg-muted/50',
                    ]"
                >
                    Templates
                </RouterLink>
                <RouterLink
                    to="/scan"
                    class="text-xs font-medium px-3 py-1.5 rounded-sm transition-colors"
                    :class="[
                        $route.name === 'scan'
                            ? 'bg-primary text-primary-foreground'
                            : 'text-muted-foreground hover:bg-muted/50',
                    ]"
                >
                    Scanner
                </RouterLink>
            </nav>
        </header>

        <!-- Screen content -->
        <main class="h-[calc(100vh-64px)] overflow-hidden">
            <RouterView />
        </main>
    </div>
</template>
