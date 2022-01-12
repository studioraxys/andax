import 'package:andax/models/story.dart';
import 'package:andax/screens/story_screen.dart';
import 'package:andax/store.dart';
import 'package:andax/widgets/loading_dialog.dart';
import 'package:andax/widgets/rounded_back_button.dart';
import 'package:andax/widgets/paging_list.dart';
import 'package:andax/widgets/story_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

typedef LikeItem = MapEntry<DocumentSnapshot, StoryInfo>;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RoundedBackButton(),
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              if (user == null) {
                await showLoadingDialog(context, signIn());
              } else {
                await FirebaseAuth.instance.signOut();
              }
            },
            icon: Icon(
              user == null ? Icons.login_rounded : Icons.logout_outlined,
            ),
            tooltip: 'Log out',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        children: [
          if (user == null)
            const Center(
              child: Text(
                'No account. Please, sign in above.',
              ),
            )
          else ...[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
              ),
              title: Text(user!.displayName ?? '[no name]'),
              subtitle: Text(user!.email ?? '[no email]'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.favorite_rounded),
              title: const Text('Liked stories'),
              trailing: Chip(
                label: Text(
                  12.toString(),
                ),
              ),
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      leading: const RoundedBackButton(),
                      title: const Text('Liked Stories'),
                    ),
                    body: PagingList<LikeItem>(
                      onRequest: getStories,
                      builder: (context, item, index) {
                        return StoryTile(
                          item.value,
                          onTap: () => Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoryScreen(item.value),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // StoryList(stories)
          ]
        ],
      ),
    );
  }

  Future<List<LikeItem>> getStories(int page, LikeItem? last) async {
    var query = FirebaseFirestore.instance
        .collection('users/${user!.uid}/likes')
        .limit(20);
    if (last != null) query = query.startAfterDocument(last.key);

    final likes = await query.get().then((r) => r.docs);
    print(likes.first.data());
    final stories = await algolia.instance
        .index('stories')
        .query('')
        .filters(
          likes
              .map((l) => l.data()['translationID'] as String)
              .map((t) => 'translation:$t')
              .join(' OR '),
        )
        .getObjects()
        .then(
          (s) => s.hits.map((h) => StoryInfo.fromAlgoliaHit(h)),
        )
        .then((ss) => ({for (final s in ss) s.translationID: s}));

    return [
      for (final like in likes)
        MapEntry(
          like,
          stories[like.data()['translationID'] as String]!,
        )
    ];
  }

  Future<void> signIn() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    final user = await GoogleSignIn().signIn();
    if (user != null) {
      final auth = await user.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(cred);
    }
  }
}
