library(glmnet)
options(stringsAsFactors=F)
library(data.table)
library(dplyr)
library(tidyr)
library(matrixStats)
args = commandArgs(trailingOnly=TRUE)


####################################
########## Pre-selection ###########
####################################
pre_select <- function(region, comb){
  p_diff = c()
  for (j in 1:length(region$snp)){
    lm2 = lm(comb$betaM ~ comb[,region$snp[j]] + comb[,paste0(region$snp[j],'_diff')])
    
    if (is.null(lm2)==F & nrow(coef(summary(lm2)))==3){
      p_diff = c(p_diff, coef(summary(lm2))[3,'Pr(>|t|)'])
    }else{
      p_diff = c(p_diff, 1)
    }
    print(j)
  }
  return(p_diff)
}




########## read data
pheno.file <- as.character(args[1])
genoAFR.file <- as.character(args[2])
genoEUR.file <- as.character(args[3])
Mformat <- as.character(args[4])
output.file <- as.character(args[5])

#pheno.file <- '/gpfs/gibbs/pi/zhao/yc769/MethylPred/LAMPP/example/test_pheno.txt'
#genoAFR.file <- '/gpfs/ycga/project/xu_ke/yc769/MethylPred/LA/result/VACS_seq_chr22_AFR.RData'
#genoEUR.file <- '/gpfs/ycga/project/xu_ke/yc769/MethylPred/LA/result/VACS_seq_chr22_EUR.RData'
#Mformat <- 'seq'


pheno = as.data.frame(fread(pheno.file, header=T))
obj_name1 = load(genoAFR.file)
snpAFR1 = get(obj_name1)
obj_name2 = load(genoEUR.file)
snpEUR1 = get(obj_name2)



########## default arguments (optional)
threshold <- gsub(x = args[grep(x = args, pattern = "threshold=")], pattern = "threshold=", replacement = "")
threshold = ifelse(length(threshold)==0, 0.005, as.numeric(threshold))
print(threshold)


########## combine snp_AFR, snp_EUR, phen
#select the region within 500kn
info = snpAFR1[,1:5]
region = info[abs(info$bp - mean(pheno$position)) < 500000,]

snpAFR1 = snpAFR1[snpAFR1$snp %in% region$snp, ]
df_AFR=as.data.frame(t(snpAFR1))
colnames(df_AFR)=df_AFR[3,]
df_AFR=df_AFR[-c(1:5), ]
dim(df_AFR)
df_AFR[1:5,1:5]
df_AFR2 = as.data.frame(apply(df_AFR, 2, as.numeric))

snpEUR1 = snpEUR1[snpEUR1$snp %in% region$snp, ]
df_EUR=as.data.frame(t(snpEUR1))
colnames(df_EUR)=df_EUR[3,]
df_EUR=df_EUR[-c(1:5), ]
dim(df_EUR)
df_EUR[1:5,1:5]
df_EUR2 = as.data.frame(apply(df_EUR, 2, as.numeric))

#create the required design matrix
geno = df_AFR2 + df_EUR2
diff = (df_AFR2 - df_EUR2)/2
rownames(geno) = rownames(df_AFR)
rownames(diff) = rownames(df_AFR)
colnames(diff) = paste0(colnames(diff),'_diff')
table(rownames(geno) == rownames(diff))
G = as.data.frame(cbind(geno, diff))

#impute missing genotype 
meanimpute <- function(x) ifelse(is.na(x),mean(x,na.rm=T),x)
G <- as.data.frame(apply(G,2,meanimpute))

G$ID = rownames(geno)
comb = inner_join(pheno, G)
comb = comb[is.na(comb$betaM)==F,]
dim(comb)

########## run the algorithm
p_diff = pre_select(region, comb)
X = c(region$snp, paste0(region$snp,'_diff')[p_diff<threshold])
length(X)
TrainX = comb[, X]
dim(TrainX)

#Methylation in count data from seq
if (Mformat == 'seq') {
  Train_DNAm = comb[, c('Unmethy_count', 'Methy_count')]
  cv = cv.glmnet(as.matrix(TrainX), as.matrix(Train_DNAm), nfolds=10, alpha=0.5, family = "binomial",type.measure = "mse")
}

#Methylation in beta value from array
if (Mformat == 'array') {
  Train_DNAm = comb[, 'betaM']
  cv = cv.glmnet(as.matrix(TrainX), Train_DNAm, nfolds=10, alpha=0.5, family="gaussian")
}

#get output
coeff = as.data.frame(as.matrix(coef(cv, s = "lambda.min")))
coeff$probe = pheno$cpg[1]
coeff$SNP = rownames(coeff)

coeff = coeff[coeff$s1 != 0, ]
coeff = coeff[, c('probe','SNP','s1')]
coeff = separate(coeff,SNP,c("snp","effect"),remove = F, sep ='_')
coeff = left_join(coeff, region, by = 'snp')
coeff = coeff[,c('probe','snp','bp','ref','alt','effect','s1')]
colnames(coeff)[7] = 'coefficient'
coeff[coeff$effect %in% 'diff', 'effect'] = 'b_diff'
coeff[is.na(coeff$effect) & coeff$snp != '(Intercept)', 'effect'] = 'b_average'
head(coeff)

write.table(coeff, output.file, quote = F, row.names = F, col.names = T, sep ="\t")

