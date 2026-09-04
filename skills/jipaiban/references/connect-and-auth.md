# 连接与鉴权

智能体先自己领取试用会话；人只在要保住班表或绑定医院账号时打开网页。

## 试用会话（默认）

```http
POST /api/v1/agent/guest-sessions HTTP/1.1
Host: jipaiban.junshian.cn
Content-Type: application/json

{"client_name":"workbuddy"}
```

成功 `200`：

```json
{
  "access_token": "<access_token>",
  "refresh_token": "<refresh_token>",
  "token_type": "bearer",
  "expires_in": 1200,
  "organization_id": null,
  "mcp_url": "/mcp",
  "claim_url": "https://jipaiban.junshian.cn/agent/claim?code=<claim-token>"
}
```

之后所有 `POST /mcp` 带 `Authorization: Bearer <access_token>`。实际 MCP 地址是 `https://jipaiban.junshian.cn/mcp`。

每会话每天最多建 3 个组。未认领小组的公开分享约 7 天后停止。认领只能由用户在网页完成，智能体不要代收手机号。

access 过期（MCP HTTP 401）且手里是 guest/agent access：

```http
POST /api/v1/agent/token/refresh HTTP/1.1
Host: jipaiban.junshian.cn
Content-Type: application/json

{"refresh_token":"<refresh_token>"}
```

成功后立刻丢掉旧 refresh，只保存返回的新 `access_token` 和 `refresh_token`。旧 refresh 再用不只失败，还会撤销整条授权。人用登录 JWT 的 401 不要走这条接口。

## 医院配对（可选）

人打开 https://jipaiban.junshian.cn/agent/connect 登录，生成一次性配对码。智能体：

```http
POST /api/v1/agent/pairing-codes/redeem
Content-Type: application/json

{"code":"<配对码>","client_name":"workbuddy"}
```

得到医院 grant 后才能调用科室班表工具。旧 refresh 重放会撤销授权。
