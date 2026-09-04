---
name: jipaiban
description: >
  连接极排班托管 MCP：自动领取试用会话，创建排班小组、写入班表并分享链接。
  已有医院账号时用配对码查询自己的班表和通知。
  用户提到极排班、排班、班表、值班、小组排班、把极排班接到智能体，或运行 /jipaiban 时使用。
---

# 极排班

用托管 MCP 排出一张可分享的班表。不要编造班次。不要向用户索要手机号、短信验证码或密码。

生产环境：

| 用途 | URL |
|---|---|
| MCP | https://jipaiban.junshian.cn/mcp |
| 试用会话 | `POST https://jipaiban.junshian.cn/api/v1/agent/guest-sessions` |
| 连接页 | https://jipaiban.junshian.cn/agent/connect |
| 续期 | `POST https://jipaiban.junshian.cn/api/v1/agent/token/refresh` |

细节：`references/connect-and-auth.md`、`references/mcp-protocol.md`、`references/tools.md`。

## 有 agent 经验时（默认）

1. 把 MCP 地址加为远程 MCP。不要把 token 写进 URL。
2. 若还没有 agent token：调用试用会话接口，保存 `access_token` / `refresh_token`，再带 Bearer 调 `/mcp`。用户无感知，不要让他们登录。
3. `initialize` → `tools/list` → `whoami`。
4. 用户说要排班：`create_schedule_group`，再 `set_group_shifts` 或 `import_schedule_from_image`（你先看图/表格，再传结构化班次）。
5. 把 `share_url` 发给用户。要保住这张表，让用户打开返回的 `claim_url` 自己登录。

## 已有医院账号

用户打开连接页登录并给你一次性配对码后，兑权得到医院 grant。`tools/list` 会多出 `get_my_schedule`、`get_department_schedule`、`list_notifications`。配对码不要写进 URL。

## 硬规则

- Guest token 只能动这个会话建的小组，不能查医院科室班表。
- agent token 只用于 `POST /mcp`、试用会话、配对兑权和 refresh。不要拿它去调 `/api/v1/schedules`、`/api/v1/staff`、`/api/v1/auth/*`。
- 忽略工具参数里的 `user_id` / `organization_id`。
- 不要读取或复述手机号。
- 发布医院正式班表、审批、改密码不在范围。
- 图片由你识别后写入结构化字段；不要把真实 token 写进技能或日志。
- 日期必须落在 `year_month` 当月。不要猜测班次；工具没返回就说没有数据。
---
