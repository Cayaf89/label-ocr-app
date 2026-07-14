declare module "*.vue" {
    import type { DefineComponent } from "vue";
    const component: DefineComponent<object, object, unknown>;
    export default component;
}

declare module "vue3-emoji-picker/css" {
    // Side-effect CSS import — no runtime types needed.
}
