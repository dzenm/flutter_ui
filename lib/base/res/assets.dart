class Assets {
  static final String imagePath = 'assets/image/';
  static final String iconPath = 'assets/icon/';
  static final String videoPath = 'assets/video/';
  static final String filePath = 'assets/file/';

  static String image(String imageName) => imagePath + imageName;

  static String icon(String iconName) => iconPath + iconName;

  static String video(String videoName) => videoPath + videoName;

  static String file(String fileName) => filePath + fileName;
}
