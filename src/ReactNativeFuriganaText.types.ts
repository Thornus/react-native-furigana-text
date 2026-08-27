import { TextStyle, ViewStyle } from 'react-native';

export interface FuriganaTextProps {
  /** Text containing kanji with furigana in format: 漢字[かんじ] */
  text: string;

  /** Style for the text container */
  containerStyle?: ViewStyle;

  /** Text style applied to both the main text and furigana (e.g. fontFamily, fontWeight, fontStyle) */
  fontStyle?: TextStyle;

  /** Font size for the main text */
  fontSize?: number;

  /** Text color */
  color?: string;

  /** Font size for furigana (default: fontSize * 0.5) */
  furiganaFontSize?: number;

  /** Color for furigana text */
  furiganaColor?: string;

  /** Callback when text is pressed */
  onPress?: () => void;

  /** Enable/disable text selection */
  selectable?: boolean;
}

export interface ParsedFurigana {
  baseText: string;
  furiganaMap: { [kanji: string]: string };
}

export interface TextSegment {
  type: 'text' | 'kanji';
  value: string;
  furigana?: string;
}
