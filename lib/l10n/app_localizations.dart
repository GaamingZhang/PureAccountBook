import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// 应用名称
  ///
  /// In zh, this message translates to:
  /// **'纯记账'**
  String get appName;

  /// 主页标签
  ///
  /// In zh, this message translates to:
  /// **'主页'**
  String get home;

  /// 图表标签
  ///
  /// In zh, this message translates to:
  /// **'图表'**
  String get chart;

  /// 排标签
  ///
  /// In zh, this message translates to:
  /// **'排行'**
  String get ranking;

  /// 设置标签
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 添加记录页面标题
  ///
  /// In zh, this message translates to:
  /// **'添加记录'**
  String get addRecord;

  /// 编辑记录页面标题
  ///
  /// In zh, this message translates to:
  /// **'编辑记录'**
  String get editRecord;

  /// 支出
  ///
  /// In zh, this message translates to:
  /// **'支出'**
  String get expense;

  /// 收入
  ///
  /// In zh, this message translates to:
  /// **'收入'**
  String get income;

  /// 金额
  ///
  /// In zh, this message translates to:
  /// **'金额'**
  String get amount;

  /// 日期
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get date;

  /// 选择类型
  ///
  /// In zh, this message translates to:
  /// **'选择类型'**
  String get selectCategory;

  /// 备注
  ///
  /// In zh, this message translates to:
  /// **'备注（可选）'**
  String get note;

  /// 保存按钮
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// 取消按钮
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 删除按钮
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// 确认删除标题
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// 确认删除消息
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这条记录吗？此操作不可撤销。'**
  String get confirmDeleteMessage;

  /// 记录已删除提示
  ///
  /// In zh, this message translates to:
  /// **'记录已删除'**
  String get recordDeleted;

  /// 保存成功提示
  ///
  /// In zh, this message translates to:
  /// **'保存成功'**
  String get saveSuccess;

  /// 无记录提示
  ///
  /// In zh, this message translates to:
  /// **'暂无记录'**
  String get noRecords;

  /// 添加记录提示
  ///
  /// In zh, this message translates to:
  /// **'点击右下角按钮添加记录'**
  String get addRecordHint;

  /// 类型管理
  ///
  /// In zh, this message translates to:
  /// **'类型管理'**
  String get categoryManage;

  /// 支出类型
  ///
  /// In zh, this message translates to:
  /// **'支出类型'**
  String get expenseCategory;

  /// 收入类型
  ///
  /// In zh, this message translates to:
  /// **'收入类型'**
  String get incomeCategory;

  /// 添加类型
  ///
  /// In zh, this message translates to:
  /// **'添加类型'**
  String get addCategory;

  /// 编辑类型
  ///
  /// In zh, this message translates to:
  /// **'编辑类型'**
  String get editCategory;

  /// 类型名称
  ///
  /// In zh, this message translates to:
  /// **'类型名称'**
  String get categoryName;

  /// 选择图标
  ///
  /// In zh, this message translates to:
  /// **'选择图标'**
  String get selectIcon;

  /// 默认类型
  ///
  /// In zh, this message translates to:
  /// **'默认类型'**
  String get defaultCategory;

  /// 类型已删除提示
  ///
  /// In zh, this message translates to:
  /// **'类型已删除'**
  String get categoryDeleted;

  /// 一周
  ///
  /// In zh, this message translates to:
  /// **'一周'**
  String get week;

  /// 一个月
  ///
  /// In zh, this message translates to:
  /// **'一个月'**
  String get month;

  /// 三个月
  ///
  /// In zh, this message translates to:
  /// **'三个月'**
  String get threeMonths;

  /// 一年
  ///
  /// In zh, this message translates to:
  /// **'一年'**
  String get year;

  /// 自定义
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get custom;

  /// 本周
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get thisWeek;

  /// 本月
  ///
  /// In zh, this message translates to:
  /// **'本月'**
  String get thisMonth;

  /// 本年
  ///
  /// In zh, this message translates to:
  /// **'本年'**
  String get thisYear;

  /// 结余
  ///
  /// In zh, this message translates to:
  /// **'结余'**
  String get balance;

  /// 无数据提示
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// 无备注
  ///
  /// In zh, this message translates to:
  /// **'无备注'**
  String get noNote;

  /// 请选择类型提示
  ///
  /// In zh, this message translates to:
  /// **'请选择类型'**
  String get pleaseSelectCategory;

  /// 请输入金额提示
  ///
  /// In zh, this message translates to:
  /// **'请输入金额'**
  String get pleaseEnterAmount;

  /// 请输入有效金额提示
  ///
  /// In zh, this message translates to:
  /// **'请输入有效金额'**
  String get pleaseEnterValidAmount;

  /// 请输入类型名称提示
  ///
  /// In zh, this message translates to:
  /// **'请输入类型名称'**
  String get pleaseEnterCategoryName;

  /// 语言设置
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// 主题设置
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// 深色模式
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkMode;

  /// 跟随系统
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// 浅色模式
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get light;

  /// 深色模式
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get dark;

  /// 预算
  ///
  /// In zh, this message translates to:
  /// **'预算'**
  String get budget;

  /// 设置预算
  ///
  /// In zh, this message translates to:
  /// **'设置预算'**
  String get setBudget;

  /// 编辑预算
  ///
  /// In zh, this message translates to:
  /// **'编辑预算'**
  String get editBudget;

  /// 清除预算
  ///
  /// In zh, this message translates to:
  /// **'清除预算'**
  String get clearBudget;

  /// 预算金额
  ///
  /// In zh, this message translates to:
  /// **'预算金额'**
  String get budgetAmount;

  /// 已支出
  ///
  /// In zh, this message translates to:
  /// **'已支出'**
  String get totalSpent;

  /// 剩余
  ///
  /// In zh, this message translates to:
  /// **'剩余'**
  String get remaining;

  /// 进度
  ///
  /// In zh, this message translates to:
  /// **'进度'**
  String get progress;

  /// 已超出预算
  ///
  /// In zh, this message translates to:
  /// **'已超出预算'**
  String get overBudget;

  /// 关于
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// 关于纯记账
  ///
  /// In zh, this message translates to:
  /// **'关于纯记账'**
  String get aboutApp;

  /// 版本
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  /// 纯本地数据
  ///
  /// In zh, this message translates to:
  /// **'纯本地数据'**
  String get localData;

  /// 纯本地数据说明
  ///
  /// In zh, this message translates to:
  /// **'所有数据仅存储在您的设备本地，不会上传到任何服务器。您的隐私数据完全由您自己掌控。'**
  String get localDataDesc;

  /// 无联网功能
  ///
  /// In zh, this message translates to:
  /// **'无联网功能'**
  String get noNetwork;

  /// 无联网功能说明
  ///
  /// In zh, this message translates to:
  /// **'本应用无需网络连接即可正常使用，不包含任何联网功能，确保您的数据安全。'**
  String get noNetworkDesc;

  /// 纯净无广告
  ///
  /// In zh, this message translates to:
  /// **'纯净无广告'**
  String get noAds;

  /// 纯净无广告说明
  ///
  /// In zh, this message translates to:
  /// **'应用内不含任何广告，为您提供清爽、专注的记账体验。'**
  String get noAdsDesc;

  /// 版权声明
  ///
  /// In zh, this message translates to:
  /// **'版权声明'**
  String get copyright;

  /// 我的
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get profile;

  /// 用户
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get user;

  /// 记账天数
  ///
  /// In zh, this message translates to:
  /// **'记账天数'**
  String get recordDays;

  /// 总记账笔数
  ///
  /// In zh, this message translates to:
  /// **'总记账笔数'**
  String get totalRecords;

  /// 天
  ///
  /// In zh, this message translates to:
  /// **'天'**
  String get days;

  /// 笔
  ///
  /// In zh, this message translates to:
  /// **'笔'**
  String get records;

  /// 主题设置
  ///
  /// In zh, this message translates to:
  /// **'主题设置'**
  String get themeSettings;

  /// 主题模式
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get themeMode;

  /// 主题色
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get themeColor;

  /// 浅色模式
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get lightMode;

  /// 请输入预算金额
  ///
  /// In zh, this message translates to:
  /// **'请输入预算金额'**
  String get pleaseEnterBudget;

  /// 确定要清除本月预算吗？
  ///
  /// In zh, this message translates to:
  /// **'确定要清除本月预算吗？'**
  String get confirmClear;

  /// 保存修改
  ///
  /// In zh, this message translates to:
  /// **'保存修改'**
  String get saveChanges;

  /// 确认设置
  ///
  /// In zh, this message translates to:
  /// **'确认设置'**
  String get confirm;

  /// 正在升级数据
  ///
  /// In zh, this message translates to:
  /// **'正在升级数据'**
  String get upgradingData;

  /// 请勿关闭应用...
  ///
  /// In zh, this message translates to:
  /// **'请勿关闭应用...'**
  String get doNotClose;

  /// 数据安全升级中
  ///
  /// In zh, this message translates to:
  /// **'数据安全升级中'**
  String get safeUpgrade;

  /// 选择开始日期
  ///
  /// In zh, this message translates to:
  /// **'选择开始日期'**
  String get selectStartDate;

  /// 选择结束日期
  ///
  /// In zh, this message translates to:
  /// **'选择结束日期'**
  String get selectEndDate;

  /// 开始日期不能晚于结束日期
  ///
  /// In zh, this message translates to:
  /// **'开始日期不能晚于结束日期'**
  String get startDateAfterEndDate;

  /// 返回
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get back;

  /// 早上好
  ///
  /// In zh, this message translates to:
  /// **'早上好'**
  String get goodMorning;

  /// 下午好
  ///
  /// In zh, this message translates to:
  /// **'下午好'**
  String get goodAfternoon;

  /// 晚上好
  ///
  /// In zh, this message translates to:
  /// **'晚上好'**
  String get goodEvening;

  /// 欢迎文字
  ///
  /// In zh, this message translates to:
  /// **'这里是纯记账'**
  String get welcomeText;

  /// 搜索提示
  ///
  /// In zh, this message translates to:
  /// **'搜索类别或备注...'**
  String get searchHint;

  /// 搜索
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// 搜索结果
  ///
  /// In zh, this message translates to:
  /// **'搜索结果'**
  String get searchResult;

  /// 记账记录
  ///
  /// In zh, this message translates to:
  /// **'记账记录'**
  String get recordList;

  /// 全部
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// 总收入
  ///
  /// In zh, this message translates to:
  /// **'总收入'**
  String get totalIncome;

  /// 总支出
  ///
  /// In zh, this message translates to:
  /// **'总支出'**
  String get totalExpense;

  /// 收入标签
  ///
  /// In zh, this message translates to:
  /// **'收入:'**
  String get incomeLabel;

  /// 支出标签
  ///
  /// In zh, this message translates to:
  /// **'支出:'**
  String get expenseLabel;

  /// 暂无记账记录
  ///
  /// In zh, this message translates to:
  /// **'暂无记账记录'**
  String get noRecordsYet;

  /// 未找到匹配的记录
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的记录'**
  String get noMatchFound;

  /// 尝试更换搜索关键词
  ///
  /// In zh, this message translates to:
  /// **'尝试更换搜索关键词'**
  String get tryOtherKeywords;

  /// 添加第一笔记账提示
  ///
  /// In zh, this message translates to:
  /// **'点击下方 + 按钮添加第一笔记账'**
  String get addFirstRecord;

  /// 月摘要
  ///
  /// In zh, this message translates to:
  /// **'月摘要'**
  String get monthSummary;

  /// 语言设置
  ///
  /// In zh, this message translates to:
  /// **'语言设置'**
  String get languageSettings;

  /// 跟随系统语言
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystemLanguage;

  /// 关于纯记账
  ///
  /// In zh, this message translates to:
  /// **'关于纯记账'**
  String get aboutPureBook;

  /// 应用标语
  ///
  /// In zh, this message translates to:
  /// **'记录您的财富增长'**
  String get slogan;

  /// 今天
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// 昨天
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get yesterday;

  /// 应用到所有月份
  ///
  /// In zh, this message translates to:
  /// **'应用到所有月份'**
  String get applyToAllMonths;

  /// 将当前预算应用到所有月份说明
  ///
  /// In zh, this message translates to:
  /// **'将当前预算应用到所有月份'**
  String get applyToAllMonthsDesc;

  /// 应用成功
  ///
  /// In zh, this message translates to:
  /// **'应用成功'**
  String get applySuccess;

  /// 预算已应用到所有月份
  ///
  /// In zh, this message translates to:
  /// **'预算已应用到所有月份'**
  String get budgetAppliedToAllMonths;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
