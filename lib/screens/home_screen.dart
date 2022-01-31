import 'package:andax/editor/story_editor_screen.dart';
import 'package:andax/store.dart';
import 'package:andax/utils.dart';
import 'package:andax/widgets/loading_builder.dart';
import 'package:andax/widgets/paging_list.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:andax/widgets/story_card.dart';
import 'package:andax/widgets/story_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/story.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<StoryInfo>> getStories(
    String index, {
    int? page,
    int? hitsPerPage,
  }) async {
    var query = algolia.instance.index('stories').query('');
    if (page != null) query = query.setPage(page);
    if (hitsPerPage != null) query = query.setHitsPerPage(hitsPerPage);
    final hits = await query.getObjects().then((s) => s.hits);
    return hits.map((h) => StoryInfo.fromAlgoliaHit(h)).toList();
  }

  // IconButton(
  //   onPressed: () async {
  //     await Navigator.push<void>(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const ProfileScreen(),
  //       ),
  //     );
  //     setState(() {});
  //   },
  //   icon: const Icon(Icons.person_rounded),
  // ),

  Widget buildCategory(IconData icon, String title, String index) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          horizontalTitleGap: 0,
          title: Text(
            capitalize(title),
            style: Theme.of(context).textTheme.headline6,
          ),
          trailing: const Icon(Icons.arrow_forward_rounded),
          onTap: () => expandCategory(title, index),
        ),
        LoadingBuilder(
          future: getStories(index, hitsPerPage: 10),
          builder: (context, stories) {
            // TODO why is the type not inferenced?
            final s = stories as List<StoryInfo>;
            return SizedBox(
              height: 128,
              child: ListView.builder(
                itemExtent: 200,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: s.length,
                itemBuilder: (context, index) {
                  final story = s[index];
                  return StoryCard(
                    story,
                    onTap: () {},
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> expandCategory(String title, String index) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              leading: const RoundedBackButton(),
              title: Text(capitalize(title)),
            ),
            body: PagingList<StoryInfo>(
              onRequest: (p, l) => getStories(index, page: p),
              maxPages: 5,
              builder: (context, info, index) {
                return StoryTile(
                  info,
                  onTap: () {},
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
      ),
      floatingActionButton: FirebaseAuth.instance.currentUser == null
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoryEditorScreen(),
                ),
              ),
              child: const Icon(Icons.edit_rounded),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildCategory(
              Icons.whatshot_rounded,
              'trending now',
              'stories_trending',
            ),
            buildCategory(
              Icons.thumb_up_rounded,
              'most popular',
              'stories',
            ),
            ListTile(
              leading: const Icon(Icons.explore_rounded),
              horizontalTitleGap: 0,
              title: Text(
                capitalize('explore new'),
                style: Theme.of(context).textTheme.headline6,
              ),
              trailing: const Icon(Icons.search_rounded),
              onTap: () {},
            ),
            LoadingBuilder(
              future: algolia
                  .index('stories_explore')
                  .query('')
                  .setHitsPerPage(0)
                  .getObjects()
                  .then((r) {
                return getStories(
                  'stories_explore',
                  page: r.nbHits ~/ 30,
                  hitsPerPage: 30,
                );
              }),
              builder: (context, stories) {
                return Column(
                  children: [
                    for (var story in stories as List<StoryInfo>)
                      StoryTile(
                        story,
                        onTap: () {},
                      )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
