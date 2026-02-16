# 纯记账 (Pure Account Book)

一款简洁、高效的个人记账应用，专注于帮助用户轻松管理日常收支。

> 本项目使用 [Trae IDE](https://www.trae.ai/) 和 [GLM-5](https://www.zhipuai.cn/) AI 模型在24小时内完成开发。

## 应用截图

<table>
  <tr>
    <td align="center">
      <img src="public/screenshot/01_home_screen.jpg" width="200" />
      <br />
      <strong>首页</strong>
    </td>
    <td align="center">
      <img src="public/screenshot/02_add_transaction.png" width="200" />
      <br />
      <strong>添加记录</strong>
    </td>
    <td align="center">
      <img src="public/screenshot/03_stats_screen.png" width="200" />
      <br />
      <strong>数据统计</strong>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="public/screenshot/04_chart_screen.png" width="200" />
      <br />
      <strong>图表分析</strong>
    </td>
    <td align="center">
      <img src="public/screenshot/05_budget_screen.jpg" width="200" />
      <br />
      <strong>预算管理</strong>
    </td>
    <td align="center">
      <img src="public/screenshot/06_settings_screen.jpg" width="200" />
      <br />
      <strong>设置页面</strong>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="public/screenshot/07_category_management.jpg" width="200" />
      <br />
      <strong>分类管理</strong>
    </td>
    <td align="center">
      <img src="public/screenshot/08_dark_mode.jpg" width="200" />
      <br />
      <strong>深色模式</strong>
    </td>
    <td align="center">
      <img src="public/screenshot/09_transaction_edit.jpg" width="200" />
      <br />
      <strong>编辑记录</strong>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="public/screenshot/10_search_function.jpg" width="200" />
      <br />
      <strong>搜索功能</strong>
    </td>
    <td align="center">
      <img src="public/screenshot/11_language_settings.jpg" width="200" />
      <br />
      <strong>语言设置</strong>
    </td>
    <td></td>
  </tr>
</table>

## 功能特性

### 核心功能

#### 1. 记账管理
- **快速记账**：一键添加收入/支出记录，支持金额、类别、日期、备注等字段
- **记录编辑**：支持修改已添加的记账记录
- **滑动删除**：向左滑动记录即可删除，带有确认对话框防止误删
- **搜索功能**：支持按类别或备注搜索历史记录

#### 2. 分类管理
- **预设分类**：内置常用收入/支出分类（餐饮、交通、购物、工资等）
- **自定义分类**：支持添加、编辑、删除自定义分类
- **分类图标**：每个分类配有直观的图标显示
- **分类颜色**：支持为分类设置自定义颜色

#### 3. 预算管理
- **月度预算**：设置每月预算上限
- **预算进度**：实时显示当月支出进度条
- **超支提醒**：预算超支时进度条变红提醒
- **批量应用**：一键将当前预算应用到所有月份

#### 4. 数据统计
- **月度摘要**：展示当月总收入、总支出、结余
- **趋势图表**：折线图展示收支趋势变化
- **分类排行**：饼图展示各类别支出占比
- **收支对比**：柱状图对比不同时间段收支

#### 5. 个性化设置
- **多语言支持**：支持中文（简体/繁体）、英文、日语、韩语、法语、西班牙语、俄语
- **主题切换**：支持浅色/深色主题，可跟随系统设置
- **语言切换**：随时切换应用显示语言

### 技术特点

- **完全离线**：无需网络连接，数据完全存储在本地
- **隐私保护**：不收集任何用户数据，无需任何权限
- **数据安全**：使用 SQLite 数据库本地存储
- **流畅体验**：使用 Riverpod 状态管理，响应式 UI 更新

## 技术架构

### 技术栈

| 技术 | 用途 |
|------|------|
| Flutter | 跨平台 UI 框架 |
| Riverpod | 状态管理 |
| SQLite (sqflite) | 本地数据存储 |
| fl_chart | 图表可视化 |
| intl | 国际化支持 |
| shared_preferences | 轻量级本地存储 |
| google_fonts | 字体支持 |

### 项目结构

```
lib/
├── core/                    # 核心功能
│   ├── config/              # 应用配置
│   └── database/            # 数据库相关
│       ├── migrations/      # 数据库迁移
│       └── database_helper.dart
│
├── features/                # 功能模块
│   ├── budget/              # 预算模块
│   │   ├── models/          # 数据模型
│   │   ├── providers/       # 状态管理
│   │   ├── repositories/    # 数据仓库
│   │   └── views/           # UI 页面
│   │
│   ├── category/            # 分类模块
│   │   ├── data/            # 默认数据
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   └── views/
│   │
│   ├── transaction/         # 交易模块
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   └── views/
│   │
│   ├── chart/               # 图表模块
│   ├── settings/            # 设置模块
│   └── ui/                  # 通用 UI
│
├── l10n/                    # 国际化资源
│   ├── app_zh.arb           # 简体中文
│   ├── app_zh_Hant.arb      # 繁体中文
│   ├── app_en.arb           # 英文
│   ├── app_ja.arb           # 日语
│   ├── app_ko.arb           # 韩语
│   ├── app_fr.arb           # 法语
│   ├── app_es.arb           # 西班牙语
│   └── app_ru.arb           # 俄语
│
├── providers/               # 全局状态
├── screens/                 # 主要页面
├── shared/                  # 共享组件
│   ├── utils/               # 工具类
│   └── widgets/             # 通用组件
│
└── main.dart                # 应用入口
```

### 数据模型

#### TransactionRecord (交易记录)
```dart
- id: int              // 主键
- amount: double       // 金额
- type: String         // 类型 (income/expense)
- categoryId: int      // 分类ID
- date: String         // 日期
- note: String?        // 备注
- createdAt: String    // 创建时间
- updatedAt: String    // 更新时间
```

#### Category (分类)
```dart
- id: int              // 主键
- name: String         // 分类名称
- icon: String         // 图标名称
- type: String         // 类型 (income/expense)
- color: String?       // 颜色值
```

#### MonthlyBudget (月度预算)
```dart
- id: int              // 主键
- amount: double       // 预算金额
- month: String        // 月份 (yyyy-MM)
- createdAt: String    // 创建时间
```

### 状态管理

使用 Riverpod 进行状态管理，主要 Provider 包括：

- `transactionNotifierProvider` - 交易记录状态管理
- `categoryNotifierProvider` - 分类状态管理
- `monthlyBudgetProvider` - 预算状态管理
- `themeProvider` - 主题状态管理
- `localeProvider` - 语言状态管理

### 数据库迁移

支持数据库版本升级，当前版本为 v5：

- v1: 基础表结构
- v2: 添加分类颜色字段
- v3: 添加交易更新时间字段
- v4: 添加预算表
- v5: 添加月度预算表

## 开始使用

### 环境要求

- Flutter SDK >= 3.11.0
- Dart SDK >= 3.11.0

### 安装运行

```bash
# 克隆项目
git clone https://github.com/yourusername/account_book.git

# 进入项目目录
cd account_book

# 安装依赖
flutter pub get

# 生成国际化文件
flutter gen-l10n

# 运行应用
flutter run

# 本地测试
flutter clean && flutter pub get && flutter gen-l10n && flutter run --release -d GaamingZhang
```

### 构建发布

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# macOS
flutter build macos --release
```

## 支持平台

- ✅ Android
- ✅ iOS
- ✅ macOS
- ✅ Web
- ✅ Windows
- ✅ Linux

## 致谢

本项目使用以下开源技术：
- [Flutter](https://flutter.dev/) - UI 框架
- [Riverpod](https://riverpod.dev/) - 状态管理
- [fl_chart](https://pub.dev/packages/fl_chart) - 图表库
- [sqflite](https://pub.dev/packages/sqflite) - SQLite 数据库

---

**开发工具**：本项目使用 [Trae IDE](https://www.trae.ai/) 和 [GLM-5](https://www.zhipuai.cn/) AI 模型辅助开发完成。
