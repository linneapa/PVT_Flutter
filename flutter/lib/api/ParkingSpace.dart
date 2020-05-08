// To parse this JSON data, do
//
//     final parkingSpace = parkingSpaceFromJson(jsonString);

import 'dart:convert';

Parkering parkingSpaceFromJson(String str) =>
    Parkering.fromJson(json.decode(str));

String parkingSpaceToJson(Parkering data) => json.encode(data.toJson());

class Parkering {
  String type;
  int totalFeatures;
  List<Feature> features;
  Crs crs;

  Parkering({
    this.type,
    this.totalFeatures,
    this.features,
    this.crs,
  });

  factory Parkering.fromJson(Map<String, dynamic> json) => Parkering(
        type: json["type"],
        totalFeatures: json["totalFeatures"],
        features: List<Feature>.from(
            json["features"].map((x) => Feature.fromJson(x))),
        crs: Crs.fromJson(json["crs"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "totalFeatures": totalFeatures,
        "features": List<dynamic>.from(features.map((x) => x.toJson())),
        "crs": crs.toJson(),
      };
}

class Crs {
  String type;
  CrsProperties properties;

  Crs({
    this.type,
    this.properties,
  });

  factory Crs.fromJson(Map<String, dynamic> json) => Crs(
        type: json["type"],
        properties: CrsProperties.fromJson(json["properties"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "properties": properties.toJson(),
      };
}

class CrsProperties {
  String name;

  CrsProperties({
    this.name,
  });

  factory CrsProperties.fromJson(Map<String, dynamic> json) => CrsProperties(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class Feature {
  String type;
  String id;
  Geometry geometry;
  String geometryName;
  FeatureProperties properties;

  Feature({
    this.type,
    this.id,
    this.geometry,
    this.geometryName,
    this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json["type"],
        id: json["id"],
        geometry: Geometry.fromJson(json["geometry"]),
        geometryName: json["geometry_name"],
        properties: FeatureProperties.fromJson(json["properties"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "geometry": geometry.toJson(),
        "geometry_name": geometryName,
        "properties": properties.toJson(),
      };
}

class Geometry {
  String type;
  List<List<double>> coordinates;

  Geometry({
    this.type,
    this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"],
        coordinates: List<List<double>>.from(json["coordinates"]
            .map((x) => List<double>.from(x.map((x) => x.toDouble())))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(
            coordinates.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };
}

class FeatureProperties {
  int fid;
  int featureObjectId;
  int featureVersionId;
  int extentNo;
  DateTime validFrom;
  int startTime;
  int endTime;
  String startWeekday;
  int maxHours;
  String citation;
  String streetName;
  String cityDistrict;
  String parkingDistrict;
  String address;
  String vfPlatsTyp;
  String otherInfo;
  String rdtUrl;
  int vfMeter;

  FeatureProperties({
    this.fid,
    this.featureObjectId,
    this.featureVersionId,
    this.extentNo,
    this.validFrom,
    this.startTime,
    this.endTime,
    this.startWeekday,
    this.maxHours,
    this.citation,
    this.streetName,
    this.cityDistrict,
    this.parkingDistrict,
    this.address,
    this.vfPlatsTyp,
    this.otherInfo,
    this.rdtUrl,
    this.vfMeter,
  });

  factory FeatureProperties.fromJson(Map<String, dynamic> json) =>
      FeatureProperties(
        fid: json["FID"],
        featureObjectId: json["FEATURE_OBJECT_ID"],
        featureVersionId: json["FEATURE_VERSION_ID"],
        extentNo: json["EXTENT_NO"],
        validFrom: DateTime.parse(json["VALID_FROM"]),
        startTime: json["START_TIME"],
        endTime: json["END_TIME"],
        startWeekday: json["START_WEEKDAY"],
        maxHours: json["MAX_HOURS"] == null ? null : json["MAX_HOURS"],
        citation: json["CITATION"],
        streetName: json["STREET_NAME"],
        cityDistrict: json["CITY_DISTRICT"],
        parkingDistrict: json["PARKING_DISTRICT"],
        address: json["ADDRESS"],
        vfPlatsTyp: json["VF_PLATS_TYP"],
        otherInfo: json["OTHER_INFO"],
        rdtUrl: json["RDT_URL"],
        vfMeter: json["VF_METER"] == null ? null : json["VF_METER"],
      );

  Map<String, dynamic> toJson() => {
        "FID": fid,
        "FEATURE_OBJECT_ID": featureObjectId,
        "FEATURE_VERSION_ID": featureVersionId,
        "EXTENT_NO": extentNo,
        "VALID_FROM": validFrom.toIso8601String(),
        "START_TIME": startTime,
        "END_TIME": endTime,
        "START_WEEKDAY": startWeekday,
        "MAX_HOURS": maxHours == null ? null : maxHours,
        "CITATION": citation,
        "STREET_NAME": streetName,
        "CITY_DISTRICT": cityDistrict,
        "PARKING_DISTRICT": parkingDistrict,
        "ADDRESS": address,
        "VF_PLATS_TYP": vfPlatsTyp,
        "OTHER_INFO": otherInfo,
        "RDT_URL": rdtUrl,
        "VF_METER": vfMeter == null ? null : vfMeter,
      };
}
