# Phase 1A Codex 分轮开发脚本

## 总目标

将项目从原始的一键 V2Ray Docker 脚本，升级为一个：

- 可维护
- 可模板化
- 可 compose 化
- 可分支演进
- 可支持 Xray 多 transport profile

的现代化部署项目。

本阶段覆盖三条开发线：

1. `refactor-base`
2. `v2-ws-tls`
3. `v2-reality`

要求：
- 先做公共底座，再做协议分支
- 不允许在 `refactor-base` 提前写死协议逻辑
- 不允许让 `v2-reality` 继承 `ws-tls` 的历史包袱
- 所有配置必须模板化
- 优先保证代码结构清晰、职责分明、便于后续维护

---

# Round 0：项目审计与重构准备

## 目标
先完整审计原仓库结构、Dockerfile、启动脚本、配置文件、README 中的使用流程，形成重构基线。

## 给 Codex 的指令

你正在重构一个老的 Docker 一键部署项目。  
请先不要直接大改代码，先完成“审计 + 设计输出”。

任务要求：

1. 阅读并分析当前仓库中的以下内容：
   - `Dockerfile`
   - 启动脚本（如 `caddy.sh` 等）
   - 现有配置文件
   - README 中的启动命令和参数说明

2. 输出一份简洁的审计结论，至少包括：
   - 当前项目的目录结构问题
   - 参数系统问题
   - 硬编码项清单
   - 与未来 `refactor-base / v2-ws-tls / v2-reality` 三分支规划冲突的点
   - 哪些逻辑应下沉到公共底座
   - 哪些逻辑只能留给 transport 分支实现

3. 在仓库中新增以下文档（如不存在则创建）：
   - `doc/phase1a-audit.md`
   - `doc/phase1a-refactor-notes.md`

4. 不修改现有业务逻辑，不引入新协议，只输出审计结果和重构建议。

输出要求：
- 文档使用中文
- 结论清晰
- 以“问题 → 风险 → 重构建议”方式组织

完成后给出：
- 已新增/修改文件列表
- 核心审计结论摘要
- 下一轮建议

---

# Round 1：创建 refactor-base 分支并完成底座目录重构

## 目标
在 `refactor-base` 分支上完成项目底座重构，不引入具体协议改造。

## 给 Codex 的指令

请在 `refactor-base` 分支上完成第一轮底座重构。

约束：
- 本轮禁止引入 Xray / VLESS / REALITY 具体逻辑
- 本轮禁止写死 `ws`、`reality`、`/one`、`caddy 必需`
- 本轮只做“公共底座”

任务要求：

1. 重构目录结构，建议形成如下骨架：
```
.
├── compose.yaml
├── .env.example
├── scripts/
│   ├── preflight-check.sh
│   ├── render-config.sh
│   ├── start.sh
│   ├── status.sh
│   └── export-client.sh
├── templates/
│   ├── core/
│   ├── transport/
│   └── proxy/
├── data/
│   ├── runtime/
│   ├── exports/
│   └── logs/
└── doc/
```

2. 将原有“单体启动脚本”的职责拆分为多个原子脚本：

   * `preflight-check.sh`
   * `render-config.sh`
   * `start.sh`
   * `status.sh`

3. 迁移 README 中“长 docker run 命令”的思路，改为 compose-first 的结构，但本轮不要求最终协议配置可用。
> 原 README 中“长 docker run 命令”为：
> - `sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy  pengchujin/v2ray_ws:0.11 YOURDOMAIN.COM V2RAY_WS && sleep 3s && sudo docker logs v2ray`
> - `sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy  pengchujin/v2ray_ws:0.11 YOURDOMAIN.COM V2RAY_WS 0890b53a-e3d4-4726-bd2b-52574e8588c4 && sleep 3s && sudo docker logs v2ray`

4. 增加 `.env.example`，至少预留这些变量：

   * `PROFILE`
   * `DOMAIN`
   * `UUID`
   * `WS_PATH`
   * `NODE_NAME`
   * `XRAY_PORT`
   * `TLS_MODE`

5. 输出模板目录骨架，但模板可以先放占位内容，不要求完整协议实现。

6. 新增文档：

   * `doc/phase1a-refactor-structure.md`

7. 修改 `README.md`，使其能反映新的项目结构和 Phase 1A 的分支策略。

交付标准：

* 项目目录已经重构
* 脚本职责清晰
* `.env.example` 可读
* 不再依赖单一巨型入口脚本
* README 已切换到新架构表述

完成后请输出：

* 修改文件列表
* 当前目录树
* 本轮未完成事项
* 下一轮建议

---

# Round 2：实现 refactor-base 的参数系统与模板渲染框架

## 目标

在 `refactor-base` 中建立统一的参数加载、校验、模板渲染框架，为两个协议分支服务。

## 给 Codex 的指令

