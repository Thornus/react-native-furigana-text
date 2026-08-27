import { registerWebModule, NativeModule } from 'expo';

// ReactNativeFuriganaTextModule is not available on the web platform.
class ReactNativeFuriganaTextModule extends NativeModule<{}> {}

export default registerWebModule(ReactNativeFuriganaTextModule, 'ReactNativeFuriganaTextModule');
