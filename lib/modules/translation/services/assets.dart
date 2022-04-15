import 'package:andax/models/story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/translation_editor.dart';

Future<List<AssetOverwrite>> getPendingAssets(StoryInfo info, String id) async {
  final q = await FirebaseFirestore.instance
      .collection(
        'stories/${info.storyID}/translations/${info.translationID}/pending',
      )
      .where('target', isEqualTo: id)
      .get();
  return [
    for (final d in q.docs)
      AssetOverwrite(id, d.data()['text'] as String? ?? '')
  ];
}

Future<void> applyAssetChanges(
  StoryInfo info,
  Map<String, AssetOverwrite> changes,
) async {
  final tdoc = FirebaseFirestore.instance.doc(
    'stories/${info.storyID}/translations/${info.translationID}',
  );
  final acol = tdoc.collection('assets');
  final pcol = tdoc.collection('pending');

  for (final c in changes.entries) {
    await acol.doc(c.key).set(<String, String>{'text': c.value.value});
    await pcol.doc(c.value.key).delete();
  }
  await tdoc.update({
    'metaData.lastUpdateAt': FieldValue.serverTimestamp(),
  });
}
