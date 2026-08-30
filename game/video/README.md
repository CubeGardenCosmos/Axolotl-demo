# video/ — playVideo 占位目录

`demo.webm` 是 `playVideo:video/demo.webm` 的**占位引用**：
当前游戏运行时（Game Runtime，Phase 3 前的占位实现）收到 `playVideo` 事件时只会
记录一条日志并继续执行（优雅降级），并不会尝试解码视频文件。

因此本目录只保留一个空占位文件以满足 `axolotlc check` 的资产完整性校验；
待引擎补齐视频播放（Phase 3+）后，把真正的视频素材放入本目录即可。