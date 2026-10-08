String formatRupiah(dynamic price) {
  final int value = double.tryParse(price.toString())?.toInt() ?? 0;
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
}
