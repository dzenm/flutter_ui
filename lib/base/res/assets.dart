class Assets {
  static const String imagePath = 'assets/images/';
  static const String videoPath = 'assets/videos/';
  static const String filePath = 'assets/files/';

  static String image(String imageName) => imagePath + imageName;

  static String video(String videoName) => videoPath + videoName;

  static String file(String fileName) => filePath + fileName;
}
