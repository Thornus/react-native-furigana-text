# react-native-furigana-text

Native Japanese furigana rendering for React Native apps using CoreText's ruby annotations on iOS.

## Installation

```sh
npm install react-native-furigana-text
```

## Usage

```tsx
import { FuriganaText } from 'react-native-furigana-text';

<FuriganaText text="漢字[かんじ]を読みます。" />
```

### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `text` | `string` | **required** | Text containing kanji with furigana in format `漢字[かんじ]` |
| `fontSize` | `number` | `16` | Font size for the main text |
| `color` | `string` | `'#000'` | Text color (hex string) |
| `furiganaFontSize` | `number` | `fontSize * 0.5` | Font size for furigana text |
| `furiganaColor` | `string` | `'#666'` | Furigana text color (hex string) |
| `style` | `ViewStyle` | - | Style for the container |
| `numberOfLines` | `number` | - | Maximum number of lines |
| `selectable` | `boolean` | `false` | Enable text selection |

## Development

### Building from source

```sh
npm run prepare
```

This runs TypeScript compilation and outputs to `build/`.

### Running the example app

The example app is in `example/`. After making changes to the native Swift code or TypeScript source, you **must re-publish via yalc** before rebuilding:

```sh
npm run prepare && yalc push
cd example
npx expo run:ios
```

> **Important:** The iOS build compiles Swift from `example/node_modules/react-native-furigana-text/ios/` (the yalc copy), not from the root `ios/` folder. Always run `yalc push` after modifying native files, or your changes won't reach the build.

### CocoaPods encoding workaround

If `pod install` fails with a Ruby `Encoding::CompatibilityError`, run with UTF-8 locale:

```sh
LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install --project-directory=ios
```

## License

MIT