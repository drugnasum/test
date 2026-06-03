# OpenCode 介绍

## 1. 基础信息

OpenCode 是一个开源 AI 编程代理（AI Coding Agent），可作为终端界面、桌面应用或 IDE 扩展使用。

- **GitHub Stars**: 160K+
- **贡献者**: 900+
- **月活开发者**: 7.5M+
- **隐私优先**: 不存储任何代码或上下文数据
- **模型支持**: 通过 Models.dev 支持 75+ LLM 提供商，包括 Claude、GPT、Gemini 等本地和云端模型
- **许可接入**: 支持 GitHub Copilot 和 ChatGPT Plus/Pro 账户直接登录

### 安装方式

```bash
# 推荐：安装脚本
curl -fsSL https://opencode.ai/install | bash

# npm
npm install -g opencode-ai

# Homebrew (macOS/Linux)
brew install anomalyco/tap/opencode

# Arch Linux
sudo pacman -S opencode

# Windows (Chocolatey)
choco install opencode
```

### 快速开始

```bash
cd /path/to/project
opencode        # 启动
/init           # 初始化项目，自动生成 AGENTS.md
```

---

## 2. Agent（代理）

Agent 是 OpenCode 中的专业化 AI 助手，可为特定任务和工作流进行定制，拥有自定义提示词、模型和工具权限。

### 2.1 类型

| 类型 | 说明 |
|------|------|
| **Primary Agent** | 主代理，用户直接交互。可用 `Tab` 键切换，拥有完整工具权限 |
| **Subagent** | 子代理，由主代理调用或通过 `@` 提及手动调用，处理特定专业任务 |

### 2.2 内置 Agent

| Agent | 模式 | 说明 |
|-------|------|------|
| **Build** | Primary | 默认主代理，拥有所有工具权限，用于开发工作 |
| **Plan** | Primary | 只读规划代理，文件编辑和 bash 默认为 `ask`（需批准），仅分析不修改 |
| **General** | Subagent | 通用子代理，用于研究复杂问题和多步任务，拥有完整工具权限（除 todo） |
| **Explore** | Subagent | 快速只读代理，用于代码库探索、文件查找、关键词搜索 |
| **Scout** | Subagent | 只读代理，用于外部文档和依赖研究，可克隆依赖仓库到缓存 |
| **Compaction** | Primary (隐藏) | 系统代理，自动压缩长上下文 |
| **Title** | Primary (隐藏) | 系统代理，自动生成会话标题 |
| **Summary** | Primary (隐藏) | 系统代理，自动生成会话摘要 |

### 2.3 自定义 Agent

可通过两种方式创建自定义 Agent：

**JSON 配置** (`opencode.json`):

```json
{
  "agent": {
    "code-reviewer": {
      "description": "Reviews code for best practices",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "You are a code reviewer...",
      "permission": { "edit": "deny" }
    }
  }
}
```

**Markdown 文件** (`~/.config/opencode/agents/review.md`):

```markdown
---
description: Reviews code for quality and best practices
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
permission:
  edit: deny
  bash: deny
---
You are in code review mode. Focus on code quality, bugs, and security.
```

### 2.4 Agent 关键配置项

| 配置 | 说明 |
|------|------|
| `description` | Agent 描述（必填） |
| `mode` | `primary` / `subagent` / `all` |
| `model` | 覆盖使用的模型 |
| `temperature` | 控制创意性（0.0~1.0） |
| `steps` | 最大迭代步数 |
| `prompt` | 自定义系统提示词文件路径 |
| `permission` | 工具权限控制：`allow` / `ask` / `deny` |
| `hidden` | 从 `@` 菜单隐藏（仅 subagent） |
| `color` | UI 颜色自定义 |

也可使用 `opencode agent create` 命令交互式创建 Agent。

---

## 3. Skill（技能）

Skill 是通过 `SKILL.md` 文件定义的可复用指令集，Agent 可按需加载。

### 3.1 放置路径

| 路径 | 作用域 |
|------|--------|
| `.opencode/skills/<name>/SKILL.md` | 项目级 |
| `~/.config/opencode/skills/<name>/SKILL.md` | 全局 |
| `.claude/skills/<name>/SKILL.md` | 项目级（Claude 兼容） |
| `~/.claude/skills/<name>/SKILL.md` | 全局（Claude 兼容） |
| `.agents/skills/<name>/SKILL.md` | 项目级（Agent 兼容） |
| `~/.agents/skills/<name>/SKILL.md` | 全局（Agent 兼容） |

