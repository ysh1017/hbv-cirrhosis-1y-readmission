# HBV相关失代偿期肝硬化一年再入院预测研究

本仓库公开当前论文采用的稿件、图表和汇总结果。内容依据作者提供的2026年10月13日中文全文总稿，比较7种候选模型，包含正文Figure 1–5、Table 1–3，以及Supplementary Figure S1–S2、Table S1–S7。S5E/F的外部患者聚类重采样结果已包含。

[按顺序查看全部图表](PUBLICATION_INDEX.md) · [中文完整稿件](5_manuscript/HBV_Chinese_Manuscript_20261013.md) · [下载Word](5_manuscript/HBV_Chinese_Manuscript_20261013.docx)

## 研究范围

主要结局为出院后1年内因静脉曲张出血、腹水、肝性脑病、肝肾综合征或自发性细菌性腹膜炎所致的非计划再入院。国内队列445名患者，开发312名、固定内部验证133名；外部评价包含MIMIC-IV中50名患者的102次合格住院。国内目标事件185例，外部目标事件67次。

7种候选模型为Logistic regression、LASSO、Elastic net、Random forest、XGBoost、RBF-SVM和LightGBM。当前主模型为基于INR、PLT、ALBI和FIB-4的RBF-SVM。MELD-Na是另行比较的临床基准，不属于七候选模型排名。

固定内部验证、完整重复嵌套内部评价和外部评价属于不同分析语境，不应混用。完整重复嵌套的患者级聚合不是第三个独立验证队列。数值、区间方法和比较方向以对应表注及正文为准。

## 目录

| 目录 | 内容 |
| --- | --- |
| [0_admin](0_admin) | 公开范围、数据使用边界和当前版本身份 |
| [1_data](1_data) | 现稿表格的机器可读汇总数据，不含患者逐例资料 |
| [2_code](2_code) | 文件完整性核验代码、现稿模型配置说明 |
| [3_results](3_results) | 主表与补表的在线阅读版，以及独立主表文件 |
| [4_figures](4_figures) | 5幅主图、2幅补图的PDF/PNG及图注 |
| [5_manuscript](5_manuscript) | 作者提供的最新中文总稿及在线阅读版 |
| [6_release](6_release) | 当前公开文件的SHA-256清单和发布说明 |
| [7.Report](7.Report) | 当前结果概览、公开材料核对范围 |

## 数据和复现边界

公开表格保留论文显示精度，不是患者级数据，也不是全精度预测。仓库不含患者姓名、住院号、MIMIC患者键、逐例预测、抽样患者索引、原始病历、模型训练对象或访问凭据。大体积或受限资料用[内容与作用说明](0_admin/CONTROLLED_MATERIALS.md)代替。

为保持当前结果导向，本仓库不发布研究任务指令、聊天记录、MIMIC筛选SQL、历史流水线、已替代的探索性结果。`2_code`不被宣称为可重跑完整研究的分析流水线。

本次整理未重新训练、预测、插补、重采样或计算任何研究指标；未改动论文科学内容。公开共享不表示论文已被期刊接收，也不将研究模型作为已验证的临床决策工具。未新增开放许可，见[使用说明](0_admin/RIGHTS_AND_USE.md)。

## 核验文件

在仓库根目录运行 `python 2_code/verify_release.py`，核验发布清单列出的文件。脚本只读文件并计算SHA-256，不访问患者数据或运行统计分析。

## English overview

Current manuscript materials for prediction of 1-year unplanned decompensation-related readmission in HBV-related decompensated cirrhosis. This public repository contains the current Chinese manuscript, five main figures, three main tables, two supplementary figures, seven supplementary tables, and manuscript-level aggregate data. It does not distribute individual-level clinical data, restricted MIMIC records, trained model objects, or the full research execution pipeline.