请继续在 `refactor-base` 分支开发。

本轮目标是实现“参数系统 + 模板渲染框架”，注意这仍然是公共底座，不是协议分支。

任务要求：

1. 实现统一的环境变量加载逻辑：

   * 从 `.env` 加载
   * 对关键变量做缺失检查
   * 输出清晰报错

2. 实现 `scripts/preflight-check.sh`，至少检查：

   * Docker 是否安装
   * Docker Compose 是否可用
   * 80/443 端口是否被占用
   * `DOMAIN` 是否为空
   * `UUID` 格式是否合法（如果提供）
   * `PROFILE` 是否在允许值中（如 `ws-tls` / `reality`）

3. 实现 `scripts/render-config.sh` 的基础框架：

   * 根据 `PROFILE` 选择模板目录
   * 将模板渲染到 `data/runtime/`
   * 保证不同 profile 后续可插拔

4. 模板系统要求：

   * 不允许硬编码 `/one`
   * 不允许在 base 中写死某协议配置
   * 使用占位变量表达未来的 transport 差异

5. 新增或完善文档：

   * `doc/phase1a-config-system.md`

6. 若合适，可增加一个简单的 shell 工具函数文件，如：

   * `scripts/lib/common.sh`

输出要求：

* 所有 shell 脚本尽量具备可读性
* 必要时加注释
* 处理错误返回码
* 不要引入过度复杂的工具链

完成后请输出：

* 关键脚本说明
* 支持的环境变量列表
* 预留给 `v2-ws-tls` / `v2-reality` 的扩展接口
* 下一轮建议

---

# Round 3：在 refactor-base 上完成 compose 化、日志与状态命令

## 目标

让 `refactor-base` 成为一个可运行、可检查、可维护的底座版本。

## 给 Codex 的指令

请继续在 `refactor-base` 分支开发。

本轮重点是：

* `compose.yaml`
* 状态命令
* 日志目录
* 启动流程标准化

任务要求：

1. 编写 `compose.yaml`：

   * 使用统一服务名
   * 挂载 `data/runtime`、`data/logs` 等目录
   * 预留 profile 扩展能力
   * 添加 `restart: unless-stopped`
   * 如适合，可加 healthcheck 占位

2. 实现 `scripts/start.sh`：

   * 调用 preflight-check
   * 调用 render-config
   * 执行 `docker compose up -d`

3. 实现 `scripts/status.sh`：

   * 输出容器状态
   * 输出关键日志位置
   * 给出常用排障提示

4. 规范日志目录：

   * `data/logs/`
   * `data/runtime/`
   * `data/exports/`

5. 更新文档：

   * `doc/phase1a-runtime.md`

6. README 中补充：

   * 启动流程
   * 状态检查
   * Phase 1A 的分支说明

交付标准：

* `refactor-base` 可以作为“公共底座版本”独立存在
* 项目已经不依赖原始的一条超长 docker 命令
* 可通过脚本标准化启动与检查

完成后输出：

* compose 设计说明
* 启动与状态流程说明
* 仍待各分支实现的能力清单

---

# Round 4：创建 v2-ws-tls 分支并实现 Xray + VLESS + WS + TLS

## 目标

从 `refactor-base` 切出 `v2-ws-tls`，完成第一条具体传输方案。

## 给 Codex 的指令

请从 `refactor-base` 分支切出 `v2-ws-tls` 分支，并在该分支上实现：

* Xray
* VLESS
* WS
* TLS

要求：

* 尽量保留原项目“域名 + 443 + 一键启动”的易用体验
* 允许使用反向代理层
* 但实现必须服从新的模板化与脚本化框架

任务要求：

1. 引入 Xray 运行时

   * 替换旧内核依赖
   * 保持项目结构与 `refactor-base` 一致

2. 在模板系统中新增/完善 `ws-tls` profile：

   * Xray 配置模板
   * transport 模板
   * 如需要，proxy/Caddy 模板

3. 使用 VLESS 代替 VMess：

   * UUID 认证
   * 合理的传输配置
   * 统一走模板渲染

4. 支持可配置的：

   * `DOMAIN`
   * `UUID`
   * `WS_PATH`
   * `NODE_NAME`
   * TLS 相关参数

5. 更新 `scripts/render-config.sh`，使其真正支持 `PROFILE=ws-tls`

6. 如需反向代理层，请保持目录与职责清晰，不要把所有逻辑塞回一个启动脚本

7. 输出文档：

   * `doc/phase1a-ws-tls.md`

8. 更新 README：

   * 增加 `v2-ws-tls` 使用说明
   * 写清楚该分支适用场景与配置方法

交付标准：

* `v2-ws-tls` 分支能够基于新架构运行
* 不复活老式单体脚本
* 不写死旧参数语义
* 配置模板化

完成后输出：

