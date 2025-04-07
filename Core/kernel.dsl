# 核心业务逻辑定义 (Kernel DSL)
# 版本: 1.0.0

# 这是一个领域特定语言(DSL)文件，用于定义产品的核心实体和操作
# 该文件属于不可变核心区域，修改需谨慎并遵循严格的验证流程

# ======== 核心实体定义 ========
entities:
  # 实体名称及其属性定义
  - name: Entity1
    description: "核心业务实体1的描述"
    attributes:
      - name: id
        type: UUID
        required: true
        description: "唯一标识符"
      - name: name
        type: String
        required: true
        description: "实体名称"
      - name: status
        type: Enum
        values: [ACTIVE, INACTIVE, PENDING]
        default: ACTIVE
        description: "实体状态"
      - name: createdAt
        type: Timestamp
        required: true
        description: "创建时间"

  - name: Entity2
    description: "核心业务实体2的描述"
    attributes:
      - name: id
        type: UUID
        required: true
        description: "唯一标识符"
      - name: entity1Id
        type: UUID
        required: true
        description: "关联到Entity1的外键"
      - name: value
        type: Decimal
        required: true
        description: "实体值"

# ======== 实体关系定义 ========
relationships:
  - type: OneToMany
    source: Entity1
    target: Entity2
    sourceAttribute: id
    targetAttribute: entity1Id
    description: "一个Entity1可以关联多个Entity2"

# ======== 核心操作定义 ========
operations:
  - name: createEntity1
    description: "创建Entity1实例"
    input:
      - name: name
        type: String
        required: true
      - name: status
        type: Enum
        values: [ACTIVE, INACTIVE, PENDING]
        required: false
        default: ACTIVE
    output:
      type: Entity1
    preconditions:
      - "name不能为空"
      - "name长度必须在3-50个字符之间"
    postconditions:
      - "返回新创建的Entity1实例"
      - "Entity1.id被正确生成"
      - "Entity1.createdAt被设置为当前时间"

  - name: associateEntity2
    description: "将Entity2关联到Entity1"
    input:
      - name: entity1Id
        type: UUID
        required: true
      - name: value
        type: Decimal
        required: true
    output:
      type: Entity2
    preconditions:
      - "entity1Id必须对应一个存在的Entity1"
      - "value必须大于0"
    postconditions:
      - "返回新创建的Entity2实例"
      - "Entity2正确关联到指定的Entity1"

# ======== 业务规则定义 ========
rules:
  - name: "Entity1状态转换规则"
    description: "定义Entity1状态转换的有效路径"
    conditions:
      - "ACTIVE可以转换为INACTIVE"
      - "PENDING可以转换为ACTIVE或INACTIVE"
      - "INACTIVE不能直接转换为ACTIVE，必须先经过PENDING状态"

  - name: "Entity2值验证规则"
    description: "验证Entity2的value值"
    conditions:
      - "value必须是正数"
      - "value的精度不能超过2位小数"

# ======== 系统边界定义 ========
boundaries:
  - name: "核心业务边界"
    description: "定义系统核心业务逻辑的边界"
    includes:
      - "Entity1和Entity2的基本CRUD操作"
      - "Entity1和Entity2之间的关联操作"
    excludes:
      - "用户认证和授权"
      - "通知和报告生成"
      - "数据导入导出"

# ======== 扩展点定义 ========
extension_points:
  - name: "Entity1状态变更钩子"
    description: "当Entity1状态变更时的扩展点"
    trigger: "Entity1.status变更"
    interface:
      - name: "beforeStatusChange"
        input: [Entity1, oldStatus, newStatus]
        output: Boolean
      - name: "afterStatusChange"
        input: [Entity1, oldStatus, newStatus]
        output: void

  - name: "Entity2值计算扩展点"
    description: "自定义Entity2值的计算逻辑"
    trigger: "计算Entity2.value"
    interface:
      - name: "calculateValue"
        input: [Entity1, rawValue]
        output: Decimal