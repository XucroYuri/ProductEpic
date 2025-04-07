# AI-IDE 产品需求描述框架

## 项目概述

这是一个专为与AI IDE软件协作而设计的产品需求描述框架，旨在构建清晰明确但为后续升级留足余地的最小可行性产品(MVP)。该框架通过结构化的方式定义产品需求，使AI助手能够准确理解开发意图并生成高质量代码。

## 核心理念

- **分层指令结构**：将产品需求分为核心业务逻辑层、模块化生成层和接口隔离层
- **约束引导生成**：通过明确的约束条件确保生成代码的质量和一致性
- **可进化设计**：从一开始就考虑产品的演进路径，确保核心业务逻辑稳定的同时允许功能扩展
- **上下文优化**：针对大语言模型的上下文长度限制，优化需求描述的结构和内容

## 框架结构

```
ProductEpic/
├── Examples/                 # 示例项目
│   └── e-commerce_example/   # 电商示例
│       ├── api_spec.yaml
│       ├── invariants.yaml
│       ├── kernel.dsl
│       ├── payment_module.yaml
│       └── roadmap.md
├── Core/                     # 核心业务逻辑（不可变区）
│   ├── kernel.dsl            # 领域特定语言定义核心实体和操作
│   └── invariants.yaml       # 系统不变量和约束条件
├── Modules/                  # 功能模块（可扩展区）
│   ├── module_template.yaml  # 模块定义模板
│   └── dependencies.yaml     # 模块间依赖关系
├── Interfaces/               # 接口定义（隔离层）
│   ├── api_spec.yaml         # API规范
│   └── ui_spec.yaml          # UI规范
├── Evolution/                # 演进路线图
│   ├── roadmap.md            # 产品演进计划
│   └── migration_guide.md    # 版本迁移指南
└── Docs/                     # 文档系统
    ├── architecture.md       # 架构文档
    ├── beginner_guide.md     # 新手指导手册
    ├── development_guide.md  # 开发指南
    └── validation_rules.md   # 验证规则
```

## 使用方法

1. **定义核心业务逻辑**：在`kernel.dsl`中使用领域特定语言定义产品的核心实体和操作
2. **设置系统约束**：在`invariants.yaml`中定义系统必须遵守的不变量和约束条件
3. **规划模块结构**：使用`module_template.yaml`定义功能模块的结构和接口
4. **设计接口规范**：在`api_spec.yaml`和`ui_spec.yaml`中定义系统的外部接口
5. **规划演进路径**：在`roadmap.md`中描述产品的演进计划和版本迁移策略

## 最佳实践

- 保持核心业务逻辑简洁明确，避免过度设计
- 明确区分不可变核心和可扩展模块
- 为每个模块提供完整的文档和测试规范
- 使用版本控制管理需求变更
- 定期审查和更新演进路线图

## 示例

请参考`Examples/`目录中的示例项目，了解如何使用本框架描述不同类型的产品需求。

## 贡献指南

欢迎通过以下方式贡献本项目：

- 提交Bug报告和功能请求
- 改进文档和示例
- 提供新的模板和最佳实践

## 许可证

Copyright © 2024 XucroYuri。保留所有权利。

本项目采用MIT许可证。详情请参阅项目根目录下的LICENSE文件。