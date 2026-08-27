import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import { requireNativeViewManager } from 'expo-modules-core';

import { FuriganaTextProps } from './ReactNativeFuriganaText.types';
import { parseFuriganaText } from './utils';
import NativeModule from './ReactNativeFuriganaTextModule';

interface NativeFuriganaTextProps {
  style?: any;
  text: string;
  furigana: Record<string, string>;
  fontSize: number;
  color: string;
  furiganaFontSize: number;
  furiganaColor: string;
  fontFamily?: string;
  fontWeight?: string;
  fontStyleValue?: string;
  selectable: boolean;
  onLayout?: (event: any) => void;
}

const ReactNativeFuriganaText =
  requireNativeViewManager<NativeFuriganaTextProps>('ReactNativeFuriganaText');

export function FuriganaText({
  text,
  containerStyle,
  fontStyle,
  fontSize = 16,
  color = '#000000',
  furiganaFontSize,
  furiganaColor = '#666666',
  onPress,
  selectable = false,
}: FuriganaTextProps) {
  const [width, setWidth] = useState(0);

  const { baseText, furiganaMap } = parseFuriganaText(text);
  const calculatedFuriganaSize = furiganaFontSize || fontSize * 0.5;

  const onLayout = useCallback((e: any) => {
    const w = Math.round(e.nativeEvent.layout.width);
    setWidth((prev) => (prev === w ? prev : w));
  }, []);

  const measuredHeight =
    width > 0 && Platform.OS === 'android'
      ? NativeModule.measureHeight(
          baseText,
          furiganaMap,
          width,
          fontSize,
          calculatedFuriganaSize
        )
      : undefined;

  const renderNative = () => (
    <ReactNativeFuriganaText
      style={[{ alignSelf: 'stretch' }, measuredHeight !== undefined && { height: measuredHeight }, containerStyle]}
      text={baseText}
      furigana={furiganaMap}
      fontSize={fontSize}
      color={color}
      furiganaFontSize={calculatedFuriganaSize}
      furiganaColor={furiganaColor}
      fontFamily={fontStyle?.fontFamily as string | undefined}
      fontWeight={fontStyle?.fontWeight as string | undefined}
      fontStyleValue={fontStyle?.fontStyle as string | undefined}
      selectable={selectable}
      onLayout={onLayout}
    />
  );

  const renderWeb = () => (
    <View style={[styles.container, containerStyle]}>
      <Text style={[styles.text, { fontSize, color }, fontStyle]}>
        {baseText.split(/([一-龯々])/g).map((segment, index) => {
          if (furiganaMap[segment]) {
            return (
              <Text key={index} style={[styles.kanjiContainer, fontStyle]}>
                <Text style={[styles.furigana, fontStyle]}>{furiganaMap[segment]}</Text>
                <Text style={fontStyle}>{segment}</Text>
              </Text>
            );
          }
          return segment;
        })}
      </Text>
    </View>
  );

  return Platform.OS === 'web' ? renderWeb() : renderNative();
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    alignItems: 'flex-end',
  },
  text: {
    fontSize: 16,
    lineHeight: 24,
  },
  kanjiContainer: {
    flexDirection: 'column',
    alignItems: 'center',
  },
  furigana: {
    fontSize: 8,
    color: '#666',
    marginBottom: 2,
  },
});