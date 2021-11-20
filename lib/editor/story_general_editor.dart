import 'package:andax/editor/story_node_selector.dart';
import 'package:andax/models/translation_asset.dart';
import 'package:andax/widgets/rounded_back_button.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'story_editor_screen.dart';

class StoryGeneralEditor extends StatelessWidget {
  const StoryGeneralEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<StoryEditorState>();
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          leading: RoundedBackButton(),
          title: Text('General'),
          forceElevated: true,
          floating: true,
          snap: true,
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Initial language',
                  ),
                  initialValue: editor.translation.language,
                  onChanged: (s) => editor.update(() {
                    editor.translation.language = s;
                  }),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.title_rounded),
                title: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Story title',
                  ),
                  initialValue:
                      ScenarioTranslation.get(editor.translation)?.title,
                  onChanged: (s) => editor.update(() {
                    ScenarioTranslation.get(editor.translation)?.title = s;
                  }),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description_rounded),
                title: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Story description',
                  ),
                  initialValue:
                      ScenarioTranslation.get(editor.translation)?.description,
                  onChanged: (s) => editor.update(() {
                    ScenarioTranslation.get(editor.translation)?.description =
                        s;
                  }),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.login_rounded),
                title: StoryNodeSelector(
                  editor.story.nodes[editor.story.startNodeId],
                  (node) => editor.update(() {
                    editor.story.startNodeId = node?.id ?? '';
                  }),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