### 3.2 文件格式

每个 `SKILL.md` 必须包含 YAML frontmatter：

```markdown
---
name: git-release
description: Create consistent releases and changelogs
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: github
---
## What I do
- Draft release notes from merged PRs
- Propose a version bump

## When to use me
Use this when you are preparing a tagged release.
```

**Frontmatter 字段**:
- `name`（必填）: 1~64 字符，小写字母数字加连字符，需与目录名匹配
- `description`（必填）: 1~1024 字符
- `license`（可选）
- `compatibility`（可选）
- `metadata`（可选，键值对）

### 3.3 工作机制

OpenCode 将可用 Skill 列表注入到 `skill` 工具描述中：

```xml
<available_skills>
  <skill>
    <name>git-release</name>
    <description>Create consistent releases and changelogs</description>
  </skill>
</available_skills>
```

Agent 通过 `skill({ name: "git-release" })` 调用加载完整内容。

### 3.4 当前工作目录下的 Skill

本项目（`H:\test`）中配置了以下 Skill：

**prompt-optimizer** (`C:\Users\voidv\.agents\skills\prompt-optimizer\SKILL.md`)

- **描述**: 优化提示词文本本身
- **功能**: 将泛泛而谈的提示词转换为精准、具体的描述，而不是回答或执行提示词内容
- **参数**: `originalPrompt` - 待优化的提示词文本
- **硬性约束**: 不调用任何实现 Skill

**test-a** (`C:\Users\voidv\.agents\skills\test-a\SKILL.md`)

- **描述**: test a — 用来取得 Jira issue
- **参数**: `Production`（Production 值）、`OutputFile`（输出文件名）
- **工作流**: 在工作目录生成 `jiraJsonInput.json`，写入 Jira 项目元数据

---

## 4. MCP（Model Context Protocol）

MCP 允许 OpenCode 接入外部工具服务，添加后 MCP 工具自动可用。

### 4.1 服务器类型

**本地 MCP 服务器** (`type: "local"`):

```json
{
  "mcp": {
    "my-local-mcp": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-command"],
      "enabled": true,
      "environment": { "MY_ENV_VAR": "value" }
    }
  }
}
```

**远程 MCP 服务器** (`type: "remote"`):

```json
{
  "mcp": {
    "my-remote-mcp": {
      "type": "remote",
      "url": "https://my-mcp-server.com",
      "headers": { "Authorization": "Bearer MY_API_KEY" }
    }
  }
}
```

### 4.2 OAuth 支持

远程 MCP 支持 OAuth 自动认证（RFC 7591 动态客户端注册）：

```bash
opencode mcp auth <server-name>   # 认证
opencode mcp list                  # 列出所有 MCP 及认证状态
opencode mcp logout <server-name>  # 移除凭证
```

### 4.3 工具管理

MCP 工具与内置工具并列可用，可通过 `tools` 配置全局或按 Agent 控制权限：

```json
{
  "tools": { "my-mcp*": false },
  "agent": {
    "my-agent": { "tools": { "my-mcp*": true } }
  }
}
```

### 4.4 常见 MCP 服务器示例

| 名称 | 类型 | 用途 |
|------|------|------|
| **Sentry** | Remote | 查询项目和错误信息 |
| **Context7** | Remote | 搜索文档 |
| **Grep (Vercel)** | Remote | 搜索 GitHub 代码片段 |

### 4.5 注意事项

- MCP 服务器会增加上下文 token，建议按需启用
- 可设置 `enabled: false` 临时禁用而不删除配置

---

## 5. LSP（Language Server Protocol）

OpenCode 可集成 LSP 服务器，将语言诊断信息作为 Agent 反馈。

### 5.1 启用方式

```json
{ "lsp": true }       // 启用所有内置 LSP
{ "lsp": false }      // 禁用所有 LSP
{ "lsp": {} }         // 启用内置 LSP + 自定义配置
```

### 5.2 内置 LSP 支持

OpenCode 内置了 30+ 语言的 LSP 支持，包括：

