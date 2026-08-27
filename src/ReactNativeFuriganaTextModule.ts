import { NativeModule, requireNativeModule } from 'expo';

declare class ReactNativeFuriganaTextModule extends NativeModule<{}> {
  measureHeight(
    text: string,
    furigana: Record<string, string>,
    width: number,
    fontSize: number,
    furiganaFontSize: number
  ): number;
}

export default requireNativeModule<ReactNativeFuriganaTextModule>('ReactNativeFuriganaText');