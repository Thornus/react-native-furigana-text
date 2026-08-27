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
  selectable: boolean;
  onLayout?: (event: any) => void;
}

const ReactNativeFuriganaText =
  requireNativeViewManager<NativeFuriganaTextProps>('ReactNativeFuriganaText');

export function FuriganaText({
  text,
  style,
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
      style={[{ alignSelf: 'stretch' }, measuredHeight !== undefined && { height: measuredHeight }, style]}
      text={baseText}
      furigana={furiganaMap}
      fontSize={fontSize}
      color={color}
      furiganaFontSize={calculatedFuriganaSize}
      furiganaColor={furiganaColor}
      selectable={selectable}
      onLayout={onLayout}
    />
  );

  const renderWeb = () => (
    <View style={[styles.container, style]}>
      <Text style={[styles.text, { fontSize, color }]}>
        {baseText.split(/([一-龯々])/g).map((segment, index) => {
          if (furiganaMap[segment]) {
            return (
              <Text key={index} style={styles.kanjiContainer}>
                <Text style={styles.furigana}>{furiganaMap[segment]}</Text>
                <Text>{segment}</Text>
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