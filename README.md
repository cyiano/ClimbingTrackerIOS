# ClimbingTracker

一个用于记录和追踪攀岩活动的iOS应用，使用SwiftUI构建。

## 项目介绍

ClimbingTracker 是一款专为攀岩爱好者设计的iOS应用，帮助用户记录每次攀岩活动、查看历史记录、分析统计数据，并支持数据的导入导出功能。

### 主要功能

- **日历记录**：通过日历界面直观地查看和添加攀岩记录
- **统计分析**：查看年度统计、月度趋势和详细的岩馆访问数据
- **数据管理**：支持数据的备份导出和恢复导入（JSON格式）
- **多种攀岩类型**：支持抱石、难度、速度三种攀岩类型
- **岩馆记录**：记录不同岩馆的访问情况

## 项目结构

```
ClimbingTracker/
├── ClimbingTracker.xcodeproj/      # Xcode项目文件
└── ClimbingTracker/                # 源代码目录
    ├── ClimbingTrackerApp.swift    # 应用入口
    ├── ContentView.swift            # 主视图（Tab导航）
    ├── Models/                      # 数据模型层
    │   ├── ClimbRecord.swift        # 攀岩记录数据模型
    │   ├── DataManager.swift        # 数据管理器（单例）
    │   └── Theme.swift              # 主题配置
    ├── Views/                       # 视图层
    │   ├── CalendarView.swift       # 日历视图
    │   ├── StatsView.swift          # 统计视图
    │   ├── DataManagementView.swift # 数据管理视图
    │   ├── RecordFormView.swift     # 记录表单视图
    │   └── ViewModifiers.swift      # 自定义视图修饰器
    ├── Utilities/                   # 工具类
    │   └── LayoutHelper.swift       # 布局辅助工具
    └── Assets.xcassets/             # 资源文件
        └── AppIcon.appiconset/      # 应用图标
```

### 架构说明

- **数据持久化**：使用UserDefaults存储数据，键名为`climbRecordsV1`
- **数据结构**：`[String: ClimbRecord]`字典，键为日期字符串（YYYY-MM-DD格式）
- **数据流**：DataManager单例作为唯一数据源，通过`@Published`属性发布变化
- **视图架构**：ContentView作为TabView容器，包含三个主要标签页（日历、统计、管理）

## 在Xcode中使用

### 系统要求

- macOS 12.0 或更高版本
- Xcode 14.0 或更高版本
- iOS 16.6 或更高版本（部署目标）

### 导入项目

1. 克隆仓库到本地：
```bash
git clone https://github.com/cyiano/ClimbingTrackerIOS.git
cd ClimbingTrackerIOS/ClimbingTracker
```

2. 打开项目：
```bash
open ClimbingTracker.xcodeproj
```

或者直接在Finder中双击`ClimbingTracker.xcodeproj`文件。

### 编译项目

#### 方法1：在Xcode中编译

1. 在Xcode中打开项目
2. 选择目标设备（模拟器或真机）
3. 点击运行按钮（⌘R）或选择菜单 Product > Run

#### 方法2：使用命令行编译

```bash
# 进入项目目录
cd ClimbingTrackerIOS/ClimbingTracker

# 编译Debug版本
xcodebuild -project ClimbingTracker.xcodeproj \
           -scheme ClimbingTracker \
           -configuration Debug

# 在模拟器中编译并运行
xcodebuild -project ClimbingTracker.xcodeproj \
           -scheme ClimbingTracker \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           -configuration Debug
```

### 调试项目

1. **设置断点**：在代码行号左侧点击添加断点
2. **运行调试**：按⌘R启动应用
3. **查看日志**：在Xcode底部的控制台查看输出
4. **查看视图层级**：运行时点击Debug View Hierarchy按钮
5. **内存调试**：使用Instruments工具进行性能分析

### 常见问题

**Q: 编译失败，提示签名错误**
A: 在项目设置中选择你的开发团队，或使用自动签名。

**Q: 模拟器无法启动**
A: 尝试重启Xcode或使用命令`xcrun simctl list`查看可用模拟器。

**Q: 数据在哪里存储？**
A: 数据存储在UserDefaults中，键名为`climbRecordsV1`。

## 技术栈

- **语言**：Swift
- **框架**：SwiftUI
- **最低部署版本**：iOS 16.6
- **数据持久化**：UserDefaults
- **依赖管理**：无外部依赖

## 开发说明

- 项目不使用CocoaPods、SPM或Carthage等依赖管理工具
- 所有UI文本使用中文
- 数据格式使用ISO8601标准
- 日期键格式统一为"YYYY-MM-DD"

## 许可证

[添加你的许可证信息]

## 作者

cyiano (cyiano@outlook.com)

## 贡献

欢迎提交Issue和Pull Request！
