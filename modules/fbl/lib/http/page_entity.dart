///
/// Created by a0010 on 2022/3/22 09:38
/// HTTP返回时分页数据对应的实体类
class PageEntity<T> {
  int? size;
  int? total;
  int? curPage;
  int? offset;
  bool? over;
  int? pageCount;
  List<T?>? datas;

  PageEntity.fromJson(Map<String, dynamic> json) {
    size = json['size'];
    total = json['total'];
    curPage = json['curPage'];
    offset = json['offset'];
    over = json['over'];
    pageCount = json['pageCount'];
    datas = json['datas'];
  }

  Map<String, dynamic> toJson() => {
        'size': size,
        'total': total,
        'curPage': curPage,
        'offset': offset,
        'over': over,
        'pageCount': pageCount,
        'datas': datas,
      };
}
