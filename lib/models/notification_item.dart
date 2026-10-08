/// Model notifikasi dari API `/notifications`.
class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String? tipe;
  final int? referenceId;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.tipe,
    this.referenceId,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? 'Pemberitahuan',
      message: json['message'] ?? '',
      tipe: json['tipe'],
      referenceId: json['reference_id'] != null
          ? int.tryParse(json['reference_id'].toString())
          : null,
      isRead: json['is_read'] == 1 || json['is_read'] == true,
    );
  }

  /// Apakah notifikasi ini terkait persetujuan resep.
  bool get isPrescriptionApproved {
    final lowerTitle = title.toLowerCase();
    return lowerTitle.contains('disetujui') ||
        lowerTitle.contains('valid') ||
        lowerTitle.contains('acc');
  }
}
