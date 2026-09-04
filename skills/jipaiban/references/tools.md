# 工具

先 `whoami`。Guest 会话看不到医院工具。

## 小组（试用即可）

| 工具 | 要点 |
|---|---|
| `whoami` | `kind`、`hospital_bound`、`groups`、`tools`、guest 时有 `claim_url` |
| `create_schedule_group` | `name`。返回 `group_id`、`share_url`、`claim_url` |
| `set_group_shifts` | `group_id`、`year_month`、`staff[{staff_key,display_name}]`、`shift_legend{code:{label,palette_role}}`、`cells[{staff_key,date,shift_code}]` |
| `import_schedule_from_image` | 同上；由宿主识别图片后传入结构化字段 |
| `get_group_schedule` | 读当前班表 |
| `list_group_members` | 成员 |
| `get_group_share_link` | 公开分享 URL |
| `request_hospital_access` | 仅 guest。`hospital_name`，可选 `contact_note` |

`palette_role` 只能是：`day`、`assist`、`night`、`rest`、`full_off`、`auxiliary_1` … `auxiliary_6`。

`date` 必须属于 `year_month` 当月。`cells.staff_key` / `shift_code` 必须能在 `staff` 和 `shift_legend` 里找到。同月再次写入会覆盖为新版本，不是和旧表合并。识别失败就不要调用写入。

别人的组会 `forbidden`。超限文案含 `limit`。参数错误看 `isError` 文本，不要猜测班次。

## 医院（配对后才出现在 tools/list）

`get_my_schedule`（可选 `month=YYYY-MM`）、`get_department_schedule`（必填 `target_date`）、`list_notifications`。

普通员工调用科室总览会 `forbidden`。不要念内部 id。
