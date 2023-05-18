///
/// Created by a0010 on 2022/3/22 09:38
/// 获取Assets文件夹的数据
class Assets {
  static const String imagePath = 'assets/images/';
  static const String videoPath = 'assets/videos/';
  static const String filePath = 'assets/files/';

  static String image(String imageName) => imagePath + imageName;

  static String video(String videoName) => videoPath + videoName;

  static String file(String fileName) => filePath + fileName;
}
