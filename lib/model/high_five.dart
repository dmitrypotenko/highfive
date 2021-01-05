import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contentful/contentful.dart';
import 'package:flutter_contentful/models/system_fields.dart';
import 'package:json_annotation/json_annotation.dart';

part 'high_five.g.dart';

class HighFive {
  final String name;
  final String nameFrom;
  final String imageUrl;
  final int id;
  final int color;

  HighFive(this.name, this.imageUrl, this.id, this.nameFrom, this.color);

  CachedNetworkImage getNetworkCachedImage() {
    return CachedNetworkImage(
      placeholder: (context, url) => CircularProgressIndicator(),
      imageUrl: imageUrl,
    );
  }
}

@JsonSerializable()
class HighFiveContentful extends Entry<HighFiveContentfulFields> {
  HighFiveContentful({
    SystemFields sys,
    HighFiveContentfulFields fields,
  }) : super(sys: sys, fields: fields);

  static HighFiveContentful fromJson(Map<String, dynamic> json) => _$HighFiveContentfulFromJson(json);

  Map<String, dynamic> toJson() => _$HighFiveContentfulToJson(this);
}

@JsonSerializable()
class HighFiveContentfulFields extends Equatable {
  HighFiveContentfulFields({
    this.name,
    this.id,
    this.nameFrom,
    this.imageUrl,
    this.color
  });

  final String name;
  final int id;
  final String nameFrom;
  final Asset imageUrl;
  final int color;

  @override
  List<Object> get props => [name, id, nameFrom, imageUrl, color];

  static HighFiveContentfulFields fromJson(Map<String, dynamic> json) => _$HighFiveContentfulFieldsFromJson(json);

  Map<String, dynamic> toJson() => _$HighFiveContentfulFieldsToJson(this);
}

class HighFiveContentfulRepository {
  final Client contentful = Client('4vb93gzyehi7', '05Kp7MY8qJLLPt9NdvV_C5Oo32UFewVwhJSFXxTxmtE');

  Future<List<HighFive>> getHighFives() async {
    var entryCollection = await contentful.getEntries({'order': 'fields.id', 'content_type': 'hIghfive'}, HighFiveContentful.fromJson);
    return entryCollection.items
        .map((highfiveContenful) => new HighFive(highfiveContenful.fields.name,
            'https:' + highfiveContenful.fields.imageUrl.fields.file.url, highfiveContenful.fields.id, highfiveContenful.fields.nameFrom,
        highfiveContenful.fields.color))
        .toList(growable: true);
  }
}
