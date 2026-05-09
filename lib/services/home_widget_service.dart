import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const _groupId = 'group.com.magic8ball.widget';
  static const _iOSWidgetName = 'DailyFortuneWidget';
  static const _androidWidgetName = 'DailyFortuneWidget';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_groupId);
  }

  Future<void> updateDailyFortune(String fortune) async {
    await HomeWidget.saveWidgetData('daily_fortune', fortune);
    await HomeWidget.updateWidget(
      name: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  }

  Future<void> updateStreak(int streak) async {
    await HomeWidget.saveWidgetData('streak_count', streak.toString());
    await HomeWidget.updateWidget(
      name: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  }

  Future<void> clearWidget() async {
    await HomeWidget.saveWidgetData('daily_fortune', 'Shake for your fortune');
    await HomeWidget.saveWidgetData('streak_count', '0');
    await HomeWidget.updateWidget(
      name: _iOSWidgetName,
      androidName: _androidWidgetName,
    );
  }
}
