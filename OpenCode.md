# OpenCode 完全指南

> OpenCode 是一款开源 AI 编程 Agent，支持终端 TUI、桌面应用和 IDE 扩展。拥有 160K+ GitHub Stars、900+ 贡献者，每月超过 750 万开发者使用。

---

## 目录

- [1. 基础信息](#1-基础信息)
  - [1.1 安装](#11-安装)
  - [1.2 配置 Provider](#12-配置-provider)
  - [1.3 初始化项目](#13-初始化项目)
  - [1.4 基本使用](#14-基本使用)
  - [1.5 配置文件](#15-配置文件)
- [2. 系统会话 (Session)](#2-系统会话-session)
  - [2.1 Plan 模式与 Build 模式](#21-plan-模式与-build-模式)
  - [2.2 分享会话](#22-分享会话)
  - [2.3 上下文压缩](#23-上下文压缩compaction)
  - [2.4 快照与撤销](#24-快照与撤销)
- [3. 提示词和 Context](#3-提示词和-context)
  - [3.1 AGENTS.md](#31-agentsmd)
  - [3.2 自定义指令 (instructions)](#32-自定义指令-instructions)
  - [3.3 上下文优先级](#33-上下文优先级)
- [4. Agent（代理）](#4-agent代理)
  - [4.1 Agent 类型](#41-agent-类型)
  - [4.2 内置 Agent](#42-内置-agent)
  - [4.3 配置 Agent](#43-配置-agent)
  - [4.4 Agent 权限](#44-agent-权限permission)
  - [4.5 创建自定义 Agent](#45-创建自定义-agent)
  - [4.6 使用 Agent](#46-使用-agent)
- [5. Skill（技能）](#5-skill技能)
  - [5.1 概述](#51-概述)
  - [5.2 放置 SKILL.md](#52-放置-skillmd)
  - [5.3 编写 SKILL.md](#53-编写-skillmd)
  - [5.4 技能发现机制](#54-技能发现机制)
  - [5.5 权限控制](#55-权限控制)
- [6. MCP（Model Context Protocol）](#6-mcpmodel-context-protocol)
  - [6.1 概述](#61-概述)
  - [6.2 本地 MCP 服务器](#62-本地-mcp-服务器)
  - [6.3 远程 MCP 服务器](#63-远程-mcp-服务器)
  - [6.4 OAuth 认证](#64-oauth-认证)
  - [6.5 管理 MCP 工具](#65-管理-mcp-工具)
  - [6.6 常见 MCP 示例](#66-常见-mcp-示例)
- [7. LSP（Language Server Protocol）](#7-lsplanguage-server-protocol)
  - [7.1 概述](#71-概述)
  - [7.2 内置 LSP 支持](#72-内置-lsp-支持)
  - [7.3 启用和配置](#73-启用和配置)
  - [7.4 自定义 LSP 服务器](#74-自定义-lsp-服务器)
  - [7.5 LSP 工具](#75-lsp-工具)
- [8. Plugin（插件）](#8-plugin插件)
  - [8.1 概述](#81-概述)
  - [8.2 使用插件](#82-使用插件)
  - [8.3 创建插件](#83-创建插件)
  - [8.4 插件事件](#84-插件事件)
  - [8.5 插件示例](#85-插件示例)
- [9. 工作目录下的 AGENTS.md](#9-工作目录下的-agentsmd)
  - [9.1 AGENTS.md 的作用](#91-agentsmd-的作用)
  - [9.2 创建 AGENTS.md](#92-创建-agentsmd)
  - [9.3 AGENTS.md 编写最佳实践](#93-agentsmd-编写最佳实践)
  - [9.4 多层级 AGENTS.md](#94-多层级-agentsmd)
  - [9.5 兼容性](#95-兼容性claude-code)
  - [9.6 引用外部文件](#96-引用外部文件)
- [10. OpenCode 与 Chat 的区别](#10-opencode-与-chat-的区别)
  - [10.1 核心定位不同](#101-核心定位不同)
  - [10.2 交互模式](#102-交互模式)
  - [10.3 上下文感知能力](#103-上下文感知能力)
  - [10.4 工具与环境集成](#104-工具与环境集成)
  - [10.5 Agent 架构](#105-agent-架构)
  - [10.6 可扩展性](#106-可扩展性)
  - [10.7 权限与安全](#107-权限与安全)
  - [10.8 对比总结](#108-对比总结)

---

## 1. 基础信息

### 1.1 安装

```bash
# 推荐安装方式
curl -fsSL https://opencode.ai/install | bash

# 也可以通过 npm
npm install -g opencode-ai

# macOS / Linux 通过 Homebrew
brew install anomalyco/tap/opencode

# Arch Linux
sudo pacman -S opencode

# Windows 通过 Chocolatey / Scoop
choco install opencode
scoop install opencode
```

### 1.2 配置 Provider

运行 `/connect` 命令，选择 provider 并输入 API Key。推荐使用 [OpenCode Zen](https://opencode.ai/docs/zen/)（经过验证的模型列表），也支持 75+ LLM 提供商（Anthropic、OpenAI、Google Gemini 等）。

```json
// opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "anthropic": {
      "options": {
        "apiKey": "{env:ANTHROPIC_API_KEY}"
      }
    }
  },
  "model": "anthropic/claude-sonnet-4-20250514"
}
```

### 1.3 初始化项目

```bash
cd /path/to/project
opencode
/init
```

`/init` 会扫描项目结构，生成 `AGENTS.md` 文件，帮助 OpenCode 理解项目约定。

### 1.4 基本使用

| 操作 | 说明 |
|------|------|
| 提问 | 直接输入问题，如 `How is auth handled in @src/api/index.ts` |
| `@` 引用 | 用 `@` 键模糊搜索并引用项目文件 |
| Tab 切换模式 | `Tab` 键在 Build/Plan 模式间切换 |
| `/undo` | 撤销最近的 Agent 修改 |
| `/redo` | 重做已撤销的修改 |
| `/share` | 分享当前会话链接 |

### 1.5 配置文件

OpenCode 配置使用 JSON/JSONC 格式，支持多层合并且按优先级从低到高：

| 优先级 | 位置 | 说明 |
|--------|------|------|
| 1 (最低) | 远程 `.well-known/opencode` | 组织级默认配置 |
| 2 | `~/.config/opencode/opencode.json` | 全局用户配置 |
| 3 | `OPENCODE_CONFIG` 环境变量指定路径 | 自定义配置覆盖 |
| 4 | 项目根目录 `opencode.json` | 项目级配置 |
| 5 | `.opencode/` 目录下的子配置 | agents、commands、plugins 等 |
| 6 | `OPENCODE_CONFIG_CONTENT` 环境变量 | 运行时覆盖 |
| 7 (最高) | 托管配置文件 / macOS MDM | 管理员强制策略 |

配置文件支持变量替换：
- `{env:VARIABLE_NAME}` — 引用环境变量
- `{file:path/to/file}` — 引用文件内容

---

## 2. 系统会话 (Session)

### 2.1 Plan 模式与 Build 模式

OpenCode 内置两个主要会话模式，通过 **Tab** 键切换：

- **Build 模式**（默认）：拥有所有工具权限，可以直接编辑文件和执行命令
- **Plan 模式**：`edit` 和 `bash` 默认设为 `ask`/`deny`，仅分析代码、建议修改，不做任何实际变更

### 2.2 分享会话

```
/share
```

创建当前对话的链接并复制到剪贴板。会话默认不共享，需手动操作。

### 2.3 上下文压缩（Compaction）

当会话上下文达到模型 token 上限时，OpenCode 会自动压缩历史消息，保留核心信息。

```json
{
  "compaction": {
    "auto": true,
    "prune": true,
    "reserved": 10000
  }
}
```

- `auto` — 上下文满时自动压缩（默认 `true`）
- `prune` — 移除旧工具输出以节省 token（默认 `true`）
- `reserved` — 压缩预留 token 缓冲区

可通过 Plugin 的 `experimental.session.compacting` 钩子自定义压缩行为。

### 2.4 快照与撤销

OpenCode 使用快照跟踪 Agent 操作期间的文件变更，支持会话内撤销（`/undo`）和重做（`/redo`）。

```json
{
  "snapshot": false
}
```

禁用快照后，Agent 所做变更将无法通过 UI 回滚。

---

## 3. 提示词和 Context

OpenCode 的提示词系统由以下部分组成，它们共同构成 LLM 的完整上下文：

### 3.1 AGENTS.md

`AGENTS.md` 是 OpenCode 最重要的提示词文件，用于定义项目级指令。内容包括：
- 构建和测试命令
- 代码规范和架构说明
- 项目特定的约定和注意事项

OpenCode 启动时自动加载 `AGENTS.md` 并注入到 system prompt 中。

### 3.2 自定义指令 (instructions)

在 `opencode.json` 中通过 `instructions` 字段引用额外的指令文件：

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

支持 glob 模式和远程 URL。所有指令文件与 `AGENTS.md` 合并构成完整上下文。

### 3.3 上下文优先级

OpenCode 加载规则文件的顺序（优先级从高到低，同一类别中首个匹配的文件生效）：

1. **本地文件** — 从当前目录向上遍历（`AGENTS.md` > `CLAUDE.md`）
2. **全局文件** — `~/.config/opencode/AGENTS.md`
3. **Claude Code 兼容** — `~/.claude/CLAUDE.md`（可禁用）
4. **instructions 配置** — `opencode.json` 中的 `instructions` 数组

此外，Agent 的 `prompt` 字段和 Skill 内容也会按需注入到上下文中。

---

## 4. Agent（代理）

### 4.1 Agent 类型

| 类型 | 模式 | 说明 |
|------|------|------|
| Primary | `primary` | 主交互代理，可通过 **Tab** 键切换 |
| Subagent | `subagent` | 被主代理通过 Task 工具调用，也可通过 `@` 手动唤起 |

### 4.2 内置 Agent

| Agent | 模式 | 说明 |
|-------|------|------|
| **Build** | primary | 默认代理，拥有所有工具权限，用于开发工作 |
| **Plan** | primary | 限制模式，`edit` 和 `bash` 需审批/禁用，仅分析和建议 |
| **General** | subagent | 通用代理，用于复杂多步骤任务，除 todo 外拥有全部工具 |
| **Explore** | subagent | 只读快速搜索代理，不能修改文件 |
| **Scout** | subagent | 只读代理，用于查阅外部文档和依赖源码 |
| **Compaction** | primary (hidden) | 系统隐藏代理，自动压缩长上下文 |
| **Title** | primary (hidden) | 系统隐藏代理，自动生成会话标题 |
| **Summary** | primary (hidden) | 系统隐藏代理，自动创建会话摘要 |

### 4.3 配置 Agent

**JSON 配置**（`opencode.json`）：

```json
{
  "agent": {
    "build": {
      "mode": "primary",
      "model": "anthropic/claude-sonnet-4-20250514",
      "prompt": "{file:./prompts/build.txt}",
      "permission": {
        "edit": "allow",
        "bash": "allow"
      }
    },
    "code-reviewer": {
      "description": "Reviews code for best practices",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "permission": {
        "edit": "deny"
      }
    }
  }
}
```

**Markdown 配置**（`.opencode/agents/review.md`）：

```markdown
---
description: Code review without edits
mode: subagent
model: anthropic/claude-sonnet-4-20250514
permission:
  edit: deny
  bash:
    "*": ask
    "git diff": allow
---

You are a code reviewer. Focus on security, performance, and maintainability.
```

**Agent 完整配置项**：

| 字段 | 说明 |
|------|------|
| `description` | 代理功能描述（必填） |
| `mode` | `primary` / `subagent` / `all` |
| `prompt` | 自定义系统提示词文件路径 |
| `model` | 覆盖使用的模型 ID |
| `temperature` | 控制输出随机性（0.0-1.0） |
| `top_p` | 控制输出多样性（0.0-1.0） |
| `steps` | 最大 Agent 迭代步数 |
| `permission` | 工具权限配置 |
| `hidden` | 隐藏代理（仅对 subagent 生效） |
| `color` | UI 显示颜色 |
| `disable` | 禁用代理 |

### 4.4 Agent 权限（Permission）

权限值：`allow`（允许）、`ask`（询问）、`deny`（禁止）

| 权限 Key | 管控的工具 |
|-----------|------------|
| `read` | `read` |
| `edit` | `write`, `edit`, `apply_patch` |
| `glob` | `glob` |
| `grep` | `grep` |
| `list` | `list` |
| `bash` | `bash`（支持 glob 模式匹配特定命令） |
| `task` | `task`（控制可调用的子代理） |
| `external_directory` | 项目外文件读写 |
| `todowrite` | `todowrite`, `todoread` |
| `webfetch` | `webfetch` |
| `websearch` | `websearch` |
| `lsp` | `lsp` |
| `skill` | `skill` |
| `question` | `question` |
| `doom_loop` | 卡住时的恢复提示 |

```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status *": "allow"
    },
    "edit": "deny"
  }
}
```

### 4.5 创建自定义 Agent

```bash
opencode agent create
```

交互式命令将引导你选择保存位置、描述功能、生成提示词、选择权限，并创建 Markdown 文件。

### 4.6 使用 Agent

- **Primary Agent**：按 `Tab` 键切换
- **Subagent**：在消息中 `@agent-name` 唤起，如 `@general help me search for this function`
- **子会话导航**：`<Leader>+Down` 进入子会话，`Right`/`Left` 切换子会话，`Up` 返回父会话

---

## 5. Skill（技能）

### 5.1 概述

Skill 是通过 `SKILL.md` 定义的**可复用指令模块**。Agent 通过 `skill` 工具按需加载技能内容。技能不会自动注入到上下文中，只有当 Agent 判断需要时才会加载。

### 5.2 放置 SKILL.md

每个技能一个文件夹，内含 `SKILL.md`：

```
.opencode/skills/<name>/SKILL.md     # 项目级
~/.config/opencode/skills/<name>/SKILL.md  # 全局
.claude/skills/<name>/SKILL.md      # Claude Code 兼容
.agents/skills/<name>/SKILL.md      # Agent 兼容
```

### 5.3 编写 SKILL.md

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
- Provide a copy-pasteable `gh release create` command

## When to use me
Use this when you are preparing a tagged release.
```

**Frontmatter 字段**：
- `name`（必填）— 小写字母数字+连字符，1-64 字符，需与目录名一致
- `description`（必填）— 1-1024 字符
- `license`（可选）
- `compatibility`（可选）
- `metadata`（可选，string→string 映射）

### 5.4 技能发现机制

- 项目本地路径：从当前工作目录向上遍历到 git worktree，加载 `.opencode/skills/*/SKILL.md`、`.claude/skills/*/SKILL.md`、`.agents/skills/*/SKILL.md`
- 全局路径：`~/.config/opencode/skills/*/SKILL.md` 等
- Agent 看到可用技能列表并按需通过 `skill({ name: "git-release" })` 加载

### 5.5 权限控制

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "pr-review": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

| 权限 | 行为 |
|------|------|
| `allow` | 立即加载 |
| `deny` | 对 Agent 隐藏，拒绝访问 |
| `ask` | 用户审批后加载 |

可在 Agent 级别覆盖全局权限。可通过 `tools: { skill: false }` 完全禁用技能工具。

---

## 6. MCP（Model Context Protocol）

### 6.1 概述

MCP 是开放标准协议，允许 OpenCode 接入外部工具和服务。MCP 工具添加后自动可供 LLM 使用，与内置工具并存。

> **注意**：MCP 服务器会增加上下文 token 数量，建议谨慎选择启用的服务器。

### 6.2 本地 MCP 服务器

```jsonc
{
  "mcp": {
    "my-local-mcp": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-command"],
      "enabled": true,
      "environment": {
        "MY_ENV_VAR": "my_env_var_value"
      }
    }
  }
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `type` | string | 是 | 必须为 `"local"` |
| `command` | string[] | 是 | 启动 MCP 的命令和参数 |
| `environment` | object | 否 | 环境变量 |
| `enabled` | boolean | 否 | 启用/禁用 |
| `timeout` | number | 否 | 工具获取超时（ms），默认 5000 |

### 6.3 远程 MCP 服务器

```json
{
  "mcp": {
    "my-remote-mcp": {
      "type": "remote",
      "url": "https://my-mcp-server.com",
      "enabled": true,
      "headers": {
        "Authorization": "Bearer MY_API_KEY"
      }
    }
  }
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `type` | string | 是 | 必须为 `"remote"` |
| `url` | string | 是 | 远程 MCP 服务器 URL |
| `enabled` | boolean | 否 | 启用/禁用 |
| `headers` | object | 否 | 请求头 |
| `oauth` | object/false | 否 | OAuth 配置，`false` 禁用 |
| `timeout` | number | 否 | 超时（ms），默认 5000 |

### 6.4 OAuth 认证

远程 MCP 支持 OAuth 自动认证：

```bash
# 否动 OAuth 流程
opencode mcp auth <server-name>

# 查看认证状态
opencode mcp list

# 移除凭据
opencode mcp logout <server-name>
```

预注册客户端凭据：

```json
{
  "mcp": {
    "my-oauth-server": {
      "type": "remote",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "clientId": "{env:MY_MCP_CLIENT_ID}",
        "clientSecret": "{env:MY_MCP_CLIENT_SECRET}",
        "scope": "tools:read tools:execute"
      }
    }
  }
}
```

### 6.5 管理 MCP 工具

MCP 工具注册时以服务器名为前缀（如 `mymcp_search`），可通过 `tools` 配置全局启用/禁用：

```json
{
  "mcp": {
    "my-mcp": { "type": "local", "command": ["bun", "x", "my-mcp"] }
  },
  "tools": {
    "my-mcp*": false
  },
  "agent": {
    "my-agent": {
      "tools": { "my-mcp*": true }
    }
  }
}
```

### 6.6 常见 MCP 示例

**Sentry**：
```json
{
  "mcp": {
    "sentry": {
      "type": "remote",
      "url": "https://mcp.sentry.dev/mcp",
      "oauth": {}
    }
  }
}
```

**Context7**（文档搜索）：
```json
{
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

**Grep by Vercel**（GitHub 代码搜索）：
```json
{
  "mcp": {
    "gh_grep": {
      "type": "remote",
      "url": "https://mcp.grep.app"
    }
  }
}
```

---

## 7. LSP（Language Server Protocol）

### 7.1 概述

OpenCode 可集成 LSP 服务器，将语言诊断信息（类型错误、语法错误等）作为反馈提供给 Agent。LSP 默认禁用，启用后会在检测到对应文件扩展名时自动启动。

### 7.2 内置 LSP 支持

| LSP 服务器 | 文件扩展名 | 要求 |
|---|---|---|
| astro | `.astro` | Astro 项目自动安装 |
| bash | `.sh`, `.bash`, `.zsh` | 自动安装 bash-language-server |
| clangd | `.c`, `.cpp`, `.h` 等 | C/C++ 项目自动安装 |
| csharp | `.cs` | .NET SDK |
| clojure-lsp | `.clj`, `.cljs` | clojure-lsp 可用 |
| dart | `.dart` | dart 可用 |
| deno | `.ts`, `.tsx`, `.js` | deno 可用（自动检测 deno.json） |
| elixir-ls | `.ex`, `.exs` | elixir 可用 |
| eslint | `.ts`, `.tsx`, `.js` 等 | eslint 依赖 |
| gopls | `.go` | go 可用 |
| hls | `.hs` | haskell-language-server 可用 |
| jdtls | `.java` | Java SDK 21+ |
| julials | `.jl` | julia + LanguageServer.jl |
| kotlin-ls | `.kt`, `.kts` | Kotlin 项目自动安装 |
| lua-ls | `.lua` | Lua 项目自动安装 |
| nixd | `.nix` | nixd 可用 |
| ocaml-lsp | `.ml`, `.mli` | ocamllsp 可用 |
| oxlint | `.ts`, `.tsx`, `.js` 等 | oxlint 依赖 |
| php intelephense | `.php` | PHP 项目自动安装 |
| prisma | `.prisma` | prisma 可用 |
| pyright | `.py`, `.pyi` | pyright 安装 |
| ruby-lsp | `.rb`, `.rake` | ruby + gem 可用 |
| rust | `.rs` | rust-analyzer 可用 |
| sourcekit-lsp | `.swift`, `.objc` | swift 安装 |
| svelte | `.svelte` | Svelte 项目自动安装 |
| terraform | `.tf`, `.tfvars` | 自动从 GitHub 安装 |
| tinymist | `.typ`, `.typc` | 自动从 GitHub 安装 |
| typescript | `.ts`, `.tsx`, `.js` 等 | typescript 依赖 |
| vue | `.vue` | Vue 项目自动安装 |
| yaml-ls | `.yaml`, `.yml` | 自动安装 Red Hat yaml-ls |
| zls | `.zig`, `.zon` | zig 可用 |

### 7.3 启用和配置

```json
// 启用所有内置 LSP
{ "lsp": true }

// 启用并自定义
{
  "lsp": {
    "rust": {
      "command": ["rust-analyzer"],
      "env": { "RUST_LOG": "debug" }
    },
    "typescript": { "disabled": true }
  }
}

// 禁用所有
{ "lsp": false }
```

可通过 `OPENCODE_DISABLE_LSP_DOWNLOAD=true` 禁止自动下载 LSP。

### 7.4 自定义 LSP 服务器

```json
{
  "lsp": {
    "custom-lsp": {
      "command": ["custom-lsp-server", "--stdio"],
      "extensions": [".custom"],
      "initialization": {
        "preferences": {
          "importModuleSpecifierPreference": "relative"
        }
      }
    }
  }
}
```

### 7.5 LSP 工具

启用 LSP 后，`lsp` 工具可用（需设置 `OPENCODE_EXPERIMENTAL_LSP_TOOL=true`）：

- `goToDefinition` — 跳转定义
- `findReferences` — 查找引用
- `hover` — 悬停信息
- `documentSymbol` — 文档符号
- `workspaceSymbol` — 工作区符号
- `goToImplementation` — 跳转实现
- `prepareCallHierarchy` — 调用层级
- `incomingCalls` / `outgoingCalls` — 调用链

---

## 8. Plugin（插件）

### 8.1 概述

Plugin 允许你通过事件钩子扩展 OpenCode 的行为，例如添加自定义工具、注入环境变量、发送通知等。

### 8.2 使用插件

**本地插件**：放置在 `.opencode/plugins/`（项目级）或 `~/.config/opencode/plugins/`（全局），自动加载。

**npm 插件**：在 `opencode.json` 中声明：

```json
{
  "plugin": ["opencode-helicone-session", "opencode-wakatime", "@my-org/custom-plugin"]
}
```

**加载顺序**：
1. 全局配置 (`~/.config/opencode/opencode.json`)
2. 项目配置 (`opencode.json`)
3. 全局插件目录 (`~/.config/opencode/plugins/`)
4. 项目插件目录 (`.opencode/plugins/`)

### 8.3 创建插件

插件是一个导出函数的 JavaScript/TypeScript 模块：

```typescript
import { type Plugin, tool } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    // 钩子实现
  }
}
```

参数说明：
- `project` — 当前项目信息
- `directory` — 当前工作目录
- `worktree` — git worktree 路径
- `client` — OpenCode SDK 客户端
- `$` — Bun Shell API

插件依赖放在 `.opencode/package.json` 中，启动时自动 `bun install`。

### 8.4 插件事件

| 类别 | 事件名 |
|------|--------|
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
| 工具 | `tool.execute.after`, `tool.execute.before` |
| TUI | `tui.prompt.append`, `tui.command.execute`, `tui.toast.show` |

### 8.5 插件示例

**通知插件**：

```javascript
export const NotificationPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await $`osascript -e 'display notification "Session completed!" with title "opencode"'`
      }
    },
  }
}
```

**添加自定义工具**：

```typescript
import { type Plugin, tool } from "@opencode-ai/plugin"

export const CustomToolsPlugin: Plugin = async (ctx) => {
  return {
    tool: {
      mytool: tool({
        description: "This is a custom tool",
        args: { foo: tool.schema.string() },
        async execute(args, context) {
          return `Hello ${args.foo} from ${context.directory}`
        },
      }),
    },
  }
}
```

---

## 9. 工作目录下的 AGENTS.md

### 9.1 AGENTS.md 的作用

`AGENTS.md` 是 OpenCode 的核心提示词文件，类似于 Cursor 的规则文件。它包含项目级的指令，会自动注入到 LLM 的 system prompt 中，用于定制 Agent 对特定项目的行为。

推荐将 `AGENTS.md` 提交到 Git 仓库，与团队共享。

### 9.2 创建 AGENTS.md

**方式一：使用 `/init` 命令**

```bash
opencode
/init
```

`/init` 命令会扫描项目文件，可能提出针对性问题，然后生成或更新 `AGENTS.md`。它关注：
- 构建、lint、测试命令
- 命令执行顺序和验证步骤
- 不明显的架构和仓库结构
- 项目特有约定、配置诀窍和操作陷阱
- 已有的指令引用（如 Cursor/Copilot 规则）

**方式二：手动创建**

直接在项目根目录创建 `AGENTS.md` 文件。

### 9.3 AGENTS.md 编写最佳实践

```markdown
# 项目名称与简介

简要描述项目技术栈和用途。

## 项目结构

- `packages/core/` — 核心共享代码
- `packages/functions/` — Serverless 函数
- `infra/` — 基础设施定义
- `sst.config.ts` — SST 配置

## 开发命令

- `bun install` — 安装依赖
- `bun run dev` — 启动开发服务器
- `bun run test` — 运行测试
- `bun run lint` — 代码检查
- `bun run typecheck` — 类型检查

## 代码规范

- 使用 TypeScript strict 模式
- 共享代码放在 `packages/core/` 中并正确导出
- 函数放在 `packages/functions/` 中
- 基础设施定义拆分为 `infra/` 下的独立文件

## 注意事项

- 测试时必须先运行 `bun run typecheck`
- 不要修改 `.env` 文件
- 提交前运行 `bun run lint && bun run test`
```

### 9.4 多层级 AGENTS.md

| 位置 | 作用范围 | 用途 |
|------|----------|------|
| 项目根目录 `AGENTS.md` | 当前项目 | 项目级规则，建议提交 Git |
| `~/.config/opencode/AGENTS.md` | 所有项目 | 全局个人规则，不共享 |
| 子目录 `AGENTS.md` | 子目录及其下级 | 子模块/包级规则 |

OpenCode 从当前工作目录向上遍历到 Git worktree 根目录加载所有匹配的规则文件。同目录下如果同时存在 `AGENTS.md` 和 `CLAUDE.md`，仅加载 `AGENTS.md`。

### 9.5 兼容性（Claude Code）

OpenCode 兼容 Claude Code 的文件约定：
- 项目规则：`CLAUDE.md`（如无 `AGENTS.md` 时使用）
- 全局规则：`~/.claude/CLAUDE.md`（如无 `~/.config/opencode/AGENTS.md` 时使用）
- 技能：`~/.claude/skills/`（参见 Skill 章节）

禁用兼容性：

```bash
export OPENCODE_DISABLE_CLAUDE_CODE=1        # 禁用所有 .claude 支持
export OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1  # 仅禁用 ~/.claude/CLAUDE.md
export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1  # 仅禁用 .claude/skills
```

### 9.6 引用外部文件

**推荐方式：在 `opencode.json` 中配置**：

```json
{
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md",
    "packages/*/AGENTS.md"
  ]
}
```

**手动方式：在 AGENTS.md 中声明**：

```markdown
## External File Loading

CRITICAL: When you encounter a file reference (e.g., @rules/general.md),
use your Read tool to load it on a need-to-know basis.

Instructions:
- Do NOT preemptively load all references
- When loaded, treat content as mandatory instructions
- Follow references recursively when needed

## Development Guidelines

For TypeScript code style: @docs/typescript-guidelines.md
For React patterns: @docs/react-patterns.md
```

---

## 附录：OpenCode 内置工具一览

| 工具 | 说明 | 权限 Key |
|------|------|-----------|
| `bash` | 执行 Shell 命令 | `bash` |
| `edit` | 精确字符串替换编辑文件 | `edit` |
| `write` | 创建/覆盖文件 | `edit` |
| `read` | 读取文件内容 | `read` |
| `grep` | 正则搜索文件内容 | `grep` |
| `glob` | 模式匹配搜索文件 | `glob` |
| `apply_patch` | 应用补丁文件 | `edit` |
| `skill` | 按需加载技能 | `skill` |
| `todowrite` / `todoread` | 任务列表管理 | `todowrite` |
| `webfetch` | 获取网页内容 | `webfetch` |
| `websearch` | Exa AI 网页搜索 | `websearch` |
| `question` | 向用户提问 | `question` |
| `lsp` | LSP 代码智能（实验性） | `lsp` |
| MCP 工具 | 外部工具（以服务器名为前缀） | 按名称匹配 |

---

## 10. OpenCode 与 Chat 的区别

### 10.1 核心定位不同

| 维度 | Chat（ChatGPT / Claude Web 等） | OpenCode |
|------|------|------|
| 核心定位 | 通用对话助手 | 编程专用 Agent |
| 使用场景 | 问答、写作、翻译、头脑风暴 | 代码编写、调试、重构、项目级开发 |
| 工作环境 | 浏览器中的沙盒 | 你的本地项目目录、终端、IDE |
| 输出形式 | 纯文本回复 | 文本回复 + **直接执行操作**（编辑文件、运行命令、搜索代码） |

Chat 类产品本质上是**对话接口**——你提问，它回答，所有操作都停留在文本层。OpenCode 则是**行动型 Agent**——它不仅回答问题，更能直接在你的代码库中执行修改、运行测试、搜索文件，并将结果反馈回对话循环。

### 10.2 交互模式

```
┌──────────────────────────────────────────────────┐
│  Chat                                            │
│                                                  │
│  用户 → 提问 → LLM → 文本回复 → 用户复制/粘贴   │
│                                                  │
│  单轮：一问一答，行动依赖人工搬运                 │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│  OpenCode                                        │
│                                                  │
│  用户 → 指令 → Agent → 调用工具链                 │
│                         ├→ 读文件 → 修改代码      │
│                         ├→ 运行命令 → 分析输出    │
│                         ├→ 搜索代码 → 定位问题    │
│                         └→ LSP 诊断 → 修正错误    │
│           ← 结果反馈 ← ← ← ← ← ← ← ← ←       │
│                                                  │
│  多轮：Agent 自主迭代直到任务完成                 │
└──────────────────────────────────────────────────┘
```

**关键区别**：

- **Chat**：你问、它答，需要你手动将建议应用到代码中
- **OpenCode**：Agent 自主规划、执行、验证、迭代，形成完整工作流

### 10.3 上下文感知能力

| 能力 | Chat | OpenCode |
|------|------|------|
| 获取项目结构 | 需要你手动粘贴信息 | `glob`、`grep` 工具自动扫描 |
| 读取源代码 | 粘贴代码片段，易遗漏 | `read` 工具精确读取任意文件 |
| 理解项目约定 | 需要你反复告知 | `AGENTS.md` + Skill 自动注入 |
| 跨文件关联 | 需要你提供上下文 | LSP go-to-definition / find-references |
| 持续对话记忆 | 有限，新会话丢失 | `AGENTS.md`、Skill、`instructions` 持久化上下文 |
| 多文件编辑 | 逐个给出代码块 | `edit`/`write`/`apply_patch` 批量修改 |
| 运行结果验证 | 无法执行，只能推测 | `bash` 工具实际运行 lint/test/typecheck |

**示例**：当你对 Chat 说 "修复这个 bug"，你需要先粘贴代码、解释上下文、然后手动应用修复。而 OpenCode 可以：

1. 用 `grep` 搜索相关错误模式
2. 用 `read` 打开相关文件
3. 用 `edit` 直接修复
4. 用 `bash` 运行测试验证
5. 用 LSP 诊断确认无新错误

### 10.4 工具与环境集成

Chat 工具的生态系统通常是**封闭的插件平台**，而 OpenCode 提供了多层次的开放集成：

| 集成层 | Chat | OpenCode |
|--------|------|------|
| 文件系统 | 无法直接访问 | `read`/`edit`/`write`/`glob` |
| Shell 命令 | 无法执行 | `bash` 工具直接运行 |
| 语言服务 | 无 | 内置 30+ LSP 服务器 |
| 外部工具 | 受限的插件市场 | MCP 协议接入任意服务（Sentry、Context7、数据库等） |
| 版本控制 | 无法操作 git | `bash` 直接执行 git 命令 + `/undo` 快照回滚 |
| 自定义扩展 | 有限 | Plugin SDK + Custom Tools + Skill 系统 |
| 团队协作 | 分享对话链接 | `/share` + 可提交 Git 的 `AGENTS.md` 实现团队共享 |

**MCP 的意义**：Chat 的插件是平台控制的；OpenCode 的 MCP 是开放标准——你可以连接数据库、Issue Tracker、文档搜索、内部 API 等任何服务，工具注册后自动可供 LLM 调用。

### 10.5 Agent 架构

| 特性 | Chat | OpenCode |
|------|------|------|
| 代理类型 | 单一对话模型 | Primary Agent + Subagent 多层架构 |
| 角色切换 | 需要手动切换 System Prompt | `Tab` 一键切换 Build/Plan 模式 |
| 子任务委派 | 不支持 | Task 工具自动委派子代理（Explore/Scout/General） |
| 权限控制 | 全有或全无 | 细粒度权限：`allow`/`ask`/`deny`，可按工具/命令/Agent 配置 |
| 迭代步数 | 由模型自行决定 | `steps` 限制最大迭代次数，控制成本 |
| 模型选择 | 固定提供商 | 75+ 提供商任意切换，Agent 可指定不同模型 |
| 并发能力 | 单线程对话 | 多会话并行 |

**Subagent 示例**：

```
你: "审查这段代码的安全性和性能"

OpenCode (Build Agent):
  → 委派 @general 执行多步骤安全审计
  → 委派 @explore 搜索相似代码模式
  → 委派 @scout 查阅外部依赖文档
  ← 汇总结果返回给你
```

在 Chat 中，你需要手动拆分任务、分别提问再手动整合。

### 10.6 可扩展性

| 扩展方式 | Chat | OpenCode |
|----------|------|------|
| 自定义提示词 | System Prompt / Custom Instructions | `AGENTS.md` + `instructions` + Skill + Agent `prompt` |
| 项目级规则 | 手动粘贴或 Custom GPT Instructions | `AGENTS.md` 提交 Git，团队共享 |
| 技能复用 | Custom GPT（平台锁定） | Skill（Markdown 文件，可跨项目共享） |
| 新工具 | 等平台开发插件 | MCP 协议自行接入 / Plugin SDK 开发 |
| 代码智能 | 无 | LSP 集成提供实时诊断 |
| 工作流自动化 | 不支持 | Plugin 钩子系统（文件编辑、会话、工具调用等事件） |
| 团队标准化 | 仅靠口头约定 | `AGENTS.md` + `opencode.json` + Plugin 实现强制规则 |

**核心差异**：Chat 的可扩展性受限于平台提供的功能；OpenCode 的每一层（工具、Agent、Skill、Plugin、LSP、MCP）都可以由开发者自行定义和扩展。

### 10.7 权限与安全

| 安全维度 | Chat | OpenCode |
|----------|------|------|
| 数据隐私 | 对话内容上传到云服务商 | 代码和上下文不存储（隐私优先设计） |
| 操作审批 | 无法真正执行操作，不存在此问题 | `permission` 系统逐工具控制（`allow`/`ask`/`deny`） |
| 命令级控制 | N/A | `bash` 权限支持 glob 模式（如 `git status *` 允许、`git push` 需审批） |
| 文件保护 | N/A | `external_directory` 权限控制项目外文件访问 |
| 策略管理 | N/A | `policies` 支持 deny/allow 特定 provider |
| 企业级管控 | 取决于平台付费计划 | MDM 托管配置、远程 `.well-known/opencode`、admin 强制策略 |

### 10.8 对比总结

```
Chat = 对话型助手
  ✓ 快速问答
  ✓ 创意写作
  ✓ 知识检索
  ✗ 无法操作你的代码库
  ✗ 无法运行命令
  ✗ 上下文需要手动搬运
  ✗ 扩展受限于平台

OpenCode = 行动型编程 Agent
  ✓ 直接读写文件、执行命令
  ✓ 自动搜索和理解代码库
  ✓ LSP 实时诊断反馈
  ✓ MCP/Plugin/Skill 多层扩展
  ✓ 多 Agent 协作架构
  ✓ 细粒度权限控制
  ✓ 团队标准化（AGENTS.md）
  ✓ 企业级隐私与管控
```

**一句话总结**：Chat 告诉你"应该怎么做"，OpenCode 直接"帮你做"。