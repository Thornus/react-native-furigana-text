import { ParsedFurigana, TextSegment } from './ReactNativeFuriganaText.types';

export function parseFuriganaText(text: string): ParsedFurigana {
  const furiganaMap: { [kanji: string]: string } = {};
  const baseText = text.replace(
    /([一-龯々]+)\[([^\]]+)\]/g,
    (_match, kanji, reading) => {
      furiganaMap[kanji] = reading;
      return kanji;
    }
  );

  return {
    baseText,
    furiganaMap,
  };
}

export function extractTextSegments(text: string): TextSegment[] {
  const segments: TextSegment[] = [];
  const regex = /([一-龯々]+)(\[([^\]]+)\])?/g;
  let match;

  while ((match = regex.exec(text)) !== null) {
    const [, kanji, , furigana] = match;

    if (furigana) {
      segments.push({
        type: 'kanji',
        value: kanji,
        furigana,
      });
    } else {
      segments.push({
        type: 'text',
        value: kanji,
      });
    }
  }

  return segments;
}