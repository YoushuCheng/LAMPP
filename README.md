# LAMPP
Incorporate local ancestry information to predict genetically associated CpG methylation in admixed populations

## Overview
<img src="img/F1.png">

## Tutorial
### Use pre-computed predictive models
The `ModelCoeff` folder contains the precomputed weights to predict DNA methylations. The weights were computed using an admixed African-American dataset (n=377) with matched genotype and Methylation Capture Sequencing (MC-seq) data. It could be used to predict methylations for admixed populations with both African (AFR) and European (EUR) ancestry backgrounds. Each file contains the weights to predict CpGs on each chromosome. For example, 
```
                       probe         snp  ref  alt    effect   coefficient
1  chr10_100011341_100011341 (Intercept) <NA> <NA>      <NA>  1.8414981275
2  chr10_100011341_100011341   rs4519025    C    T b_average  0.0333244156
3  chr10_100011341_100011341    rs483614    C    T b_average -0.0107931322
4  chr10_100011341_100011341    rs511346    C    T b_average -0.0053931625
5  chr10_100011341_100011341    rs493478    G    A b_average -0.0074867534
6  chr10_100011341_100011341 rs147926658    A    C b_average -0.1765639535
7  chr10_100011341_100011341   rs4604804    G    A b_average -0.0055744287
8  chr10_100011341_100011341  rs61873743    A    G b_average  0.0049915697
9  chr10_100011341_100011341   rs1983867    G    C b_average -0.0058019736
10 chr10_100011341_100011341   rs1983865    C    T b_average -0.0168435740
11 chr10_100011341_100011341   rs1983864    T    G b_average -0.0013953108
12 chr10_100011341_100011341   rs2015972    C    T b_average -0.0142083941
13 chr10_100011341_100011341   rs7090035    G    C b_average -0.0163765711
14 chr10_100011341_100011341   rs4919216    A    G b_average  0.0033519243
15 chr10_100011341_100011341  rs11189616    G    A b_average  0.0364279768
16 chr10_100011341_100011341  rs11189651    T    G b_average  0.0066057951
17 chr10_100011341_100011341   rs3911757    A    G b_average  0.0203806543
18 chr10_100011341_100011341  rs10786444    G    C b_average  0.0118401372
19 chr10_100011341_100011341   rs2484941    C    T b_average -0.0157890674
20 chr10_100011341_100011341  rs10786466    T    C b_average -0.0009975034
21 chr10_100011341_100011341   rs7094763    C    A b_average -0.0072354371
22 chr10_100011341_100011341   rs4244329    A    G    b_diff  0.0457274612
23 chr10_100011341_100011341  rs75915328    A    G    b_diff  0.0959142574
24 chr10_100011341_100011341  rs11189704    C    T    b_diff  0.0110776412
...
```
- **probe:** The CpG to be predicted.
- **snp:** The SNP used as predictor.
- **ref:** The non-effect/reference allele of the SNP.
- **alt:** The effect allele of the SNP.
- **effect:** Terms indicating how to apply the effect sizes: `b_average` or `b_diff`. `b_average` indicates the effect size is to be applied on the original genotype $`SNP_j`$ (also equivalent to $`SNP_{j,AFR}+SNP_{j,EUR}`$). `b_diff` indicates the effect size is to be applied on the difference between the AFR and EUR genotype $`\frac{SNP_{j,AFR}-SNP_{j,EUR}}{2}`$. Specifically, $`SNP_{j,AFR}`$ and $`SNP_{j,EUR}`$ can be obtained by incorporating local ancestry and dissecting the original genotype into two ancestries (details in the Overview figure). 
- **coefficient:** The corresponding effect sizes.

### Compute your own predictive models
```
Rscript LAMPP.r /gpfs/gibbs/pi/zhao/yc769/MethylPred/LAMPP/example/test_pheno.txt /gpfs/ycga/project/xu_ke/yc769/MethylPred/LA/result/VACS_seq_chr22_AFR.RData /gpfs/ycga/project/xu_ke/yc769/MethylPred/LA/result/VACS_seq_chr22_EUR.RData seq ./oc1.txt \
threshold=0.005
```
- **file for phenotype/DNA methylation:** 
```
    ID Methy_count Unmethy_count     betaM                     cpg position
1 id_1          24             1 0.9600000 chr22_17564995_17564995 17564995
2 id_2          50             4 0.9259259 chr22_17564995_17564995 17564995
3 id_3          41             9 0.8200000 chr22_17564995_17564995 17564995
4 id_4          63             6 0.9130435 chr22_17564995_17564995 17564995
5 id_5          33             5 0.8684211 chr22_17564995_17564995 17564995
6 id_6          23             5 0.8214286 chr22_17564995_17564995 17564995
...
```
- **file for genotype:**
```
   chr       bp         snp ref alt id_1 id_2 id_3 id_4 id_5
1   22 16849681 rs111636391   G   C    0    1    1    0    0
2   22 16850115   rs5747996   C   T    0    1    1    0    0
3   22 16850297   rs7285252   C   T    0    1    1    0    0
4   22 16850437   rs5748209   G   A    0    1    1    0    0
5   22 16852914  rs77993021   G   A    0    1    1    0    0
6   22 16853178 rs111273033   C   T    0    1    1    0    0
7   22 16853232 rs112102661   G   A    0    1    1    0    0
8   22 16853625  rs28858177   A   C    0    1    1    0    0
9   22 16855618   rs5747010   G   A    0    1    1    0    0
10  22 16855731   rs5748914   G   C    0    1    1    0    0
...
```
