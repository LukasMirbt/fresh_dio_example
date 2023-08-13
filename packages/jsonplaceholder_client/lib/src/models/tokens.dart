import 'package:json_annotation/json_annotation.dart';

part 'tokens.g.dart';

@JsonSerializable()
class Tokens {
  const Tokens({
    required this.refresh,
    required this.access,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) => _$TokensFromJson(json);

  final String refresh;
  final String access;

  Map<String, dynamic> toJson() => _$TokensToJson(this);

  Tokens copyWith({
    String? refresh,
    String? access,
  }) {
    return Tokens(
      refresh: refresh ?? this.refresh,
      access: access ?? this.access,
    );
  }
}
