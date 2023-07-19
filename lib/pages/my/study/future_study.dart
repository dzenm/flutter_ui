import 'study.dart';

/// 异步学习测试代码
class FutureStudy {
  /// main 方法
  static void main() {
    FutureStudy instance = FutureStudy();
    // instance.taskPriority();
    instance.awaitTaskPriority();
  }

  /// 任务的优先级
  void taskPriority() {
    // I/flutter (23350): 2023-03-11 22:35:27 952 I/Application  main first task
    // I/flutter (23350): 2023-03-11 22:35:27 956 I/Application  Future first syncTask
    // I/flutter (23350): 2023-03-11 22:35:27 957 I/Application  main second task
    // I/flutter (23350): 2023-03-11 22:35:27 958 I/Application  Future second syncTask
    // I/flutter (23350): 2023-03-11 22:35:30 165 I/Application  Future first microTask
    // I/flutter (23350): 2023-03-11 22:35:30 166 I/Application  Future second microTask
    // I/flutter (23350): 2023-03-11 22:35:30 852 I/Application  Future first eventTask
    // I/flutter (23350): 2023-03-11 22:35:30 854 I/Application  Future second eventTask
    // main task > Future sync task > Future event task > Future micro task
    // 最先是不加任何异步的同步代码
    // Future.sync跟同步代码是一样的优先级
    // Future.micro task优先级其次（微任务队列 MicroTaskQueue）
    // Future.delayed优先级最后（事件队列 EventTaskQueue）

    Study.log('main first task');
    Future.microtask(() => Study.log('Future first microTask'));
    Future.sync(() => Study.log('Future first syncTask'));
    Future.delayed(Duration.zero, () => Study.log('Future first eventTask'));

    Study.log('main second task');
    Future.sync(() => Study.log('Future second syncTask'));
    Future.delayed(Duration.zero, () => Study.log('Future second eventTask'));
    Future.microtask(() => Study.log('Future second microTask'));
  }

  /// await 事件队列
  void awaitTaskPriority() {
    // I/flutter ( 2593): 2023-03-12 08:20:12 822 I/Application  main task start
    // I/flutter ( 2593): 2023-03-12 08:20:12 823 I/Application  foo task
    // I/flutter ( 2593): 2023-03-12 08:20:12 825 I/Application  fun1 task
    // I/flutter ( 2593): 2023-03-12 08:20:12 826 I/Application  fun2 task
    // I/flutter ( 2593): 2023-03-12 08:20:12 828 I/Application  fun3 task
    // I/flutter ( 2593): 2023-03-12 08:20:12 834 I/Application  main task end
    // I/flutter ( 2593): 2023-03-12 08:20:15 072 I/Application  foo return fun2
    // I/flutter ( 2593): 2023-03-12 08:20:15 073 I/Application  future value task
    //

    Study.log('main task start');
    foo();
    Future.value('future value task').then((a) => Study.log(a));
    Study.log("main task end");
  }

  void foo() async {
    Study.log('foo task');
    String res = await fun1();
    Study.log('foo $res');
  }

  Future<String> fun1() async {
    Study.log('fun1 task');
    return fun2();
  }

  Future<String> fun2() async {
    Study.log('fun2 task');
    fun3();
    return 'return fun2';
  }

  Future<void> fun3() async {
    Study.log('fun3 task');
  }
}
