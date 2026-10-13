# WorldClockMenuBar

一个使用 Swift、SwiftUI 和 AppKit 开发的 macOS 菜单栏世界时钟应用，可在菜单栏中查看多个城市的时间，并快速切换当前选中的城市时钟。

## 功能特性

- **多城市时钟**：在菜单栏中查看多个城市的当前时间。
- **快速切换**：点击城市即可切换当前选中的时钟。
- **24 小时制**：默认使用 24 小时制。
- **显示设置**：支持配置城市名称、时间格式和菜单栏图标。
- **时区管理**：通过设置窗口管理时钟城市与时区。
- **诊断日志**：记录应用启动、设置窗口和城市切换等操作。
- **菜单栏应用**：作为菜单栏常驻应用运行，不在 Dock 中显示普通应用图标。

## 运行环境

- macOS 13.0 或更高版本
- Swift 编译器 `swiftc`
- Xcode Command Line Tools

已测试环境：macOS 27.0.1。

## 项目结构

```text
WorldClockMenuBar/
├── WorldClockMenuBar/
│   ├── WorldClockMenuBarApp.swift
│   ├── ClockMenuView.swift
│   ├── ClockStore.swift
│   ├── SettingsView.swift
│   └── DiagnosticLog.swift
├── build.sh
├── run.sh
├── .gitignore
└── README.md
```

## 快速开始

### 1. 安装编译工具

在终端中执行：

```bash
xcode-select --install
```

如果已经安装 Xcode 或 Command Line Tools，可以跳过此步骤。

确认 Swift 编译器可用：

```bash
swiftc --version
```

### 2. 下载项目

如果使用 Git 克隆仓库：

```bash
git clone https://github.com/你的用户名/WorldClockMenuBar.git
cd WorldClockMenuBar
```

请将仓库地址替换为实际的 GitHub 地址。

### 3. 编译应用

在项目根目录执行：

```bash
chmod +x build.sh run.sh
./build.sh
```

编译脚本会自动：

1. 检查 `swiftc` 是否可用。
2. 清理之前生成的 `.build` 和应用包。
3. 编译 `WorldClockMenuBar/` 目录下的 Swift 源文件。
4. 创建 macOS `.app` 应用包。
5. 写入应用所需的 `Info.plist`。

成功后，终端会输出：

```text
Built: dist/WorldClockMenuBar.app
Run it with: open "dist/WorldClockMenuBar.app"
```

### 4. 运行应用

推荐使用项目提供的运行脚本：

```bash
./run.sh
```

也可以直接执行：

```bash
open dist/WorldClockMenuBar.app
```

如果应用尚未编译，`run.sh` 会提示先执行 `./build.sh`。

## 生成文件说明

| 路径 | 用途 |
|---|---|
| `.build/` | 构建过程中使用的目录 |
| `dist/WorldClockMenuBar.app` | 编译生成的 macOS 应用 |
| `build.sh` | 编译脚本 |
| `run.sh` | 启动脚本 |

`.build/` 和 `dist/` 属于生成目录，通常无需提交到 GitHub。其他用户克隆源码后，可以自行编译生成应用。

## 诊断日志

应用运行日志默认保存在：

```text
~/Library/Application Support/WorldClockMenuBar/diagnostics.log
```

日志可用于排查应用启动、城市切换和设置窗口显示等问题。

分享日志前，请检查其中是否包含不希望公开的本机环境或操作信息。

## 技术栈

- **Swift**：应用逻辑与时间处理
- **SwiftUI**：菜单栏内容与设置界面
- **AppKit**：macOS 应用激活与窗口交互
- **Foundation**：日期、时间和时区相关功能

## 后续计划

- 完善城市和时区的添加、删除功能。
- 优化设置窗口及菜单栏交互。
- 增加更多菜单栏图标选项。
- 持续改进日志和故障排查能力。

## 许可证

当前项目暂未指定开源许可证。

如果计划公开发布并允许他人使用、修改或分发代码，请先选择并添加适合项目的许可证文件。