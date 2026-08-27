// Reexport the native module. On web, it will be resolved to ReactNativeFuriganaTextModule.web.ts
// and on native platforms to ReactNativeFuriganaTextModule.ts
export { default } from './ReactNativeFuriganaTextModule';
export * from './ReactNativeFuriganaText.types';
export { FuriganaText } from './ReactNativeFuriganaText';
