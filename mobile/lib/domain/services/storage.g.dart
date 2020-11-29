// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageUploadResponse _$StorageUploadResponseFromJson(
    Map<String, dynamic> json) {
  return StorageUploadResponse(
    url: json['url'] as String,
    state: _$enumDecodeNullable(_$UploadProgressStateEnumMap, json['state']),
    isInComplete: json['isInComplete'] as bool,
  );
}

Map<String, dynamic> _$StorageUploadResponseToJson(
        StorageUploadResponse instance) =>
    <String, dynamic>{
      'url': instance.url,
      'isInComplete': instance.isInComplete,
      'state': _$UploadProgressStateEnumMap[instance.state],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$UploadProgressStateEnumMap = {
  UploadProgressState.DONE: 'DONE',
  UploadProgressState.FAILED: 'FAILED',
  UploadProgressState.IN_PROGRESS: 'IN_PROGRESS',
  UploadProgressState.PAUSED: 'PAUSED',
};
