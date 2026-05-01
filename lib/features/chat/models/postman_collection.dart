import 'dart:convert';

class PostmanCollection {
  const PostmanCollection({
    required this.info,
    required this.items,
    required this.variables,
  });

  final PostmanInfo info;
  final List<PostmanItem> items;
  final List<PostmanVariable> variables;

  factory PostmanCollection.fromJson(Map<String, dynamic> json) {
    return PostmanCollection(
      info: PostmanInfo.fromJson((json['info'] as Map<String, dynamic>?) ?? {}),
      items: ((json['item'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic item) =>
              PostmanItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      variables: ((json['variable'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic variable) =>
              PostmanVariable.fromJson(variable as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'info': info.toJson(),
      'item': items.map((e) => e.toJson()).toList(),
      'variable': variables.map((e) => e.toJson()).toList(),
    };
  }

  factory PostmanCollection.fromRawJson(String source) =>
      PostmanCollection.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

class PostmanInfo {
  const PostmanInfo({
    required this.name,
    required this.description,
  });

  final String name;
  final String description;

  factory PostmanInfo.fromJson(Map<String, dynamic> json) {
    return PostmanInfo(
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'description': description,
      };
}

class PostmanItem {
  const PostmanItem({
    required this.name,
    required this.items,
    required this.responses,
    this.request,
  });

  final String name;
  final List<PostmanItem> items;
  final List<PostmanResponse> responses;
  final PostmanRequest? request;

  factory PostmanItem.fromJson(Map<String, dynamic> json) {
    return PostmanItem(
      name: (json['name'] as String?) ?? '',
      items: ((json['item'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic child) =>
              PostmanItem.fromJson(child as Map<String, dynamic>))
          .toList(),
      responses: ((json['response'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic response) =>
              PostmanResponse.fromJson(response as Map<String, dynamic>))
          .toList(),
      request: json['request'] == null
          ? null
          : PostmanRequest.fromJson(json['request'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'item': items.map((e) => e.toJson()).toList(),
        'response': responses.map((e) => e.toJson()).toList(),
        if (request != null) 'request': request!.toJson(),
      };
}

class PostmanResponse {
  const PostmanResponse({
    required this.name,
    required this.body,
    required this.code,
  });

  final String name;
  final String body;
  final int code;

  factory PostmanResponse.fromJson(Map<String, dynamic> json) {
    return PostmanResponse(
      name: (json['name'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'body': body,
        'code': code,
      };
}

class PostmanRequest {
  const PostmanRequest({
    required this.method,
    required this.url,
    required this.description,
  });

  final String method;
  final String url;
  final String description;

  factory PostmanRequest.fromJson(Map<String, dynamic> json) {
    final urlJson = json['url'];
    String rawUrl = '';
    if (urlJson is Map<String, dynamic>) {
      rawUrl = (urlJson['raw'] as String?) ?? '';
    } else if (urlJson is String) {
      rawUrl = urlJson;
    }

    return PostmanRequest(
      method: (json['method'] as String?) ?? 'GET',
      url: rawUrl,
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'method': method,
        'url': <String, dynamic>{'raw': url},
        'description': description,
      };
}

class PostmanVariable {
  const PostmanVariable({
    required this.key,
    required this.value,
  });

  final String key;
  final String value;

  factory PostmanVariable.fromJson(Map<String, dynamic> json) {
    return PostmanVariable(
      key: (json['key'] as String?) ?? '',
      value: (json['value'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'value': value,
      };
}
