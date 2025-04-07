# 电子商务系统核心业务逻辑定义 (Kernel DSL)
# 版本: 1.0.0

# 这是一个电子商务系统的领域特定语言(DSL)文件，用于定义核心实体和操作
# 该文件属于不可变核心区域，修改需谨慎并遵循严格的验证流程

# ======== 核心实体定义 ========
entities:
  # 产品实体
  - name: Product
    description: "商品信息实体"
    attributes:
      - name: id
        type: UUID
        required: true
        description: "产品唯一标识符"
      - name: name
        type: String
        required: true
        description: "产品名称"
      - name: description
        type: String
        required: false
        description: "产品描述"
      - name: price
        type: Decimal
        required: true
        description: "产品价格"
      - name: inventory
        type: Integer
        required: true
        description: "库存数量"
      - name: status
        type: Enum
        values: [ACTIVE, INACTIVE, OUT_OF_STOCK]
        default: ACTIVE
        description: "产品状态"
      - name: createdAt
        type: Timestamp
        required: true
        description: "创建时间"

  # 用户实体
  - name: User
    description: "用户信息实体"
    attributes:
      - name: id
        type: UUID
        required: true
        description: "用户唯一标识符"
      - name: username
        type: String
        required: true
        description: "用户名"
      - name: email
        type: String
        required: true
        description: "电子邮箱"
      - name: passwordHash
        type: String
        required: true
        description: "密码哈希值"
      - name: status
        type: Enum
        values: [ACTIVE, INACTIVE, LOCKED]
        default: ACTIVE
        description: "用户状态"
      - name: createdAt
        type: Timestamp
        required: true
        description: "创建时间"

  # 订单实体
  - name: Order
    description: "订单信息实体"
    attributes:
      - name: id
        type: UUID
        required: true
        description: "订单唯一标识符"
      - name: userId
        type: UUID
        required: true
        description: "关联的用户ID"
      - name: status
        type: Enum
        values: [PENDING, PAID, SHIPPED, DELIVERED, CANCELLED]
        default: PENDING
        description: "订单状态"
      - name: totalAmount
        type: Decimal
        required: true
        description: "订单总金额"
      - name: createdAt
        type: Timestamp
        required: true
        description: "创建时间"

  # 订单项实体
  - name: OrderItem
    description: "订单项信息实体"
    attributes:
      - name: id
        type: UUID
        required: true
        description: "订单项唯一标识符"
      - name: orderId
        type: UUID
        required: true
        description: "关联的订单ID"
      - name: productId
        type: UUID
        required: true
        description: "关联的产品ID"
      - name: quantity
        type: Integer
        required: true
        description: "购买数量"
      - name: price
        type: Decimal
        required: true
        description: "购买时的产品单价"
      - name: subtotal
        type: Decimal
        required: true
        description: "小计金额"

# ======== 实体关系定义 ========
relationships:
  - type: OneToMany
    source: User
    target: Order
    sourceAttribute: id
    targetAttribute: userId
    description: "一个用户可以有多个订单"

  - type: OneToMany
    source: Order
    target: OrderItem
    sourceAttribute: id
    targetAttribute: orderId
    description: "一个订单包含多个订单项"

  - type: ManyToOne
    source: OrderItem
    target: Product
    sourceAttribute: productId
    targetAttribute: id
    description: "一个订单项关联一个产品"

