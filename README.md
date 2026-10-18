# HBV相关失代偿期肝硬化一年再入院预测研究

本仓库保留作者2026年10月13日中文公开稿、原图表及汇总结果，同时提供2026年10月18日核定的HI工作版在线补充材料与图形。较新HI结构为5幅主图、Table 1 a/b、2幅补图、Tables S1–S9及Notes M1–M7；旧中文版本的3张主表不作为当前HI编号。S5E/F的外部患者聚类重采样结果已包含。材料仍属作者公开工作稿，不表示已投稿、接收或发表。

[2026-10-18 HI材料入口](6_release/HI_20261018/README.md) · [Online Resource 1 / ESM](6_release/HI_20261018/ESM_1.pdf)

编号对应：旧Table 2 → 当前Table 1 a/b；旧Table 1 → 当前Online Table S8；旧Table 3 → 当前Online Table S9。旧中文稿及其图表链接继续保留；旧汇总JSON/Markdown不在本轮重新制表或重编号。

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
| [5_manuscript](5_manuscript) | 保留2026-10-13中文公开稿及在线阅读版 |
| [6_release](6_release) | 2026-10-18 HI补充材料与图形、文件SHA-256清单及发布说明 |
| [7.Report](7.Report) | 当前结果概览、公开材料核对范围 |

## 数据和复现边界

公开表格保留论文显示精度，不是患者级数据，也不是全精度预测。仓库不含患者姓名、住院号、MIMIC患者键、逐例预测、抽样患者索引、原始病历、模型训练对象或访问凭据。大体积或受限资料用[内容与作用说明](0_admin/CONTROLLED_MATERIALS.md)代替。

为保持当前结果导向，本仓库不发布研究任务指令、聊天记录、MIMIC筛选SQL、历史流水线、已替代的探索性结果。`2_code`不被宣称为可重跑完整研究的分析流水线。

本次整理未重新训练、预测、插补、重采样或计算任何研究指标；未改动论文科学内容。公开共享不表示论文已被期刊接收，也不将研究模型作为已验证的临床决策工具。未新增开放许可，见[使用说明](0_admin/RIGHTS_AND_USE.md)。

## 核验文件

在仓库根目录运行 `python 2_code/verify_release.py`，核验发布清单列出的文件。脚本只读文件并计算SHA-256，不访问患者数据或运行统计分析。

## English overview

Manuscript preparation materials for prediction of 1-year unplanned decompensation-related readmission in HBV-related decompensated cirrhosis. This repository retains the 13 October 2026 Chinese public manuscript and its original figures, tables and aggregate data, and adds the approved 18 October 2026 HI working-version online resource and figures. The newer HI structure comprises five main figures, Table 1 a/b, two supplementary figures, Tables S1–S9 and Notes M1–M7. See the [HI version entry](6_release/HI_20261018/README.md) and [Online Resource 1](6_release/HI_20261018/ESM_1.pdf). These are author working materials, not evidence of journal acceptance or publication. Individual-level clinical data, restricted MIMIC records, trained model objects and the full research execution pipeline are not distributed.
