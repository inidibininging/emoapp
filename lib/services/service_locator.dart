import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:emoapp/model/discussion/discussion.dart';
import 'package:emoapp/model/discussion/discussion_message.dart';
import 'package:emoapp/model/entity_base_type.dart';
import 'package:emoapp/model/journal_entry_extended.dart';
import 'package:emoapp/model/journal_type.dart';
import 'package:emoapp/model/kanban.dart';
import 'package:emoapp/model/topic.dart';
import 'package:emoapp/model/emotion.dart';
import 'package:emoapp/model/default_emotions.dart';
import 'package:emoapp/model/idea.dart';
import 'package:emoapp/model/visibility_group.dart';
import 'package:emoapp/services/journal_entry_extended_service.dart';
import 'package:emoapp/services/sdb.dart';
import 'package:emoapp/services/flat_file_service.dart';
import 'package:emoapp/services/emotion_service.dart';
import 'package:emoapp/services/idea_service.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:emoapp/model/entity_base.dart';
import 'package:emoapp/model/profile.dart';

/// Does all the GetIt registration
class ServiceLocatorRegistrar {
  ///physical path to hive db
  // static String hivePathKey = 'hivePathKey';

  // static String journalEntryKey = 'entryColor';
  // static String journalPerspectiveKey = 'perspectiveColor';
  // static String journalRetrospectiveKey = 'retrospectiveColor';

