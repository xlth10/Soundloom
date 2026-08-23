# VoiceCue Live Activity 快速闪念实施计划

## 已确认的产品决策

- 操作按钮允许短暂打开 VoiceCue。
- 打开后立即自动开始录音。
- 前台启动页保留“取消并丢弃”。
- 用户离开 App 后，从灵动岛或锁屏点击“停止并保存”。
- 录音进行时再次触发操作按钮，不创建第二段录音；只回到当前会话。
- 停止后立即保存原始音频并通知“语音闪念已保存，正在转写”。
- 仅在转写失败时通知用户进入 VoiceCue 重试。

## 实施结构

操作按钮快捷指令
  → StartVoiceCueQuickCaptureIntent（前台）
  → VoiceCueRecordingSessionCoordinator
  → PhoneLongRecorder 建立 AVAudioSession
  → VoiceCueLiveActivityController 创建 Live Activity
  → 用户回主屏或锁屏
  → StopVoiceCueQuickCaptureIntent（Live Activity）
  → RecordingInbox 保存原始文件并异步转写
  → 本地通知反馈结果

## 已实现

1. 将旧的 Toggle 入口替换为仅启动的 StartVoiceCueQuickCaptureIntent。
2. 新增协调器，将开始、停止保存、取消丢弃统一到同一会话逻辑。
3. 新增启动录音全屏页，包含计时与“取消并丢弃”。
4. 将锁屏和展开灵动岛配置为“停止并保存”。
5. 录音停止后先保存原始音频，再进入既有异步转写流程。
6. 新增保存中和转写失败本地通知。
7. Live Activity 不可创建时拒绝开始录音，避免后台录音被系统中止。

## 真机验收

1. 在“操作按钮”设置中选择一个快捷指令，其唯一动作是“开始 VoiceCue 语音闪念”。
2. App 未在前台时按操作按钮一次；VoiceCue 应短暂打开并立即显示计时启动页。
3. 不点取消，回到主屏或锁屏；应看到 VoiceCue 的录音 Live Activity。
4. 长按灵动岛或在锁屏卡片点击“停止并保存”。
5. 确认录音停止、出现“语音闪念已保存，正在转写”通知，且收件箱出现可播放原始音频。
6. 录音中再次按操作按钮；不应新建录音，而应回到已有会话。
7. 重新开始后在启动页点“取消并丢弃”；收件箱不应新增该段录音。

## 已知边界

- iOS 不允许 VoiceCue 在主屏上展示任意自定义悬浮弹窗；自定义 UI 只能在 App 前台或 Live Activity 的系统区域中出现。
- Live Activity 的停止按钮需要真机验证实际交互；它的 App Intent 在不打开 App 的情况下由 App 进程执行。
- 完整 Scheme 的命令行构建仍被既有 Watch AppIcon 资源配置阻断；本次 iPhone target 已通过 Xcode 真机构建并安装。
