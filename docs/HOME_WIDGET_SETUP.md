# Home Screen Widget Setup

This app supports home screen widgets on both iOS and Android using the `home_widget` package.

## iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Add a new Widget Extension target:
   - File > New > Target > Widget Extension
   - Name it `DailyFortuneWidget`
   - Make sure "Include Configuration Intent" is unchecked
3. In the widget Swift file, use the App Group `group.com.magic8ball.widget`
4. The widget reads `daily_fortune` and `streak_count` from shared UserDefaults

## Android Setup

1. Create a new `AppWidgetProvider` class in `android/app/src/main/kotlin/...`
2. Define the widget in `res/xml/daily_fortune_widget_info.xml`
3. Add the widget receiver to `AndroidManifest.xml`
4. The widget reads from the same shared preferences key

## Deep Linking

Tapping the widget opens the app with the route `/daily`, which navigates to the home screen with the daily fortune flow.

## Testing

Run the app and ask a question. The widget should update with the latest answer and streak count.
