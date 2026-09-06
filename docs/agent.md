# 极排班给智能体的公开入口

极排班是面向医护人员的排班工作台。智能体可以先读取现有班表，再帮助用户补充、核对和分享安排；用户不需要把手机号、验证码或密码交给智能体。

这是公开仓的 Agent 入口。需要复制到客户端的技能文件在 [`skills/jipaiban/SKILL.md`](https://github.com/871922384/jipaiban-releases/blob/main/skills/jipaiban/SKILL.md)，托管 MCP 的地址是 [`https://jipaiban.junshian.cn/mcp`](https://jipaiban.junshian.cn/mcp)。

## 三步接入

### 1. 安装技能

把公开仓中的 `skills/jipaiban/` 目录导入 Agent 的 skills 目录。不同客户端的目录名称不同，通用做法是：

```bash
git clone --depth 1 https://github.com/871922384/jipaiban-releases.git
# 把路径替换成客户端的 skills 目录
AGENT_SKILLS_DIR="/path/to/your/agent/skills"
cp -R jipaiban-releases/skills/jipaiban "$AGENT_SKILLS_DIR/jipaiban"
```

也可以直接打开 [SKILL.md](https://github.com/871922384/jipaiban-releases/blob/main/skills/jipaiban/SKILL.md)，让支持远程技能的 Agent 读取它。

### 2. 添加 MCP

将下面的地址作为远程 MCP 添加：

```text
https://jipaiban.junshian.cn/mcp
```

不要把 token 写进 URL。Agent 需要试用时，按技能中的说明调用 `POST /api/v1/agent/guest-sessions` 自动领取短期会话；用户要保住班表或查看医院数据时，再打开[连接页](https://jipaiban.junshian.cn/agent/connect)。

### 3. 先确认身份，再动班表

每次新会话按这个顺序开始：

```text
initialize → tools/list → whoami
```

确认身份后再创建小组、写入班次或读取医院班表。完成排班后，把工具返回的 `share_url` 给用户；要长期保留班表时，把 `claim_url` 留给用户在网页中完成认领。

## 能做什么

| 会话类型 | 可以做 | 不能做 |
| --- | --- | --- |
| Guest 试用 | 创建自己的排班小组、写入班次、查看班表、生成分享链接 | 查看医院科室班表，访问别人的小组 |
| 医院配对 | 读取自己的班表、按权限查看科室班表、读取通知 | 代用户登录、发布正式班表、修改密码 |

Guest 会话适合先把一张小组班表排出来。医院账号需要用户在连接页登录并提供一次性配对码；配对码不能写进 URL，也不能记录到日志。

## 产品边界

- 先看班表，再编辑；工具没有返回的数据就明确说没有数据。
- 不猜测班次，不把图片识别结果未经确认直接当成事实。
- 不索要或复述手机号、验证码、密码。
- Agent token 只用于托管 MCP、试用会话、配对兑权和续期，不直接调用内部 API。
- HTTP 401 时只对 Agent access 做 refresh；失败后重新领取试用会话，或请用户回连接页配对。

## 给客户端作者的入口

把下面三个链接作为公开仓的稳定入口：

- [Agent 快速接入页](https://github.com/871922384/jipaiban-releases/blob/main/docs/agent.md)：产品定位、接入步骤和安全边界。
- [技能正文](https://github.com/871922384/jipaiban-releases/blob/main/skills/jipaiban/SKILL.md)：触发词、默认流程和工具规则。
- [MCP 协议参考](https://github.com/871922384/jipaiban-releases/tree/main/skills/jipaiban/references)：鉴权、JSON-RPC 和工具参数。

WorkBuddy、Claude、Cursor、Grok、Codex 或其他支持 skills / MCP 的 Agent，都可以从同一份技能正文开始。客户端只需要把技能目录放到自己的 skills 目录，MCP 连接仍然指向极排班托管服务。

## 公开链接

- 产品页：[jipaiban.junshian.cn](https://jipaiban.junshian.cn)
- Agent 连接页：[jipaiban.junshian.cn/agent/connect](https://jipaiban.junshian.cn/agent/connect)
- 公开仓：[github.com/871922384/jipaiban-releases](https://github.com/871922384/jipaiban-releases)
