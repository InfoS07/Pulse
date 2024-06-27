import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/widgets/exercise_card.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/features/home/presentation/widgets/filter_button.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';
import 'package:pulse/features/home/presentation/widgets/week_days_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeBloc>(context).add(LoadPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pulse App'),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: 100,
                    child: WeekDaysWidget(),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 18),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FilterButton(
                          text: 'Tout',
                          isSelected: state.filter == 'Tout',
                          onTap: () {
                            BlocProvider.of<HomeBloc>(context)
                                .add(FilterPosts('Tout'));
                          },
                        ),
                        SizedBox(width: 16),
                        FilterButton(
                          text: 'Moi',
                          isSelected: state.filter == 'Moi',
                          onTap: () {
                            BlocProvider.of<HomeBloc>(context)
                                .add(FilterPosts('Moi'));
                          },
                        ),
                        SizedBox(width: 16),
                        FilterButton(
                          text: 'Abonné',
                          isSelected: state.filter == 'Abonné',
                          onTap: () {
                            BlocProvider.of<HomeBloc>(context)
                                .add(FilterPosts('Abonné'));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 8),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: SocialMediaPostWidget(
                          post: state.posts[index],
                          onTap: () {
                            context.go('/home/details/$index',
                                extra: state.posts[
                                    index]); //,extra: state.posts[index]);
                          },
                        ),
                      );
                    },
                    childCount: state.posts.length,
                  ),
                ),
              ],
            );
          } else if (state is HomeError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
