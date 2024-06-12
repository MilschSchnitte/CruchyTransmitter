import 'package:crunchy_transmitter/anime/anime.dart';
import 'package:crunchy_transmitter/weekday.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<Map<Weekday, List<Anime>>> fetchAndGroupAnimeByWeekday() async {
  List<Anime> animeList = await fetchData();
  Map<Weekday, List<Anime>> animeMap = groupAnimeByWeekday(animeList);
  return animeMap;
}

Future<List<Anime>> fetchData() async {
  final response = await http.get(Uri.parse(
      'https://crunchytransmitter.ddns.net/CrunchyTransmitter-1.0-SNAPSHOT/anime'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Anime.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

Map<Weekday, List<Anime>> groupAnimeByWeekday(List<Anime> animeList) {
  Map<Weekday, List<Anime>> animeMap = {};
  for (final anime in animeList) {
    final weekday = WeekdayExtension.getWeekdayName(anime.episode.releaseTime);
    if (!animeMap.containsKey(weekday)) {
      animeMap[weekday] = [];
    }
    animeMap[weekday]!.add(anime);
  }
  return animeMap;
}

Future<void> saveAnimeDataToSharedPreferences(
    Map<Weekday, List<Anime>> animeData, SharedPreferences prefs) async {
  final String jsonString = jsonEncode(animeData.map((key, value) {
    return MapEntry(
        key.toString(), value.map((anime) => anime.toJson()).toList());
  }));
  prefs.setString('animeData', jsonString);
}

Future<void> updateSingleAnimeInSharedPreferences(
    Anime anime, SharedPreferences prefs) async {
// Lade die vorhandenen Daten aus den SharedPreferences
  final String? jsonString = prefs.getString('animeData');

  // Konvertiere den JSON-String zurück in eine Map<Weekday, List<Anime>>
  final Map<String, dynamic> decodedData = jsonDecode(jsonString!);
  final Map<Weekday, List<Anime>> animeData = Map.fromEntries(
    decodedData.entries.map((entry) {
      return MapEntry(
        WeekdayExtension.fromString(entry.key),
        (entry.value as List<dynamic>)
            .map<Anime>((json) => Anime.fromJsonInStorage(json))
            .toList(),
      );
    }),
  );

  final weekday = WeekdayExtension.getWeekdayName(anime.episode.releaseTime);
  final index = animeData[weekday]
      ?.indexWhere((element) => element.animeId == anime.animeId);
  if (index != null && index != -1) {
    animeData[weekday]?[index] = anime;
  }

  // Konvertiere die aktualisierten Daten zurück in einen JSON-String
  final updatedJsonString = jsonEncode(animeData.map((key, value) {
    return MapEntry(
        key.toString(), value.map((anime) => anime.toJson()).toList());
  }));

  // Speichere die aktualisierten Daten in den SharedPreferences
  await prefs.setString('animeData', updatedJsonString);
}