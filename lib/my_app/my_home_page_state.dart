import 'my_home_page.dart';
import 'dart:convert';

import 'package:crunchy_transmitter/anime/anime.dart';
import 'package:crunchy_transmitter/anime/anime_handler.dart';
import 'package:crunchy_transmitter/fcm.dart';

import 'package:crunchy_transmitter/weekday.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  final String _storageKeyFilterIndex = 'filter';
  final String _storageKeyAnimeData = 'animeData';

  Map<Weekday, List<Anime>>? _animeData;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isLoading = true;
  final Map<int, bool> _isLoadingMap = {};

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        String? url = message.data['url'];
        if (url != null && url.isNotEmpty) {
          await launchUrl(Uri.parse(url));
        } else {
          errorDialog(
              "Aktuell ist der Anime bei Crunchyroll noch nicht angelegt.");
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        String? url = message.data['url'];
        if (url != null && url.isNotEmpty) {
          await launchUrl(Uri.parse(url));
        } else {
          errorDialog(
              "Aktuell ist der Anime bei Crunchyroll noch nicht angelegt.");
        }
      }
    });

    _prefs.then((prefs) async {
      _animeData = await fetchAndGroupAnimeByWeekday();

      Map<Weekday, List<Anime>>? animeOldStorage;

      if (_animeData != null && _animeData!.isNotEmpty) {
        final String? animeDataStringOld =
            prefs.getString(_storageKeyAnimeData);

        if (animeDataStringOld != null) {
          final Map<String, dynamic> jsonMap = jsonDecode(animeDataStringOld);
          animeOldStorage = Map<Weekday, List<Anime>>.from(jsonMap.map(
            (key, value) => MapEntry(
                WeekdayExtension.fromString(key),
                (value as List)
                    .map((e) => Anime.fromJsonInStorage(e))
                    .toList()),
          ));

          _animeData?.forEach((weekday, animeList) {
            if (animeOldStorage?[weekday] != null) {
              for (Anime anime in animeList) {
                Anime existingAnime = animeOldStorage![weekday]!
                    .firstWhere((e) => e.animeId == anime.animeId);
                if (existingAnime != null) {
                  anime.notification = existingAnime.notification;
                }
              }
            }
          });
        }

        _animeData = sortAnimeByWeekdayAndTime(_animeData!);
        saveAnimeDataToSharedPreferences(
            _animeData!, prefs, _storageKeyAnimeData);

        //Filter option on top is save for next app open
        final int? filterIndex = prefs.getInt(_storageKeyFilterIndex);
        if (filterIndex != null) {
          selectedIndex = filterIndex;
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        errorDialog(
            "Es gab einen Fehler beim Laden der Animedaten. Bitte probiere es später erneut.");
      }
    });
  }

  Future<void> _updateFilterIndex(int index, String storageKeyAnimeData) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt(storageKeyAnimeData, index);
  }

  Future<void> _updateAnime(Anime anime) async {
    final SharedPreferences prefs = await _prefs;
    await updateSingleAnimeInSharedPreferences(anime, prefs);

    final String? animeDataString = prefs.getString(_storageKeyAnimeData);
    if (animeDataString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(animeDataString);
      _animeData = Map<Weekday, List<Anime>>.from(jsonMap.map(
        (key, value) => MapEntry(WeekdayExtension.fromString(key),
            (value as List).map((e) => Anime.fromJsonInStorage(e)).toList()),
      ));
    }
    setState(() {
      _animeData = _animeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 33, 33),
        leading: Container(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/ic_launcher.png'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Color.fromARGB(255, 244, 117, 33),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          // IconButton(
          //   icon: const Icon(
          //     Icons.settings,
          //     color: Color.fromARGB(155, 255, 255, 255),
          //   ),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => SettingsPage(
          //                 title: widget.title,
          //               )),
          //     );
          //   },
          // ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _animeData != null
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 30,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedIndex = 0;
                                  _updateFilterIndex(0, _storageKeyFilterIndex);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: selectedIndex == 0
                                      ? Colors.green
                                      : const Color.fromRGBO(97, 97, 97, 1),
                                ),
                              ),
                              child: Text(
                                'Alle',
                                style: TextStyle(
                                  color: selectedIndex == 0
                                      ? Colors.white
                                      : const Color.fromARGB(
                                          255, 168, 168, 168),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 110,
                            height: 30,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  selectedIndex = 1;
                                  _updateFilterIndex(1, _storageKeyFilterIndex);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: selectedIndex == 1
                                      ? Colors.green
                                      : const Color.fromRGBO(97, 97, 97, 1),
                                ),
                              ),
                              child: Text(
                                'Abonnierte',
                                style: TextStyle(
                                  color: selectedIndex == 1
                                      ? Colors.white
                                      : const Color.fromARGB(
                                          255, 168, 168, 168),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._animeData!.entries.map((entry) {
                      return Column(
                        children: [
                          buildSection(entry.key, entry.value),
                          buildGrid(entry.value),
                        ],
                      );
                    }),
                  ],
                )
              : const Center(
                  child: Text(
                    'No data found',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
    );
  }

  Widget buildSection(Weekday title, List<Anime> anime) {
    final filteredAnimeList =
        anime.where((anime) => !(selectedIndex == 1 && !anime.notification));

    if (filteredAnimeList.isEmpty) {
      return const SizedBox(height: 0);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          '${title.toGerman()} ${anime[0].episode.dateOfWeekday.day}. ${_getMonthName(anime[0].episode.dateOfWeekday.month)}',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }

  Widget buildGrid(List<Anime> animeList) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double spacing = screenWidth * 0.04;

    List<Anime> filteredAnimeList = animeList;
    if (selectedIndex == 1) {
      filteredAnimeList =
          animeList.where((anime) => anime.notification).toList();
    }

    return Column(
      children: List.generate((filteredAnimeList.length / 2).ceil(), (index) {
        final startIndex = index * 2;
        final endIndex = startIndex + 2;
        final items = filteredAnimeList.sublist(
            startIndex,
            endIndex < filteredAnimeList.length
                ? endIndex
                : filteredAnimeList.length);

        return Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((anime) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                  child: buildGridItem(anime),
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget buildGridItem(Anime anime) {
    final int releaseHour = anime.episode.releaseTime.hour;
    final String releaseMinute =
        anime.episode.releaseTime.minute.toString().padLeft(2, '0');

    final Map<int, String> germanMonths = {
      1: 'Januar',
      2: 'Februar',
      3: 'März',
      4: 'April',
      5: 'Mai',
      6: 'Juni',
      7: 'Juli',
      8: 'August',
      9: 'September',
      10: 'Oktober',
      11: 'November',
      12: 'Dezember'
    };
    final day = anime.episode.dateOfCorretionDate?.day.toString();
    final monthNumber = anime.episode.dateOfCorretionDate?.month;
    final monthName = germanMonths[monthNumber];

    final String dateOfCorretionDate = '$day. $monthName';

    final double imageHeight = MediaQuery.of(context).size.height * 0.32;
    final double imageWidth = MediaQuery.of(context).size.width * 0.45;

    return GestureDetector(
        onTap: () async {
          setState(() {
            _isLoadingMap[anime.animeId] = true;
          });

          int responseCode = await FCM.changeSubscriptionAnime(anime.animeId);
          if (responseCode == 1) {
            anime.notification = true;
          } else if (responseCode == 0) {
            anime.notification = false;
          } else {
            String errorMessage =
                "Es gab einen Fehler. Versuche es vielleicht in 5 Minuten nochmal. Fehlernachricht: ${FCM.responseMessage}";

            if (FCM.responseMessage.contains("CERTIFICATE_VERIFY_FAILED")) {
              errorMessage =
                  "Es gab einen Fehler beim Senden. Es kann sein das du Zertifikatsprobleme hast.";
            } else if (FCM.responseMessage.contains("No address")) {
              errorMessage =
                  "Es gab einen Fehler beim Senden. Es kann sein das du kein Internet hast.";
            }

            errorDialog(errorMessage);
          }
          _updateAnime(anime);
          setState(() {
            _isLoadingMap[anime.animeId] = false;
          });
        },
        onLongPressStart: (LongPressStartDetails details) {
          _showCustomMenu(details.globalPosition, anime.crunchyrollUrl);
        },
        child: Center(
          child: _isLoadingMap[anime.animeId] != null &&
                  _isLoadingMap[anime.animeId]!
              ? SizedBox(
                  height: imageHeight,
                  width: imageWidth,
                  child: const Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                )
              : SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ColorFiltered(
                        colorFilter: anime.notification
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.saturation,
                              )
                            : const ColorFilter.mode(
                                Colors.grey,
                                BlendMode.saturation,
                              ),
                        child: Image.network(
                          anime.imageUrl,
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  imageWidth, // Definiere hier die maximale Breite
                            ),
                            child: Text(
                              anime.title,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 244, 117, 33),
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (anime.episode.dateOfCorretionDate == null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$releaseHour:$releaseMinute Uhr',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  anime.episode.episode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              'Kommt am: $dateOfCorretionDate',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
        ));
  }

  /// The message on hold ("anschauen")
  void _showCustomMenu(Offset position, String url) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      color: const Color.fromARGB(121, 0, 0, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(0, 33, 149, 243),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (url == "") {
                    errorDialog(
                        "Aktuell ist der Anime bei Crunchyroll noch nicht angelegt.");
                  } else {
                    await launchUrl(Uri.parse(url));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Anschauen',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  void errorDialog(String message) {
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fehler'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