# ======== 核心操作定义 ========
operations:
  - name: createProduct
    description: "创建新产品"
    input:
      - name: name
        type: String
        required: true
      - name: description
        type: String
        required: false
      - name: price
        type: Decimal
        required: true
      - name: inventory
        type: Integer
        required: true
      - name: status
        type: Enum
        values: [ACTIVE, INACTIVE]
        required: false
        default: ACTIVE
    output:
      type: Product
    preconditions:
      - "name不能为空"
      - "price必须大于0"
      - "inventory必须大于等于0"
    postconditions:
      - "返回新创建的Product实例"
      - "Product.id被正确生成"
      - "Product.createdAt被设置为当前时间"

  - name: updateProductInventory
    description: "更新产品库存"
    input:
      - name: productId
        type: UUID
        required: true
      - name: delta
        type: Integer
        required: true
        description: "库存变化量，正数表示增加，负数表示减少"
    output:
      type: Product
    preconditions:
      - "productId必须对应一个存在的Product"
      - "如果delta为负数，其绝对值不能大于当前库存"
    postconditions:
      - "Product.inventory被更新为当前值加上delta"
      - "如果更新后inventory为0，Product.status被设置为OUT_OF_STOCK"
      - "如果更新后inventory大于0且status为OUT_OF_STOCK，Product.status被设置为ACTIVE"

  - name: createOrder
    description: "创建新订单"
    input:
      - name: userId
        type: UUID
        required: true
      - name: items
        type: Array
        items:
          type: Object
          properties:
            - name: productId
              type: UUID
              required: true
            - name: quantity
              type: Integer
              required: true
        required: true
    output:
      type: Order
    preconditions:
      - "userId必须对应一个状态为ACTIVE的User"
      - "items不能为空"
      - "每个item.productId必须对应一个存在的Product"
      - "每个item.quantity必须大于0"
      - "每个关联的Product必须有足够的库存"
    postconditions:
      - "创建新的Order实例"
      - "为每个item创建OrderItem实例"
      - "计算Order.totalAmount为所有OrderItem.subtotal的总和"
      - "减少每个关联Product的库存"
      - "如果某个Product库存变为0，更新其status为OUT_OF_STOCK"

  - name: updateOrderStatus
    description: "更新订单状态"
    input:
      - name: orderId
        type: UUID
        required: true
      - name: status
        type: Enum
        values: [PAID, SHIPPED, DELIVERED, CANCELLED]
        required: true
    output:
      type: Order
    preconditions:
      - "orderId必须对应一个存在的Order"
      - "状态转换必须遵循有效的状态流转路径"
      - "如果新状态为CANCELLED，订单当前状态必须为PENDING或PAID"
    postconditions:
      - "Order.status被更新为新状态"
      - "如果新状态为CANCELLED，恢复相关Product的库存"

# ======== 业务规则定义 ========
rules:
  - name: "订单状态转换规则"
    description: "定义订单状态的有效转换路径"
    conditions:
      - "PENDING可以转换为PAID或CANCELLED"
      - "PAID可以转换为SHIPPED或CANCELLED"
      - "SHIPPED可以转换为DELIVERED"
      - "DELIVERED是终态，不能再转换"
      - "CANCELLED是终态，不能再转换"

  - name: "产品价格规则"
    description: "产品价格的业务规则"
    conditions:
      - "产品价格必须大于0"
      - "产品价格精度不能超过2位小数"

  - name: "库存管理规则"
    description: "库存管理的业务规则"
    conditions:
      - "库存不能为负数"
      - "当库存为0时，产品状态必须为OUT_OF_STOCK"
      - "当库存大于0时，产品状态不能为OUT_OF_STOCK"

# ======== 系统边界定义 ========
boundaries:
  - name: "核心业务边界"
    description: "定义系统核心业务逻辑的边界"
    includes:
      - "产品管理的基本操作"
      - "订单处理的核心流程"
      - "用户账户的基本管理"
    excludes:
      - "支付处理"
      - "物流管理"
      - "营销活动"
      - "客户服务"

# ======== 扩展点定义 ========
extension_points:
  - name: "订单创建前钩子"
    description: "订单创建前的扩展点"
    trigger: "createOrder操作执行前"
    interface:
      - name: "validateOrder"
        input: ["userId", "items"]
        output: Boolean

  - name: "订单状态变更钩子"
    description: "订单状态变更时的扩展点"
    trigger: "updateOrderStatus操作执行后"
    interface:
      - name: "afterStatusChange"
        input: ["order", "oldStatus", "newStatus"]
        output: void

  - name: "产品价格计算扩展点"
    description: "自定义产品价格计算逻辑"
    trigger: "计算OrderItem.subtotal"
    interface:
      - name: "calculatePrice"
        input: ["product", "quantity", "user"]
        output: Decimal