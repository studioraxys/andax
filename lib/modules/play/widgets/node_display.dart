import 'package:andax/models/node.dart';
import 'package:andax/modules/play/utils/animator.dart';
import 'package:andax/modules/play/widgets/actor_chip.dart';
import 'package:andax/modules/play/widgets/audio_slider.dart';
import 'package:andax/modules/play/widgets/message_card.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/play.dart';
import '../utils/audio_controller.dart';

class NodeDisplay extends StatelessWidget {
  const NodeDisplay({
    Key? key,
    required this.node,
    required this.previousNode,
  }) : super(key: key);

  final Node node;
  final Node? previousNode;

  @override
  Widget build(BuildContext context) {
    final play = context.watch<PlayScreenState>();
    final actor = play.actors[node.actorId];
    final text = play.tr.node(node, allowEmpty: true);
    final aUrl = play.tr.audio(node);
    final audio = play.audio;
    if (text.isEmpty) return const SizedBox();

    final thread = actor?.id == previousNode?.actorId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (thread)
          const SizedBox(height: 2)
        else if (actor == null)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '• • •',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          const SizedBox(height: 16),
        if (node.image != null)
          Image.network(
            node.image!.url,
            height: node.image!.height,
            fit: node.image!.fit,
            alignment: node.image!.alignment,
          ),
        if (actor != null && !thread) ActorChip(actor),
        if (text.isNotEmpty)
          MessageCard(
            text,
            onTap: aUrl.isEmpty ? null : () => audio.play(aUrl, node.id),
          ),
        ChangeNotifierProvider.value(
          value: audio,
          builder: (context, _) {
            return AudioSlider(node);
          },
        ),
      ],
    );
  }
}
