# HI working materials — 2026-10-18

本目录对应作者核定的 `Integrated_20261018` 工作版本，提供最新在线补充材料和图形。它是论文准备材料，不表示稿件已经投稿、接收或发表，也不是完整的端到端复现软件。

## 阅读入口

[Online Resource 1 / ESM_1.pdf](ESM_1.pdf) 为43页的一份补充文件，包含Notes M1–M7、Tables S1–S9及Figs. S1–S2。M1中已补第2套完成数据和四项变量的预测均值匹配；S4说明段已补冻结预测接口；M6保留核定的临床审核程序。M1、M2等不另行拆成独立上传文件。

| 当前编号 | 内容 | PDF |
|---|---|---|
| Fig. 1 | 患者筛选与分组 | [Fig1（沿用既有文件）](../../4_figures/Figure1.pdf) |
| Fig. 2 | 特征筛选及Core4 | [Fig2](figures/Fig2.pdf) |
| Fig. 3 | 七模型性能 | [Fig3](figures/Fig3.pdf) |
| Fig. 4 | MELD-Na比较、风险分层、校准及DCA | [Fig4](figures/Fig4.pdf) |
| Fig. 5 | SHAP | [Fig5](figures/Fig5.pdf) |
| Fig. S1 | 同等容量的事件捕获 | [FigS1](figures/FigS1.pdf) |
| Fig. S2 | 全范围DCA及成对净获益差值 | [FigS2](figures/FigS2.pdf) |
| Graphical Abstract | 已去除审阅标记和底部缩写表的V2 | [Graphical Abstract](figures/Graphical_Abstract.pdf) |

[五幅主图的核定图注](FIGURE_LEGENDS.md)。Fig. 2–5采用已核定的174 × 234 mm字号调整版；此为作者工作尺寸，不是期刊技术接收回执。高分辨率TIFF继续保留为投稿生产文件，本目录不重复上传相同图形的TIFF或预览PNG。

## 与2026-10-13中文公开稿的编号关系

旧中文稿和原汇总表保留，不覆盖、不删除。本目录为较新的HI配套材料，不把旧稿描述为从未公开。

| 当前HI位置 | 2026-10-13中文公开稿中的位置 |
|---|---|
| Table 1 a/b：七模型性能 | [Table 2](../../3_results/tables/Table2.md) |
| Online Table S8：国内总体基线 | [Table 1](../../3_results/tables/Table1.md) |
| Online Table S9：覆盖与事件捕获 | [Table 3](../../3_results/tables/Table3.md) |
| Figs. 1–5 | 主题顺序不变，本目录提供当前图面版本 |
| Figs. S1–S2、Tables S1–S7 | 编号保留；当前图注、表注和在线方法以本目录ESM为准 |

旧JSON/Markdown汇总表继续对应历史中文稿，不在本轮重新抽表、重算或强制重编号；Table S8/S9的内容已经收入本目录ESM，不能因旧目录没有同名文件就当作缺失数据。

## 模型使用与访问范围

原固定RBF-SVM、Core4 logistic和MELD-Na基准对象及接口已在作者受控环境中查回。Core4接口使用命名输入 `INR`, `PLT`, `ALBI`, `FIB.4`，返回正类 `Yes` 的概率；预测沿用对象内的缩放及SVM概率映射。MELD-Na使用其原单变量logistic基准，不能将评分直接当概率，也不属于同一个Core4接口。

本公开目录不包含训练模型对象、支持向量、患者输入、逐例预测或完整执行流水线；仅凭本目录不能独立运行原模型或端到端重做研究。已有本地回放记录不代表全部七模型、最早全部历史状态或跨平台完整复现均已验证。模型或数据的进一步访问须经过相应研究及数据权限审核，本说明不承诺自动提供，也不新授予开放许可。联系资料见ESM首页。

国内逐例资料及受限MIMIC记录不公开；受控审计包、签署表、伦理原件、凭据和本机路径不作为本目录附件。使用限制沿用仓库[RIGHTS_AND_USE](../../0_admin/RIGHTS_AND_USE.md)与[CONTROLLED_MATERIALS](../../0_admin/CONTROLLED_MATERIALS.md)。

## 版本核验

[SHA256SUMS.txt](SHA256SUMS.txt)列出本目录文件（不含清单自身）的SHA-256。本目录PDF为核定整合包的原样副本；Fig. 1链接复用仓库中的同字节既有文件；本次公开整理不改写主稿、在线资源、图注、图形或任何研究结果。