| LSP 服务器 | 语言/文件类型 | 自动安装 |
|-----------|-------------|---------|
| typescript | .ts, .tsx, .js, .jsx | 是 |
| gopls | .go | 否（需 go 命令） |
| rust | .rs | 否（需 rust-analyzer） |
| pyright | .py, .pyi | 否（需 pyright 依赖） |
| clangd | .c, .cpp, .h, .hpp | 是 |
| jdtls | .java | 否（需 Java 21+） |
| dart | .dart | 否（需 dart 命令） |
| sourcekit-lsp | .swift | 否（需 swift） |
| vue | .vue | 是 |
| svelte | .svelte | 是 |
| astro | .astro | 是 |
| prisma | .prisma | 否（需 prisma 命令） |
| ... | ... | ... |

> LSP 默认禁用。启用后，打开文件时自动检测扩展名并启动对应 LSP 服务器。
> 可通过 `OPENCODE_DISABLE_LSP_DOWNLOAD=true` 环境变量禁用自动下载。

### 5.3 自定义 LSP

```json
{
  "lsp": {
    "custom-lsp": {
      "command": ["custom-lsp-server", "--stdio"],
      "extensions": [".custom"],
      "env": { "RUST_LOG": "debug" },
      "initialization": { "preferences": { "importModuleSpecifierPreference": "relative" } }
    },
    "typescript": { "disabled": true }
  }
}
```

### 5.4 最佳实践

- LSP 提供诊断信息可帮助 Agent 定位问题，但并非所有项目都受益
- 语言服务器可能占用大量内存、版本不一致、拖慢 Agent 流程
- 许多项目中，让 Agent 直接运行 lint/typecheck 命令更可靠
- 建议在 `AGENTS.md` 中记录相关命令

---

## 6. Plugin（插件）

Plugin 允许通过 JavaScript/TypeScript 模块扩展 OpenCode 行为，可订阅事件、修改工具执行、添加自定义工具等。

### 6.1 安装插件

**本地插件** — 放置于：
- `.opencode/plugins/`（项目级）
- `~/.config/opencode/plugins/`（全局）

**npm 插件** — 在 `opencode.json` 中声明：

```json
{
  "plugin": ["opencode-helicone-session", "opencode-wakatime", "@my-org/custom-plugin"]
}
```

npm 插件使用 Bun 自动安装并缓存至 `~/.cache/opencode/node_modules/`。

**加载顺序**: 全局配置 → 项目配置 → 全局 plugins 目录 → 项目 plugins 目录

### 6.2 创建插件

插件导出一个异步函数，接收上下文对象，返回钩子对象：

```javascript
export const MyPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    "tool.execute.before": async (input, output) => { /* ... */ },
    "event": async ({ event }) => { /* ... */ },
  }
}
```

TypeScript 支持：

```typescript
import type { Plugin } from "@opencode-ai/plugin"
export const MyPlugin: Plugin = async (ctx) => { /* ... */ }
```

### 6.3 可用事件

| 分类 | 事件 |
|------|------|
| 命令 | `command.executed` |
| 文件 | `file.edited`, `file.watcher.updated` |
| 安装 | `installation.updated` |
| LSP | `lsp.client.diagnostics`, `lsp.updated` |
| 消息 | `message.part.removed`, `message.part.updated`, `message.removed`, `message.updated` |
| 权限 | `permission.asked`, `permission.replied` |
| 服务器 | `server.connected` |
| 会话 | `session.created`, `session.compacted`, `session.deleted`, `session.diff`, `session.error`, `session.idle`, `session.status`, `session.updated` |
| Todo | `todo.updated` |
| Shell | `shell.env` |
| 工具 | `tool.execute.before`, `tool.execute.after` |
| TUI | `tui.prompt.append`, `tui.command.execute`, `tui.toast.show` |

### 6.4 插件示例

**发送通知**:
```javascript
export const NotificationPlugin = async ({ $ }) => ({
  event: async ({ event }) => {
    if (event.type === "session.idle") {
      await $`osascript -e 'display notification "Done!" with title "opencode"'`
    }
  }
})
```

**保护 .env 文件**:
```javascript
export const EnvProtection = async () => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool === "read" && output.args.filePath.includes(".env")) {
      throw new Error("Do not read .env files")
    }
  }
})
```

**自定义工具**:
```typescript
import { type Plugin, tool } from "@opencode-ai/plugin"
export const CustomToolsPlugin: Plugin = async () => ({
  tool: {
    mytool: tool({
      description: "A custom tool",
      args: { foo: tool.schema.string() },
      async execute(args, context) {
        return `Hello ${args.foo}`
      }
    })
  }
})
```

