# MCP 协议

入口：`POST https://jipaiban.junshian.cn/mcp`

- JSON-RPC 2.0
- 协议版本：`2024-11-05`
- 鉴权：`Authorization: Bearer <access_token>`（agent access）
- 支持的 method：`initialize`、`ping`、`tools/list`、`tools/call`

HTTP **401** 时按手里的凭证处理：

- 当前请求带的是 **agent access token**：调用 refresh，换新 token 后重试同一 MCP 请求。refresh 也 401（含撤销、过期、旧 refresh 重放）则停止，请用户回连接页重新生成配对码。
- 未带 token、或带的是 **人用登录 JWT**：不要 refresh。`/mcp` 只接受 agent access token。请用户打开连接页生成配对码后再兑权。

## 通用请求

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "<method>",
  "params": {}
}
```

`id` 可以是数字或字符串。通知（无 `id`）当前按普通请求处理，但调用工具时请始终带 `id`。

## initialize

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {},
    "clientInfo": {"name": "workbuddy", "version": "1.0"}
  }
}
```

成功：

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {"tools": {}},
    "serverInfo": {"name": "jipaiban-agent-connect", "version": "1.0.0"}
  }
}
```

`params` 目前不改变工具面，可按上面示例发送。

## ping

```json
{"jsonrpc":"2.0","id":1,"method":"ping"}
```

成功：`{"jsonrpc":"2.0","id":1,"result":{}}`

适合检测 agent access token 是否仍有效。若这次请求用的就是 agent access 且返回 401，再续期。

## tools/list

```json
{"jsonrpc":"2.0","id":1,"method":"tools/list"}
```

成功 `result.tools` 为四个工具定义。当前固定为：

- `whoami`
- `get_my_schedule`
- `get_department_schedule`
- `list_notifications`

每个元素含 `name`、`description`、`inputSchema`。以本次 `tools/list` 为准；不要假设以后还会多出写操作。

## tools/call

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "whoami",
    "arguments": {}
  }
}
```

| params 字段 | 规则 |
|---|---|
| `name` | 必填，工具名 |
| `arguments` | 可选对象。缺省或非对象时按 `{}`。`user_id` / `organization_id` 会被丢掉。 |

HTTP 始终 200（鉴权通过时）。工具成败看 `result.isError`。

成功：

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [{"type": "text", "text": "{...JSON 字符串...}"}],
    "isError": false,
    "structuredContent": {}
  }
}
```

优先读 `structuredContent`。没有则解析 `content[0].text`（UTF-8 JSON 文本）。

失败（权限、参数、限流、未知工具）：

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [{"type": "text", "text": "forbidden: Schedule organization overview is not allowed"}],
    "isError": true
  }
}
```

常见 `text`：

| 文本 | 原因 |
|---|---|
| `forbidden: Schedule organization overview is not allowed` | 当前用户不能看科室总览 |
| `target_date is required in YYYY-MM-DD format` | 缺日期或格式错 |
| `month must be in YYYY-MM format` | 月份格式错 |
| `Department not found` | `department_id` 不属于当前组织 |
| `Unknown tool: ...` | 工具名写错 |
| `params.name is required` | 没传工具名 |
| `arguments must be an object` | `params` 不是对象 |
| `Tool call rate limit exceeded, retry in one minute` | 同一授权每分钟最多 60 次 `tools/call` |
| `Tool call failed` | 未分类错误，不要重试刷屏 |

限流窗口：60 秒内 60 次 `tools/call`，按授权（grant）计，不是按工具名。超限后等一分钟。`initialize` / `ping` / `tools/list` 不计入该限额。

## JSON-RPC 级错误

这些是 `error` 对象，不是 `result.isError`。HTTP 仍为 200。

| code | 含义 |
|---|---|
| `-32700` | 请求体不是合法 JSON |
| `-32600` | 不是 JSON-RPC 2.0 对象，或 `jsonrpc` 不是 `"2.0"`，或 `method` 为空 |
| `-32601` | 未知 method（例如 `tools/invoke`） |

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {"code": -32601, "message": "Unknown method: bogus/method"}
}
```

没有 `notifications/subscribe`、`resources/list`、SSE 其它路径。只使用上面四个 method。
