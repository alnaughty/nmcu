extension Formatter on Duration {
  String formatDuration() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes.remainder(60))}:${twoDigits(seconds.remainder(60))}";
    } else {
      return "${twoDigits(minutes)}:${twoDigits(seconds.remainder(60))}";
    }
  }
}
