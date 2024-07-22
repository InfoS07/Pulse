import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:pulse/core/theme/app_pallete.dart';
import 'package:pulse/features/home/presentation/widgets/social_media_post_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pulse/features/home/presentation/bloc/home_bloc.dart';
import 'package:pulse/core/common/entities/social_media_post.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: CalendarView(),
    );
  }
}

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<SocialMediaPost?>> events = {};
  late final ValueNotifier<List<SocialMediaPost?>> _selectedPosts;

  String? userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AppUserCubit>().state;
    if (authState is AppUserLoggedIn) {
      userId = authState.user.uid;
    }
    _selectedDay = _focusedDay;
    _selectedPosts = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  List<SocialMediaPost?> _getEventsForDay(DateTime day) {
    List<SocialMediaPost?> returnEvents = [];
    events.forEach((key, value) {
      if (isSameDay(key, day)) {
        returnEvents = value;
      }
    });
    return returnEvents;
  }

  void _updateEvents(List<SocialMediaPost?> posts) {
    final Map<DateTime, List<SocialMediaPost?>> newEvents = {};
    for (var post in posts) {
      if (post != null) {
        final postDate =
            DateTime(post.startAt.year, post.startAt.month, post.startAt.day);
        if (newEvents[postDate] == null) {
          newEvents[postDate] = [];
        }
        if (post.user.uid == userId) {
          newEvents[postDate]!.add(post);
        }
      }
    }

    events = newEvents;
    _selectedPosts.value = _getEventsForDay(_selectedDay!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            _updateEvents(state.posts);

            return ValueListenableBuilder(
              valueListenable: _selectedPosts,
              builder: (BuildContext context, dynamic value, Widget? child) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('EEEE d MMMM y', 'fr_FR')
                                  .format(_selectedDay!),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TableCalendar(
                              calendarStyle: const CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: AppPallete.primaryColorFade,
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: AppPallete.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                markerDecoration: BoxDecoration(
                                  color: AppPallete.secondaryColor,
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle:
                                    TextStyle(color: Colors.black),
                                todayTextStyle: TextStyle(color: Colors.white),
                              ),
                              locale: 'fr_FR',
                              firstDay: DateTime.utc(2010, 10, 16),
                              lastDay: DateTime.utc(2030, 3, 14),
                              focusedDay: _focusedDay,
                              calendarFormat: _calendarFormat,
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                  _selectedPosts.value =
                                      _getEventsForDay(_selectedDay!);
                                });
                              },
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              onPageChanged: (focusedDay) {
                                _focusedDay = focusedDay;
                              },
                              eventLoader: _getEventsForDay,
                            ),
                          ],
                        ),
                      ),
                      if (_selectedPosts.value.isNotEmpty)
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _selectedPosts.value.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: SocialMediaPostWidget(
                                post: _selectedPosts.value[index]!,
                                onTap: () {
                                  context.push('/home/details/$index',
                                      extra: _selectedPosts.value[index]!);
                                },
                              ),
                            );
                          },
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Aucun entraînement',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          } else if (state is HomeError) {
            return Center(child: Text('Erreur : ${state.message}'));
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/cloud.png'),
                    width: 150,
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60.0),
                    child: Text(
                      'Vous n\'avez aucune aucun entraînement pour le moment.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
