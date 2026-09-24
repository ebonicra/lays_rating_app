/// Картинка новости: локальная (ещё не загружена) или серверная.
class NewsImage {
  const NewsImage.local(this.localPath) : remotePath = null;
  const NewsImage.remote(this.remotePath) : localPath = null;

  /// Локальный путь (файл ещё не загружен).
  final String? localPath;

  /// Имя файла на сервере.
  final String? remotePath;

  bool get isLocal => localPath != null;
  bool get isRemote => remotePath != null;

  /// Возвращает имя файла для `extra_data` (только для серверной).
  String? get serverName => remotePath;

  factory NewsImage.fromJson(Map<String, dynamic> json) {
    return NewsImage.remote(json['image_path'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'image_path': remotePath};
}