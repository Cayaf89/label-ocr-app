import { createRouter, createWebHistory } from "vue-router";
import TemplateListScreen from "../screens/TemplateListScreen.vue";
import TemplateScreen from "../screens/TemplateScreen.vue";
import ScanScreen from "../screens/ScanScreen.vue";

const routes = [
    { path: "/", name: "template-list", component: TemplateListScreen },
    {
        path: "/templates/new",
        name: "template-new",
        component: TemplateScreen,
    },
    { path: "/templates/:id/configure", name: "template-update", component: TemplateScreen },
    { path: "/scan", name: "scan", component: ScanScreen },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

export default router;
