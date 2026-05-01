import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../models/postman_collection.dart';

class ChatSeedLoaderService {
  static const String _chatCollectionAsset =
      'assets/Bonoos Chat API (REST + WebSocket).postman_collection.json';
  static const String _calendarCollectionAsset =
      'assets/Bonoos Calendar API.postman_collection.json';

  Future<PostmanCollection> loadChatCollection() async {
    final raw = await rootBundle.loadString(_chatCollectionAsset);
    return PostmanCollection.fromRawJson(raw);
  }

  Future<PostmanCollection> loadCalendarCollection() async {
    final raw = await rootBundle.loadString(_calendarCollectionAsset);
    return PostmanCollection.fromRawJson(raw);
  }

  Future<List<ChatThread>> loadSeedThreads() async {
    final collection = await loadChatCollection();
    final conversationsResponseBody = _findResponseBody(
      collection: collection,
      folderName: '01 - Client Chat (JWT required)',
      requestName: 'List my conversations',
    );
    final decoded = _safeDecode(conversationsResponseBody);
    final data = (decoded['data'] as List<dynamic>? ?? <dynamic>[]);
    return data
        .map((dynamic e) => ChatThread.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessage>> loadSeedMessages() async {
    final collection = await loadChatCollection();
    final messagesResponseBody = _findResponseBody(
      collection: collection,
      folderName: '01 - Client Chat (JWT required)',
      requestName: 'List messages',
    );
    final decoded = _safeDecode(messagesResponseBody);
    final data = (decoded['data'] as List<dynamic>? ?? <dynamic>[]);
    return data
        .map((dynamic e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> chatEnvironmentVariables(PostmanCollection collection) {
    return <String, dynamic>{
      for (final variable in collection.variables) variable.key: variable.value,
    };
  }

  String _findResponseBody({
    required PostmanCollection collection,
    required String folderName,
    required String requestName,
  }) {
    final folder = collection.items.firstWhere(
      (item) => item.name == folderName,
      orElse: () => const PostmanItem(
        name: '',
        items: <PostmanItem>[],
        responses: <PostmanResponse>[],
      ),
    );
    final requestItem = folder.items.firstWhere(
      (item) => item.name == requestName,
      orElse: () => const PostmanItem(
        name: '',
        items: <PostmanItem>[],
        responses: <PostmanResponse>[],
      ),
    );
    final responseBody = requestItem.responses.isNotEmpty
        ? requestItem.responses.first.body
        : '';
    if (responseBody.trim().startsWith('{')) return responseBody;

    final chatRaw = _extractResponseBodyFromCollection(
      collection: collection,
      requestName: requestName,
    );
    return chatRaw ?? '{"data":[]}';
  }

  String? _extractResponseBodyFromCollection({
    required PostmanCollection collection,
    required String requestName,
  }) {
    final raw =
        _traverseForResponse(requestName: requestName, items: collection.items);
    return raw;
  }

  String? _traverseForResponse({
    required String requestName,
    required List<PostmanItem> items,
  }) {
    for (final item in items) {
      if (item.name == requestName) {
        if (item.responses.isNotEmpty) {
          final body = item.responses.first.body;
          if (body.trim().startsWith('{')) return body;
        }
      }
      final nested =
          _traverseForResponse(requestName: requestName, items: item.items);
      if (nested != null) return nested;
    }
    return null;
  }

  Map<String, dynamic> _safeDecode(String raw) {
    try {
      return (raw.isEmpty
          ? <String, dynamic>{'data': <dynamic>[]}
          : (jsonDecode(raw) as Map<String, dynamic>));
    } catch (_) {
      return <String, dynamic>{'data': <dynamic>[]};
    }
  }
}
