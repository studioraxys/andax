import 'package:enum_to_string/enum_to_string.dart';

import 'translation_asset.dart';

enum ActorType {
  npc,
  player,
}

class Actor {
  String id;
  ActorType type;

  Actor({
    required this.id,
    this.type = ActorType.npc,
  });

  String getName(Map<String, TranslationAsset> translations) =>
      (translations[id] as ActorTranslation?)?.name ?? '';

  Actor.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          type: EnumToString.fromString(
                ActorType.values,
                json['type'],
              ) ??
              ActorType.npc,
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': EnumToString.convertToString(type),
      };
}
