enum BillStatus {
  pending('Pending', 0xFFFFA726), // Orange
  overdue('Overdue', 0xFFE57373), // Red
  paid('Paid', 0xFF81C784), // Green
  cancelled('Cancelled', 0xFF90A4AE); // Grey

  final String label;
  final int color;
  const BillStatus(this.label, this.color);

  factory BillStatus.fromString(String value) {
    return BillStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => BillStatus.pending,
    );
  }
}