  /// registers basic stuff, like hive
  /// and all of its entity services
  Future<void> register() async {
    var hivePath = 'emo';
    try {
      // Skip path_provider on web platform
      if (!kIsWeb && Platform.isAndroid) {
        await [
          Permission.storage,
        ].request();
      }
      // Only try to get documents directory on non-web platforms
      if (!kIsWeb) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final appDocPath = appDocDir.path;
        hivePath = appDocPath;
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {}
    // await Hive.initFlutter(hivePath);

    // GetIt.instance.registerSingleton(hivePath, instanceName: hivePathKey);

    // GetIt.instance.registerSingleton<JournalEntryExtendedService>(
    //   JournalEntryExtendedService(),
    // );

    await registerProfile();
    await registerJournalEntryExtended();
    await registerDiscussion();
    await registerTopic();
    await registerEmotion();
    await registerIdea();
    await registerVisibilityGroup();
    await registerKanban();
  }

  /// used for registering entity instantiation with or without parameters
  /// properties are also included
  void registerEntityInvocatorWithParams<T extends EntityBase, TPropertyTuple>(
    T Function(TPropertyTuple params) instantiationMethod,
    String instanceName,
  ) {
    GetIt.instance.registerFactoryParam<T, TPropertyTuple, void>(
      instanceName: instanceName,
      (param1, _) => instantiationMethod(param1),
    );
  }

  /// used for instantiating entities
  T getSpecificEntityInstance<T extends EntityBase, TProperties>(
    String instanceName,
    TProperties param,
  ) =>
      GetIt.instance.get<T>(instanceName: instanceName, param1: param);

  Future<void> registerProfile() async {
    (bool, Exception?) profileValidation(Profile p) => p.name == 'debug'
        ? (true, null)
        : (false, Exception('profile name is not there'));

    registerEntityInvocatorWithParams<
        Profile,
        (
          String name,
          String imageKey,
          String description,
          String currentDiscussionId
        )>(
      ((
                String name,
                String imageKey,
                String description,
                String currentDiscussionId
              ) params) =>
          Profile(
        id: const Uuid().v4(),
        name: params.$1,
        imageKey: params.$2,
        description: params.$3,
        currentDiscussionId: params.$4,
      ),
      'profile-box',
    );
    GetIt.instance.registerFactoryParam<Profile, Map<String, dynamic>, void>(
        (json, _) => Profile.fromJson(json),
        instanceName: "${Profile}Json");

    final profile =
        GetIt.instance.registerSingleton<FlatFileEntityService<Profile>>(
      FlatFileEntityService<Profile>(profileValidation, Sdb<Profile>()),
    );

    final profileBox = await profile.where((p) => p.name == 'debug');
    if (profileBox.isEmpty) {
      final debugProfile = await profile.create(
        getSpecificEntityInstance<
            Profile,
            (
              String name,
              String imageKey,
              String description,
              String curentDiscussionId
            )>(
          'profile-box',
          ('debug', 'somerandomshit', 'This is a debug profile', ''),
        ),
        profileValidation,
      );
    }
  }

  Future<void> registerJournalEntryExtended() async {
    // ('', 5, [], JournalType.entry.index)
    (bool, Exception?) journalValidation(JournalEntryExtended d) =>
        d.text.isNotEmpty
            ? (true, null)
            : (false, Exception('discussion name is not there'));

    GetIt.instance.registerSingleton(JournalEntryExtendedService(
        journalValidation, Sdb<JournalEntryExtended>()));

    final debugProfile = await GetIt.instance
        .get<FlatFileEntityService<Profile>>()
        .where((p) => p.name == 'debug')
        .then((p) => p.firstOrNull);

    registerEntityInvocatorWithParams(
      // ignore: prefer_expression_function_bodies
      ((String text, int emotionalLevel) params) {
        return JournalEntryExtended(
            id: const Uuid().v4(),
            text: params.$1,
            timeStamp: DateTime.now(),
            emotionalLevel: params.$2,
            type: JournalType.entry.value,
            discussionId: debugProfile?.currentDiscussionId ?? '');
      },
      JournalType.entry.name,
    );

    GetIt.instance
        .registerFactoryParam<JournalEntryExtended, Map<String, dynamic>, void>(
            (json, _) => JournalEntryExtended.fromJson(json),
            instanceName: "${JournalEntryExtended}Json");
  }

  Future<void> registerDiscussion() async {
    (bool, Exception?) discussionValidation(Discussion d) => d.name.isNotEmpty
        ? (true, null)
        : (false, Exception('discussion name is not there'));

    registerEntityInvocatorWithParams<Discussion,
        (String name, String imageKey, String description)>(
      ((String name, String imageKey, String description) params) => Discussion(
        id: const Uuid().v4(),
        name: params.$1,
        imageKey: params.$2,
        description: params.$3,
        children1: <EntityBaseType>[],
      ),
      'discussion-box',
    );

    final discussion =
        GetIt.instance.registerSingleton<FlatFileEntityService<Discussion>>(
      FlatFileEntityService<Discussion>(
          discussionValidation, Sdb<Discussion>()),
    );

    final debugDiscussion = await discussion.create(
      getSpecificEntityInstance<Discussion,
          (String name, String imageKey, String description)>(
        'discussion-box',
        ('debug', 'somerandomshit', 'This is a debug discussion'),
      ),
      discussionValidation,
    );

    GetIt.instance.registerFactoryParam<Discussion, Map<String, dynamic>, void>(
        (json, _) => Discussion.fromJson(json),
        instanceName: "${Discussion}Json");

    (bool, Exception?) discussionMessageValidation(DiscussionMessage d) =>
        d.content.isNotEmpty
            ? (true, null)
            : (false, Exception('discussion message content is not there'));

    final discussionMessages = GetIt.instance
        .registerSingleton<FlatFileEntityService<DiscussionMessage>>(
            FlatFileEntityService<DiscussionMessage>(
                discussionMessageValidation, Sdb<DiscussionMessage>()));

    GetIt.instance
        .registerFactoryParam<DiscussionMessage, Map<String, dynamic>, void>(
            (json, _) => DiscussionMessage.fromJson(json),
            instanceName: "${DiscussionMessage}Json");

    print(debugDiscussion);
  }

  Future<void> registerTopic() async {
    (bool, Exception?) topicValidation(Topic t) => t.title.isNotEmpty
        ? (true, null)
        : (false, Exception('topic title is not there'));

    registerEntityInvocatorWithParams<Topic,
        (String title, String description)>(
      ((String title, String description) params) => Topic(
        id: const Uuid().v4(),
        title: params.$1,
        description: params.$2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      'topic-box',
    );

    final topic =
        GetIt.instance.registerSingleton<FlatFileEntityService<Topic>>(
      FlatFileEntityService<Topic>(topicValidation, Sdb<Topic>()),
    );

    GetIt.instance.registerFactoryParam<Topic, Map<String, dynamic>, void>(
        (json, _) => Topic.fromJson(json),
        instanceName: "${Topic}Json");

    // Create default "General" topic if no topics exist
    final existingTopics = await topic.where((t) => true);
    if (existingTopics.isEmpty) {
      final generalTopic = Topic(
        id: const Uuid().v4(),
        title: 'General',
        description: 'Default general topic for journal entries',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await topic.create(generalTopic, topicValidation);
    }
  }

  Future<void> registerEmotion() async {
    (bool, Exception?) emotionValidation(Emotion e) => e.name.isNotEmpty
        ? (true, null)
        : (false, Exception('emotion name is not there'));

    final emotion =
        GetIt.instance.registerSingleton<FlatFileEntityService<Emotion>>(
      EmotionService(emotionValidation, Sdb<Emotion>()),
    );

    GetIt.instance.registerFactoryParam<Emotion, Map<String, dynamic>, void>(
        (json, _) => Emotion.fromJson(json),
        instanceName: "${Emotion}Json");

    // Register default emotions if not already present
    final existingEmotions = await emotion.where((e) => true);
    if (existingEmotions.isEmpty) {
      for (final defaultEmotion in DefaultEmotions.getAllEmotions()) {
        await emotion.create(defaultEmotion, emotionValidation);
      }
    }
  }
  //   registerEntityInvocatorWithParams(
  //     // ignore: prefer_expression_function_bodies
  //     ((String text, int emotionalLevel) params) {
  //       return JournalEntryExtended(
  //         id: const Uuid().v4(),
  //         text: params.$1,
  //         hashtags: [],
  //         timeStamp: DateTime.now(),
  //         emotionalLevel: params.$2,
  //         type: JournalType.entry.value,
  //       );
  //     },
  //     JournalType.entry.name,
  //   );

  //   registerEntityInvocatorWithParams(
  //     // ignore: prefer_expression_function_bodies
  //     ((String text, int emotionalLevel) params) {
  //       return JournalEntryExtended(
  //         id: const Uuid().v4(),
  //         text: params.$1,
  //         hashtags: [],
  //         timeStamp: DateTime.now(),
  //         emotionalLevel: params.$2,
  //         type: JournalType.perspective.value,
  //       );
  //     },
  //     JournalType.perspective.name,
  //   );

  //   registerEntityInvocatorWithParams(
  //     // ignore: prefer_expression_function_bodies
  //     ((String text, int emotionalLevel) params) {
  //       return JournalEntryExtended(
  //         id: const Uuid().v4(),
  //         text: params.$1,
  //         hashtags: [],
  //         timeStamp: DateTime.now(),
  //         emotionalLevel: params.$2,
  //         type: JournalType.retrospective.value,
  //       );
  //     },
  //     JournalType.retrospective.name,
  //   );

  //   // GetIt.instance.registerSingleton<JournalEntryExtendedService>(
  //   // JournalEntryExtendedService());
  // }

  Future<void> registerVisibilityGroup() async {
    (bool, Exception?) visibilityGroupValidation(VisibilityGroup vg) =>
        vg.name.isNotEmpty
            ? (true, null)
            : (false, Exception('visibility group name is not there'));

    registerEntityInvocatorWithParams<VisibilityGroup, (String name, String description)>(
      ((String name, String description) params) => VisibilityGroup(
        id: const Uuid().v4(),
        name: params.$1,
        description: params.$2,
      ),
      'visibility-group-box',
    );

    final visibilityGroup =
        GetIt.instance.registerSingleton<FlatFileEntityService<VisibilityGroup>>(
      FlatFileEntityService<VisibilityGroup>(
          visibilityGroupValidation, Sdb<VisibilityGroup>()),
    );

    GetIt.instance
        .registerFactoryParam<VisibilityGroup, Map<String, dynamic>, void>(
            (json, _) => VisibilityGroup.fromJson(json),
            instanceName: "${VisibilityGroup}Json");

    // Create default "Personal" visibility group if none exist
    final existingGroups = await visibilityGroup.where((vg) => true);
    if (existingGroups.isEmpty) {
      final personalGroup = VisibilityGroup(
        id: const Uuid().v4(),
        name: 'Personal',
        description: 'Personal visibility group for private ideas',
      );
      await visibilityGroup.create(personalGroup, visibilityGroupValidation);
    }
  }

  Future<void> registerIdea() async {
    (bool, Exception?) ideaValidation(Idea i) => i.title.isNotEmpty
        ? (true, null)
        : (false, Exception('idea title is not there'));

    registerEntityInvocatorWithParams<Idea,
        (String title, String content, double x, double y)>(
      ((String title, String content, double x, double y) params) => Idea.create(
        title: params.$1,
        content: params.$2,
        positionX: params.$3,
        positionY: params.$4,
      ),
      'idea-box',
    );

    final idea = GetIt.instance.registerSingleton<IdeaService>(
      IdeaService(ideaValidation, Sdb<Idea>()),
    );

    GetIt.instance.registerFactoryParam<Idea, Map<String, dynamic>, void>(
        (json, _) => Idea.fromJson(json),
        instanceName: "${Idea}Json");
  }

  Future<void> registerKanban() async {
    registerEntityInvocatorWithParams<Kanban,
        (String name, String topicId)>(
      ((String name, String topicId) params) => Kanban.create(
        name: params.$1,
        topicId: params.$2,
      ),
      'kanban-box',
    );

    GetIt.instance.registerFactoryParam<Kanban, Map<String, dynamic>, void>(
        (json, _) => Kanban.fromJson(json),
        instanceName: "${Kanban}Json");
  }
}