* 使用到的 profile 文件
* 关键配置说明
* 启动步骤
* 已知限制

---

# Round 5：对 v2-ws-tls 做自测与排障优化

## 目标

确保 `v2-ws-tls` 不是“只看起来能跑”，而是具备基本可用性和可排障性。

## 给 Codex 的指令

请继续在 `v2-ws-tls` 分支上进行自测与加固。

任务要求：

1. 检查并优化：

   * 配置渲染结果
   * 启动流程
   * volume 挂载
   * 端口暴露
   * TLS / 域名相关说明

2. 优化日志与状态输出：

   * 让 `status.sh` 能看懂关键状态
   * 输出实际使用到的配置路径
   * 给出常见问题定位建议

3. 对 README 和 `doc/phase1a-ws-tls.md` 增补：

   * 常见错误
   * 排障步骤
   * 部署前检查事项

4. 如必要，可新增：

   * `scripts/show-config.sh`
   * `scripts/show-env.sh`

交付标准：

* `v2-ws-tls` 分支文档完整度提升
* 自测流程清晰
* 基本排障路径可读

完成后输出：

* 自测清单
* 常见错误总结
* 建议是否可以作为第一个“可交付分支”

---

# Round 6：创建 v2-reality 分支并实现 Xray + VLESS + REALITY

## 目标

从 `refactor-base` 切出 `v2-reality`，实现 Reality 方案，并保持其独立性。

## 给 Codex 的指令

请从 `refactor-base` 切出 `v2-reality` 分支，并在该分支上实现：

* Xray
* VLESS
* REALITY

注意：

* 不允许让 `v2-reality` 继承 `v2-ws-tls` 的 transport 逻辑
* 不要为了复用而强行保留 ws path、caddy 必需、证书依赖等历史包袱
* 该分支应视为独立 transport profile 的实现

任务要求：

1. 在模板系统中新增/完善 `reality` profile：

   * reality 配置模板
   * 所需密钥/参数生成逻辑
   * profile 专属变量校验

2. 处理与 ws-tls 不同的运行依赖：

   * 如不需要反向代理层，应保持启动流程简洁
   * 如不需要传统 TLS 证书，则文档中明确说明

3. 更新 `scripts/render-config.sh`，使其真正支持 `PROFILE=reality`

4. 完善 `preflight-check.sh`：

   * 支持 reality 所需的额外校验
   * 错误信息清晰

5. 输出文档：

   * `doc/phase1a-reality.md`

6. 更新 README：

   * 增加 `v2-reality` 使用说明
   * 说明该分支与 `v2-ws-tls` 的定位差异

交付标准：

* `v2-reality` 独立实现完成
* 不携带 ws-tls 历史逻辑包袱
* 配置体系仍然符合 `refactor-base` 的公共框架

完成后输出：

* reality 分支新增的关键文件
* 与 ws-tls 的主要差异
* 启动与参数说明
* 已知限制

---

# Round 7：统一三分支文档与开发者说明

## 目标

让项目对开发者、运维者、后续 Codex 都足够清晰。

## 给 Codex 的指令

请统一整理 `refactor-base`、`v2-ws-tls`、`v2-reality` 三条分支的文档与开发说明。

任务要求：

1. 统一 README 的表达：

   * 项目定位
   * 分支关系
   * 每个分支适用场景
   * 基础使用方式

2. 完善：

   * `AGENTS.md`
   * `codex-playbook.md`
   * `doc/phase1a-scope.md`
   * `doc/phase1a-flow.md`

3. 新增：

   * `doc/branch-strategy.md`
   * `doc/profile-design.md`

4. 将公共概念解释清楚：

   * profile
   * template
   * runtime
   * export
   * transport-specific logic

交付标准：

* 文档之间术语一致
* 分支职责明确
* 后续接手开发的人可快速理解项目

完成后输出：

* 文档索引
* 术语表
* 哪些内容适合进入下一阶段

---

# Round 8：Phase 1A 收尾与发布准备

## 目标

对 Phase 1A 做阶段性收尾，形成可继续推进的稳定状态。

## 给 Codex 的指令

请对 Phase 1A 做一次收尾整理。

任务要求：

1. 梳理三条分支当前状态：

   * 已完成
   * 未完成
   * 风险点
   * 建议下一阶段

2. 输出阶段总结文档：

   * `doc/phase1a-summary.md`

3. 在 README 或文档中补充：

   * 推荐使用路径
   * 不同用户应选哪个分支
   * 哪个分支更适合作为后续默认主线

4. 生成一份简洁的待办列表：

   * `doc/phase2-todo.md`

交付标准：

* Phase 1A 边界清晰
* 后续 Phase 2 能无缝衔接
* 文档能指导下一位开发者继续推进

完成后输出：

* 阶段总结
* 下一阶段建议
* 是否建议将某个分支提升为默认推荐路线

