---
name: jipaiban
description: >
  连接极排班托管 MCP，用配对码兑权后查看当前授权用户的身份、班表、科室排班和通知。
  用户提到极排班、排班、班次、值班、请假、通知、把极排班接到 WorkBuddy/Claude/Cursor/Grok，
  或运行 /jipaiban 时使用。
---

# 极排班

用托管 MCP 读取**当前授权用户**自己的排班数据。不要编造班次，不要用 agent token 去打普通 REST。

生产环境：

| 用途 | URL |
|---|---|
| 人登录并生成配对码 | https://jipaiban.junshian.cn/agent/connect |
| MCP | https://jipaiban.junshian.cn/mcp |
| 兑权 | `POST https://jipaiban.junshian.cn/api/v1/agent/pairing-codes/redeem` |
| 续期 | `POST https://jipaiban.junshian.cn/api/v1/agent/token/refresh` |

细节：`references/connect-and-auth.md`、`references/mcp-protocol.md`、`references/tools.md`。

## 连接

1. 请用户自己打开连接页完成登录，复制 MCP 地址，生成一次性配对码。不要向用户索要、接收或处理手机号、短信验证码或密码。
2. 使用连接页显示的一次性配对码（短时有效、只能兑一次）。用户把码交给你，不要写进 URL、日志或技能文件。
3. 用下面的兑权请求换成 `access_token` 和 `refresh_token`。`client_name` 用来区分客户端，例如 `workbuddy`、`claude`、`cursor`、`grok`。
4. 之后所有 MCP 调用带 `Authorization: Bearer <access_token>`。access 约 20 分钟过期，用 refresh 续期；旧 refresh 重放会撤销整条授权。

```http
POST /api/v1/agent/pairing-codes/redeem
Host: jipaiban.junshian.cn
Content-Type: application/json

{"code":"<配对码>","client_name":"workbuddy"}
```

成功后 `mcp_url` 可能是相对路径 `/mcp`，实际请求始终打 `https://jipaiban.junshian.cn/mcp`。

## 调用顺序

1. `initialize`（协议版本 `2024-11-05`）
2. `tools/list` 确认工具
3. 先 `whoami`，再按用户问题调用其它工具
4. 当前用的是 agent access token 且 MCP 返回 HTTP 401：用 refresh 续期再重试。人用登录 JWT、尚未兑权、或 refresh 也 401：不要 refresh，请用户回连接页重新生成配对码。

## 工具

| 工具 | 谁能用 | 参数 |
|---|---|---|
| `whoami` | 任何人 | 无 |
| `get_my_schedule` | 任何人 | 可选 `month`（`YYYY-MM`，默认当月） |
| `get_department_schedule` | 组织管理员，或科室 `admin`/`manager` | 必填 `target_date`（`YYYY-MM-DD`），可选 `department_id` |
| `list_notifications` | 任何人 | 无 |

忽略工具参数里的 `user_id` 和 `organization_id`。身份以授权为准。

普通员工调用 `get_department_schedule` 会得到工具级错误（`isError: true`，文案含 `forbidden`），HTTP 仍是 200。

发布或修改正式班表、生成草稿、人员导入、批量删除不在当前技能范围。当前 MCP 也没有这些工具。

## 硬规则

- 不要把配对码、access token、refresh token 写进 URL、query、路径或技能文件。
- 不要索要、保存、读取或复述手机号。服务端会去掉 `phone`/`mobile` 字段；如果仍出现，忽略。
- agent token（`token` 类型为 `agent_access`）只用于 `POST /mcp` 以及 refresh。不要拿它去调 `/api/v1/schedules`、`/api/v1/staff`、`/api/v1/auth/*`。
- 人用的登录 JWT 也不能打 `/mcp`。
- 不要猜测班次。工具没返回就说没有数据或权限不够。
- 不要引导用户提供密码、短信验证码、SSH、环境变量或服务器地址。连接只需要配对码。
