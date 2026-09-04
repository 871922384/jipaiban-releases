# 连接与鉴权

人在浏览器完成登录和授权；智能体只兑配对码、续期、调 MCP。

## 人做什么

1. 打开 https://jipaiban.junshian.cn/agent/connect
2. 在连接页自行完成登录。智能体不要代发验证码，也不要收集手机号或密码。
3. 复制 MCP 地址：`https://jipaiban.junshian.cn/mcp`
4. 生成一次性配对码
5. 把 MCP 地址和配对码交给智能体
6. 需要断开时，在同一页面撤销对应客户端

配对码以连接页展示为准，短时有效、只能兑换一次。把用户给出的码原样放进 `code` 字段即可。

智能体不要调用「生成配对码」「列出授权」「撤销授权」接口。那些需要人用登录态，不是 agent token。

## 兑权

```http
POST /api/v1/agent/pairing-codes/redeem HTTP/1.1
Host: jipaiban.junshian.cn
Content-Type: application/json

{
  "code": "<配对码>",
  "client_name": "workbuddy"
}
```

| 字段 | 规则 |
|---|---|
| `code` | 必填。使用连接页展示的一次性配对码。 |
| `client_name` | 可选，默认 `agent`，最长 50。只保留 `a-z0-9._-`，会转成小写。建议：`workbuddy`、`claude`、`cursor`、`grok`。 |

成功 `200`：

```json
{
  "access_token": "<access_token>",
  "refresh_token": "<refresh_token>",
  "token_type": "bearer",
  "expires_in": 1200,
  "organization_id": "<organization_id>",
  "mcp_url": "/mcp"
}
```

| 字段 | 含义 |
|---|---|
| `access_token` | 调 MCP 用。约 20 分钟（`expires_in` 秒）。 |
| `refresh_token` | 续期用。约 30 天。只保存最新值。 |
| `organization_id` | 本次授权绑定的组织。工具参数里的 `organization_id` 会被忽略。 |
| `mcp_url` | 相对路径 `/mcp`。请求用 `https://jipaiban.junshian.cn/mcp`。 |

失败：

| HTTP | 何时 |
|---|---|
| 400 | 配对码无效、过期、已用过 |
| 422 | body 不合法（缺 `code`、长度不对） |

错误 body 形如 `{"detail":"Pairing code is invalid or expired"}`。不要把用户给的码回显到错误说明里。

## 续期

当前请求用的是 agent access token、且 MCP 返回 **HTTP 401**（不是 JSON-RPC 业务错误）时，用 refresh 续期。人用登录 JWT 的 401 不要走这条接口。

```http
POST /api/v1/agent/token/refresh HTTP/1.1
Host: jipaiban.junshian.cn
Content-Type: application/json

{
  "refresh_token": "<refresh_token>"
}
```

成功 `200`，字段与兑权相同，会返回**新的** `access_token` 和**新的** `refresh_token`。立刻丢掉旧 refresh，只保留新的。

失败：

| HTTP | 何时 |
|---|---|
| 401 | refresh 无效、过期、授权已撤销，或旧 refresh 被重放 |

**重放会撤销整条授权。** 用已经轮换掉的 refresh 再请求一次，该客户端作废，之后 MCP 和 refresh 都是 401。用户必须回连接页重新生成配对码。

## 怎么带 token

MCP：

```http
POST /mcp HTTP/1.1
Host: jipaiban.junshian.cn
Authorization: Bearer <access_token>
Content-Type: application/json
```

- 不要把 token 放进 query、路径、MCP URL。
- 不要把人用登录 JWT 拿到 `/mcp` 上用（会 401）。
- 不要把 agent token 拿到 `/api/v1/schedules`、`/api/v1/staff`、`/api/v1/auth/*` 上用（会 401）。
- 兑权和续期这两条 HTTP 接口本身不带 Bearer。

## 建议的本地状态

智能体侧只保存：

- `access_token`
- `refresh_token`
- `organization_id`（展示用，不作为越权参数）
- `client_name`

不要保存配对码。不要保存手机号。
