# MCP 协议

入口：`POST https://jipaiban.junshian.cn/mcp`

- JSON-RPC 2.0，协议 `2024-11-05`
- method：`initialize`、`ping`、`tools/list`、`tools/call`
- 鉴权：`Authorization: Bearer <access_token>`（试用会话或医院配对得到的 agent access）

HTTP **401**：

- 当前是 agent access：refresh 后重试。refresh 也 401 则重新领取试用会话，或请用户回连接页配对。
- 人用登录 JWT 或没 token：不要 refresh。先走试用会话。

`tools/call` 在鉴权通过时 HTTP 200，成败看 `result.isError`。优先读 `structuredContent`。

`tools/list` 按当前授权裁剪。Guest 没有医院工具。同一授权每分钟最多 60 次 `tools/call`。
