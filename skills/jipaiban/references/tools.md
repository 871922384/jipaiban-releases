# 工具

身份始终来自配对授权，不来自参数。调用前先 `whoami`。不要向用户复述手机号。

## whoami

当前授权用户是谁、什么角色、在哪些科室。

参数：无（多余字段忽略）。

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {"name": "whoami", "arguments": {}}
}
```

`structuredContent`：

```json
{
  "user_id": "<user_id>",
  "display_name": "张护士",
  "role": "member",
  "organization_id": "<organization_id>",
  "departments": ["内科病区"]
}
```

| 字段 | 含义 |
|---|---|
| `user_id` | 内部用户 id。不要用来冒充别人。 |
| `display_name` | 显示名。可能为 `null`。 |
| `role` | 组织角色：`admin`、`manager`、`member`、`staff`。 |
| `organization_id` | 授权绑定的组织。 |
| `departments` | 科室名称列表，可能为空。 |

`role` 为 `member` / `staff` 时不要调用 `get_department_schedule`。`admin` 可看全组织；科室 `admin`/`manager` 可看自己管理的科室。

传入 `user_id` / `organization_id` 不会切换身份，返回仍是授权用户。

## get_my_schedule

当前用户自己的**已发布**班表，按月。

| 参数 | 必填 | 规则 |
|---|---|---|
| `month` | 否 | `YYYY-MM`。省略则用当前 UTC 月份。 |

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "get_my_schedule",
    "arguments": {"month": "2026-09"}
  }
}
```

没有人员档案时：

```json
{"month": "2026-09", "days": []}
```

有班次时 `days` 每一项：

| 字段 | 含义 |
|---|---|
| `assignment_id` | 这条排班记录 |
| `version_id` / `plan_id` | 所属版本与计划 |
| `published_at` | 发布时间，ISO-8601，可能为 `null` |
| `staff_profile_id` | 当前用户的人员档案 |
| `date` | 上班日期 `YYYY-MM-DD` |
| `shift_type_id` | 班种 id |
| `shift_name` | 班种名，如 `白班` |
| `shift_short_name` | 简称 |
| `shift_color` | 颜色 |
| `shift_is_rest` | 是否休息班 |
| `shift_is_standby` | 是否备班 |
| `default_work_minutes` | 默认工时（分钟） |
| `time_range` | 当前固定为 `null` |
| `note` | 备注 |

只含 `status=current` 的已发布版本。草稿、未发布版本不会出现。某天没排班则 `days` 里没有那一天，不要补造休。

`month` 格式错误：`isError: true`，`month must be in YYYY-MM format`。

回答用户时用 `date` + `shift_name`（及 `note`）。不要把内部 id 念给用户，除非他们在排障。

## get_department_schedule

某日科室已发布排班总览。权限与组织排班总览相同。

| 参数 | 必填 | 规则 |
|---|---|---|
| `target_date` | 是 | `YYYY-MM-DD` |
| `department_id` | 否 | 只看一个科室。省略则返回当前用户能管理的全部科室。 |

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": {
    "name": "get_department_schedule",
    "arguments": {
      "target_date": "2026-09-04",
      "department_id": "<department_id>"
    }
  }
}
```

成功：

```json
{
  "target_date": "2026-09-04",
  "departments": [
    {
      "department_id": "<department_id>",
      "department_name": "内科病区",
      "has_current_schedule": true,
      "assignments": [
        {
          "staff_name": "张护士",
          "shift_name": "白班",
          "shift_is_rest": false,
          "note": null
        }
      ]
    }
  ]
}
```

| 字段 | 含义 |
|---|---|
| `has_current_schedule` | 该科室当天是否有已发布版本 |
| `assignments` | 当天该科室已发布班次。无排班时为 `[]` |
| `staff_name` | 姓名。找不到档案时为 `null` |
| `shift_name` / `shift_is_rest` / `note` | 班种与备注 |

没有人员手机号。不要把 `department_id` 换成其它组织的值去试探。

错误：

| `isError` 文本 | 何时 |
|---|---|
| `target_date is required in YYYY-MM-DD format` | 缺参数或不是日历日期 |
| `forbidden: Schedule organization overview is not allowed` | 普通员工，或该科室不在管理范围 |
| `Department not found` | id 不存在或不属于当前组织 |

组织里还没有科室时，有权限的管理员会得到 `departments: []`，这不是错误。

## list_notifications

当前组织里发给自己或全员的通知，新的在前。

参数：无。

```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "tools/call",
  "params": {"name": "list_notifications", "arguments": {}}
}
```

```json
{
  "notifications": [
    {
      "id": "<notification_id>",
      "type": "announcement",
      "title": "排班更新",
      "body": "九月排班已发布",
      "created_at": "2026-09-04T02:00:00+00:00",
      "is_read": false
    }
  ]
}
```

| 字段 | 含义 |
|---|---|
| `type` | 通知类型，原样展示 |
| `title` / `body` | 标题与正文 |
| `created_at` | ISO-8601 |
| `is_read` | 当前授权用户是否已读 |

没有分页参数。列表可能较长，回答时先概括未读，再按用户问题展开。当前 MCP 不能标记已读。

## 不在范围

不要尝试、不要向用户承诺可以用 MCP 做这些事：

- 发布 / 生成 / 修改正式班表
- 请假、调班、审批（请用户用极排班 App 或管理端）
- 导入人员、改手机号、改密码
- 用 agent token 调 `/api/v1/*` 业务接口
---
