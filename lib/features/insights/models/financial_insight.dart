import 'package:equatable/equatable.dart';

/// Represents different types of financial insights
enum InsightType { spending, saving, budgeting, trending }

/// A class representing financial insights with trend data and analysis
class FinancialInsight extends Equatable {
  final String title;
  final String description;
  final List<double> trendData;
  final DateTime date;
  final InsightType type;

  const FinancialInsight({
    required this.title,
    required this.description,
    required this.trendData,
    required this.date,
    required this.type,
  });

  /// Creates a FinancialInsight from JSON data
  factory FinancialInsight.fromJson(Map<String, dynamic> json) {
    return FinancialInsight(
      title: json['title'] as String,
      description: json['description'] as String,
      trendData: List<double>.from(json['trendData']),
      date: DateTime.parse(json['date'] as String),
      type: InsightType.values.firstWhere(
        (e) => e.toString() == 'InsightType.${json['type']}',
      ),
    );
  }

  /// Converts the FinancialInsight to a JSON map
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'trendData': trendData,
    'date': date.toIso8601String(),
    'type': type.toString().split('.').last,
  };

  /// Returns the average value from trend data
  double get average =>
      trendData.isEmpty
          ? 0
          : trendData.reduce((a, b) => a + b) / trendData.length;

  /// Returns the highest value from trend data
  double get highestValue =>
      trendData.isEmpty ? 0 : trendData.reduce((a, b) => a > b ? a : b);

  /// Returns the lowest value from trend data
  double get lowestValue =>
      trendData.isEmpty ? 0 : trendData.reduce((a, b) => a < b ? a : b);

  /// Returns true if the trend is increasing
  bool get isIncreasing =>
      trendData.length >= 2 && trendData.last > trendData[trendData.length - 2];

  /// Creates a copy of this FinancialInsight with optional new values
  FinancialInsight copyWith({
    String? title,
    String? description,
    List<double>? trendData,
    DateTime? date,
    InsightType? type,
  }) {
    return FinancialInsight(
      title: title ?? this.title,
      description: description ?? this.description,
      trendData: trendData ?? this.trendData,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  @override
  List<Object> get props => [title, description, trendData, date, type];

  @override
  String toString() =>
      'FinancialInsight(title: $title, type: $type, date: $date)';
}
