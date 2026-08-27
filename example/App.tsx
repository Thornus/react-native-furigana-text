import { SafeAreaView, ScrollView, StyleSheet, Text, View } from 'react-native';
import { FuriganaText } from 'react-native-furigana-text';

export default function App() {
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.container} contentContainerStyle={styles.content}>
        <Text style={styles.header}>FuriganaText Example</Text>

        <Group name="Basic">
          <FuriganaText text="漢字[かんじ]を読みます。" style={styles.customStyle}/>
        </Group>

        <Group name="Custom font size & color">
          <FuriganaText
            text="日本語[にほんご]の勉強[べんきょう]"
            fontSize={22}
            color="#1f2937"
            furiganaColor="#2563eb"
            style={styles.customStyle}
          />
          <Text>Test Lower Boundary</Text>
        </Group>

        <Group name="Explicit furigana font size">
          <FuriganaText
            text="東京[とうきょう]タワー"
            fontSize={60}
            furiganaFontSize={22}
            furiganaColor="#dc2626"
            style={styles.customStyle}
          />
        </Group>

        <Group name="Custom container style">
          <FuriganaText
            text="美しい景色[けしき]"
            style={styles.customStyle}
            fontSize={22}
            color="#0f172a"
            furiganaColor="#16a34a"
          />
        </Group>

        <Group name="Selectable">
          <FuriganaText
            text="長[なが]い文章[ぶんしょう]を書[か]いてみます。この文章[ぶんしょう]は折[お]り返[かえ]されるはずです。漢字[かんじ]が含[ふく]まれています。"
            selectable
            fontSize={18}
          />
        </Group>
      </ScrollView>
    </SafeAreaView>
  );
}

function Group(props: { name: string; children: React.ReactNode }) {
  return (
    <View style={styles.group}>
      <Text style={styles.groupHeader}>{props.name}</Text>
      {props.children}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#eee' },
  content: { paddingBottom: 40 },
  header: { fontSize: 30, margin: 20 },
  groupHeader: { fontSize: 20, marginBottom: 12 },
  group: { margin: 20, backgroundColor: '#fff', borderRadius: 10, padding: 20 },
  view: { flex: 1, height: 200 },
  customStyle: {  backgroundColor: '#f1f5f9', borderRadius: 8 },
});