---

## 7. 内置工具

OpenCode 内置以下工具供 Agent 使用：

| 工具 | 说明 | 权限键 |
|------|------|--------|
| `bash` | 执行 Shell 命令 | `bash` |
| `edit` | 精确字符串替换编辑文件 | `edit` |
| `write` | 创建或覆盖文件 | `edit` |
| `read` | 读取文件内容 | `read` |
| `grep` | 正则搜索文件内容 | `grep` |
| `glob` | 按模式匹配查找文件 | `glob` |
| `lsp` | LSP 代码智能（实验性） | `lsp` |
| `apply_patch` | 应用补丁 | `edit` |
| `skill` | 加载 Skill 指令 | `skill` |
| `todowrite` | 管理任务清单 | `todowrite` |
| `webfetch` | 获取网页内容 | `webfetch` |
| `websearch` | 网页搜索（需 Exa） | `websearch` |
| `question` | 向用户提问 | `question` |

权限控制：`allow`（允许）、`ask`（需批准）、`deny`（禁止）。

---

## 8. AGENTS.md（项目规则）

`AGENTS.md` 是 OpenCode 的项目级指令文件，类似 Cursor 的 rules。Agent 启动时会自动加载该文件作为上下文。

### 8.1 文件位置与优先级

| 优先级 | 路径 | 作用域 |
|--------|------|--------|
| 1 | 项目目录下 `AGENTS.md` | 项目级（向上遍历查找） |
| 2 | `~/.config/opencode/AGENTS.md` | 全局 |
| 3 | `~/.claude/CLAUDE.md` | 全局（Claude 兼容） |

> 同级目录同时存在 `AGENTS.md` 和 `CLAUDE.md` 时，仅加载 `AGENTS.md`。

### 8.2 初始化

运行 `/init` 命令，OpenCode 会扫描项目并自动生成或更新 `AGENTS.md`，包括：
- 构建、lint、测试命令
- 项目结构和架构说明
- 项目特定约定和注意事项
- 引用已有的 Cursor/Copilot 规则

### 8.3 自定义指令文件

可在 `opencode.json` 中指定额外指令文件（支持 glob 和远程 URL）：

```json
{
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md",
    "https://raw.githubusercontent.com/my-org/shared-rules/main/style.md"
  ]
}
```

### 8.4 当前工作目录 AGENTS.md

本项目的 `AGENTS.md`（`H:\test\AGENTS.md`）内容如下：

```markdown
# AGENTS.md

## Repository Overview

Minimal workspace for Jira integration targeting a Japanese printer/fax driver
project (project key `gd`). Contains no source code, build system, or version control.

## Key Facts

- **Not a Git repo.** No `.git` directory — do not assume git operations work.
- **No build/test/lint commands.** There is nothing to compile, test, or run.
- **Domain:** Telecommunications and print driver components (PCL, PS, PLW, XPS).
  Component names and descriptions use Japanese.
- **`jiraJsonInput.json`** is the only substantive file. It defines Jira project metadata:
  - `project`: Jira project key (`"gd"`)
  - `component`: list of driver component names, all prefixed with `[CD]`
  - `production`: deployment target (`"ci"`)
- **`cvasfas`** and **`veve.txt`** are empty placeholder files with no content.
```

---

## 9. 配置文件

OpenCode 的核心配置文件为 `opencode.json`，支持项目级（项目根目录）和全局级（`~/.config/opencode/opencode.json`）。

JSON Schema: `https://opencode.ai/config.json`

主要配置节：

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {},
  "mcp": {},
  "lsp": true,
  "plugin": [],
  "permission": {},
  "instructions": [],
  "tools": {}
}
```

---

## 10. 其他特性

- **多会话**: 同一项目上启动多个并行 Agent 会话
- **分享链接**: `/share` 命令创建可分享的会话链接
- **Undo/Redo**: `/undo` 撤销更改，`/redo` 重做
- **Plan/Build 模式**: Tab 键切换规划和构建模式
- **图片支持**: 拖放图片到终端添加到提示词
- **Zen**: OpenCode 提供精选的、经测试验证的模型列表（[opencode.ai/zen](https://opencode.ai/zen)）
- **ACP 支持**: 兼容 Agent Context Protocol
- **SDK**: 提供 TypeScript SDK 用于插件开发