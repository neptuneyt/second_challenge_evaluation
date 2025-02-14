library(ggplot2)
library(reshape2)
library(plotly)
library(dplyr)
library(ggpubr)
library(svglite)

# creates a own color palette from red to green
my_palette <- colorRampPalette(c("white", "black"))(n = 3)

# (optional) defines the color breaks manually for a "skewed" color transition
col_breaks = c(seq(0,0.5,length=1),  # for white
               seq(0.5,0.94,length=1),
               seq(0.95,1.0,length=1)) # for black
              

# NOW: read from Adrian's table
mar_unique<-read.delim("marine_unique.tsv", sep='\t', header=FALSE,col.names = c("Genome","unique"))
lot_unique<-read.delim("rhizosphere_unique.tsv", sep='\t', header=FALSE,col.names = c("Genome","unique"))

#Zhi-Luo's data
mar_pooled_genomefraction<-read.delim("all_min_identity98_Genome_fraction.txt", 
                                 sep='\t',header = TRUE,na.strings = "-")
names(mar_pooled_genomefraction)[names(mar_pooled_genomefraction) == "Assemblies"] <- "Genome"

lot_pooled_genomefraction<-read.delim("Lotus_gf.tsv", 
                                      sep='\t',header = TRUE,na.strings = "-")
names(lot_pooled_genomefraction)[names(lot_pooled_genomefraction) == "Assemblies"] <- "Genome"

#lot_pooled_hybrid_cov<-read.delim("coverage_lotus.tsv", row.names=1, header=F)
lot_pooled_cov<-read.delim("lotus_coverage_merged.tsv", header=F)

mar_pooled_hybrid_cov<-read.delim("coverage_hybrid.tsv")
mar_pooled_hybrid_cov<-select(mar_pooled_hybrid_cov,Genome,sum)
mar_pooled_cov<-read.delim("coverage_new_datamash.tsv",header=FALSE)

colnames(mar_pooled_cov)<-c("Genome","coverage")
colnames(mar_pooled_hybrid_cov)<-c("Genome","coverage")
mar_pooled_cov$Genome <- gsub('-', '_', mar_pooled_cov$Genome)
mar_pooled_hybrid_cov$Genome <- gsub('-', '_', mar_pooled_hybrid_cov$Genome)
mar_pooled_hybrid_cov$Genome <- gsub('.fasta', '', mar_pooled_hybrid_cov$Genome)

colnames(lot_pooled_cov)<-c("Genome","coverage")
lot_pooled_cov$Genome <- gsub('-', '_', lot_pooled_cov$Genome)
lot_pooled_cov$Genome <- gsub('.fasta', '', lot_pooled_cov$Genome)

mar_pooled_hybrid_cov<-bind_rows(mar_pooled_hybrid_cov, mar_pooled_cov) %>%
   group_by(Genome) %>%
   summarise_all(funs(sum(., na.rm = TRUE)))

mar_pooled_merged<-merge(mar_pooled_cov,mar_pooled_genomefraction,by="Genome")
mar_pooled_merged<-merge(mar_unique,mar_pooled_merged,by="Genome")
mar_pooled_merged_hybrid<-merge(mar_pooled_hybrid_cov,mar_pooled_genomefraction,by="Genome")
mar_pooled_merged_hybrid<-merge(mar_unique,mar_pooled_merged_hybrid,by="Genome")

lot_pooled_merged<-merge(lot_pooled_cov,lot_pooled_genomefraction,by="Genome")
lot_pooled_merged<-merge(lot_unique,lot_pooled_merged,by="Genome")
#lot_pooled_merged_hybrid<-merge(lot_pooled_hybrid_cov,lot_pooled_genomefraction,by="Genome")
#lot_pooled_merged_hybrid<-merge(lot_unique,lot_pooled_merged_hybrid,by="Genome")

# remove the plasmids for now
#mar_pooled_merged_no_plasmids<-mar_pooled_merged[!grepl("RNODE", mar_pooled_merged$Genome),]
lot_pooled_merged<-lot_pooled_merged[!grepl("RNODE", lot_pooled_merged$Genome),]

# do not remove, but change plasmids to own uniqueness type
mar_pooled_merged[grepl("RNODE", mar_pooled_merged$Genome), "unique"] <- "circular"
mar_pooled_merged[grepl("RNODE", mar_pooled_merged$Genome), "coverage"] <- mar_pooled_merged[grepl("RNODE", mar_pooled_merged$Genome), "coverage"]*10
mar_pooled_merged_hybrid[grepl("RNODE", mar_pooled_merged_hybrid$Genome), "unique"] <- "circular"
mar_pooled_merged_hybrid[grepl("RNODE", mar_pooled_merged_hybrid$Genome), "coverage"] <- mar_pooled_merged_hybrid[grepl("RNODE", mar_pooled_merged_hybrid$Genome), "coverage"]*10

lot_pooled_merged[grepl("RNODE", lot_pooled_merged$Genome), "unique"] <- "circular"
lot_pooled_merged[grepl("RNODE", lot_pooled_merged$Genome), "coverage"] <- lot_pooled_merged[grepl("RNODE", lot_pooled_merged$Genome), "coverage"]*10
#lot_pooled_merged_hybrid[grepl("RNODE", lot_pooled_merged_hybrid$Genome), "unique"] <- "circular"
#lot_pooled_merged_hybrid[grepl("RNODE", lot_pooled_merged_hybrid$Genome), "coverage"] <- lot_pooled_merged_hybrid[grepl("RNODE", lot_pooled_merged_hybrid$Genome), "coverage"]*10


# select subset for plotting
#df1<-mar_pooled_merged
#df2<-mar_pooled_merged_hybrid
#df1 <- select(df1,Genome,coverage,unique,ABySS_short,HipMer_Metagenome_short,Megahit_v1.1.4.2_short,metaSPAdes_v3.13.1_short,Ray.Meta_short)
#df2 <- select(df2,Genome,coverage,unique,pooled_hybrid_gsa,A.STAR_contig_hybrid,Miniasm_GATB_hybrid,OPERA.MS.inhouse_hybrid)
#df3 <- select(mar_pooled_merged,Genome,coverage,unique,pooled_short_gsa)
#colnames(df1) <- c("Genome", "coverage", "unique","ABySS (short)","HipMer (short)","MEGAHIT (short)","SPAdes (short)","Ray (short)")
#colnames(df2) <- c("Genome", "coverage", "unique","GSA (hybrid)","A-STAR (hybrid)","GATB (hybrid)","OPERA-MS (hybrid)")
#colnames(df3) <- c("Genome", "coverage", "unique","GSA (short)")
#df_melted1 <- melt(df1,id=c("Genome","unique","coverage"))
#df_melted2 <- melt(df2,id=c("Genome","unique","coverage"))
#df_melted3 <- melt(df3,id=c("Genome","unique","coverage"))
##df_melted[grepl("RNODE", mar_pooled_merged$Genome),]
#colnames(df_melted1)<-c("Genome","unique","coverage","assembler","genome_fraction")
#colnames(df_melted2)<-c("Genome","unique","coverage","assembler","genome_fraction")
#colnames(df_melted3)<-c("Genome","unique","coverage","assembler","genome_fraction")
#fun <- function (x) min(x,100)
#df_melted1[grepl("RNODE",df_melted1$Genome), "genome_fraction"] <- unlist(lapply(df_melted1[grepl("RNODE",df_melted1$Genome), "genome_fraction"]*10, fun))
#df_melted2[grepl("RNODE",df_melted2$Genome), "genome_fraction"] <- unlist(lapply(df_melted2[grepl("RNODE",df_melted2$Genome), "genome_fraction"]*10, fun))
#df_melted3[grepl("RNODE",df_melted3$Genome), "genome_fraction"] <- unlist(lapply(df_melted3[grepl("RNODE",df_melted3$Genome), "genome_fraction"]*10, fun))

df<-lot_pooled_merged
df_melted <- melt(df,id=c("Genome","unique","coverage"))
#df_melted[grepl("RNODE", mar_pooled_merged$Genome),]
colnames(df_melted)<-c("Genome","unique","coverage","assembler","genome_fraction")
fun <- function (x) min(x,100)
df_melted[grepl("RNODE",df_melted$Genome), "genome_fraction"] <- unlist(lapply(df_melted[grepl("RNODE",df_melted$Genome), "genome_fraction"]*10, fun))

# plot unique only
#ggplot(df_melted[df_melted$unique=="uniq",],aes(x=coverage,y=genome_fraction,colour=unique,group=assembler)) + geom_point(size=0.7) +
#  scale_x_continuous(trans='log') + facet_grid(assembler ~ .) + scale_color_manual(values=c("#1b9e77"))

scaleFUN <- function(x) sprintf("%.0f", x)

#high_gf1 <- filter(filter(df_melted1, unique == "uniq"), genome_fraction > 90)
#min_covs1 <- high_gf1 %>% group_by(assembler, coverage) %>%
#   slice(which.min(coverage))
#vals1 <- select(min_covs1[!duplicated(min_covs1$assembler),],assembler, coverage)
#high_gf2 <- filter(filter(df_melted2, unique == "uniq"), genome_fraction > 90)
#min_covs2 <- high_gf2 %>% group_by(assembler, coverage) %>%
#   slice(which.min(coverage))
#vals2 <- select(min_covs2[!duplicated(min_covs2$assembler),],assembler, coverage)
#high_gf3 <- filter(filter(df_melted3, unique == "uniq"), genome_fraction > 90)
#min_covs3 <- high_gf3 %>% group_by(assembler, coverage) %>%
#   slice(which.min(coverage))
#vals3 <- select(min_covs3[!duplicated(min_covs3$assembler),],assembler, coverage)
high_gf <- filter(filter(df_melted, unique == "uniq"), genome_fraction > 90)
min_covs <- high_gf %>% group_by(assembler, coverage) %>%
   slice(which.min(coverage))
vals <- select(min_covs[!duplicated(min_covs$assembler),],assembler, coverage)

plot <- ggplot(df_melted,aes(x=coverage,y=genome_fraction,colour=unique,group=assembler)) + 
   geom_point(shape=16, size=0.85) +
   facet_wrap(assembler ~ ., ncol = 2) +
   scale_x_continuous(trans='log', labels=scaleFUN) +  
   #   geom_vline(xintercept=20, color="gray") +
   geom_vline(data=vals, mapping = aes(xintercept=vals$coverage), color=" dark gray") + 
   scale_y_continuous(breaks=c(0,50,100)) +
   scale_color_manual(values=c("#1b9e77", "#7570b3","#e7298a","#66a61e"), name="Genome groups", label=c("Spiked genomes", "Funghi", "Unique (ANI <95%)", "Common (ANI \u2265 95%)")) + 
   theme(strip.text.y = element_text(size = 6), legend.position='top', panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
         panel.background = element_blank(), axis.line = element_line(colour = "black"), legend.text=element_text(size=14)) +
   guides(colour = guide_legend(override.aes = list(size=2.5))) +
   xlab("Sequencing coverage") + ylab("Genome fraction (%)")
#ggsave(file="Coverage_lotus.png", plot=p)

# plot all
plot1 <- ggplot(df_melted1,aes(x=coverage,y=genome_fraction,colour=unique,group=assembler)) + 
   geom_point(shape=16, size=0.85) +
   facet_wrap(assembler ~ ., ncol = 1) +
   scale_x_continuous(trans='log', labels=scaleFUN) +  
#   geom_vline(xintercept=20, color="gray") +
   geom_vline(data=vals1, mapping = aes(xintercept=vals1$coverage), color=" dark gray") + 
   scale_y_continuous(breaks=c(0,50,100)) +
   scale_color_manual(values=c("#d95f02", "#1b9e77", "#7570b3"), name="Genome groups", label=c("Circular elements", "Common (ANI \u2265 95%)", "Unique (ANI <95%)")) + 
  theme(strip.text.y = element_text(size = 6), legend.position='top', panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"),
        text=element_text(size=14), legend.text=element_text(size=14), axis.text=element_text(size=12), axis.title=element_text(size=14)) +
   guides(colour = guide_legend(override.aes = list(size=2.5))) +
  xlab("Sequencing coverage") + ylab("Genome fraction (%)")

plot2 <- ggplot(df_melted3,aes(x=coverage,y=genome_fraction,colour=unique,group=assembler)) + 
   geom_point(shape=16, size=0.85) +
   geom_point(data=df_melted2,shape=16, size=0.85) + 
   scale_x_continuous(trans='log', labels=scaleFUN, breaks=c(1,20,403,8103)) + 
   facet_wrap(assembler ~ ., ncol = 1) + 
#   geom_vline(xintercept=20, color="gray") +
   geom_vline(data=vals3, mapping = aes(xintercept=vals3$coverage), color=" dark gray") +
   geom_vline(data=vals2, mapping = aes(xintercept=vals2$coverage), color=" dark gray") +
   scale_y_continuous(breaks=c(0,50,100)) +
   scale_color_manual(values=c("#d95f02", "#1b9e77", "#7570b3"), name="Genome groups", label=c("Circular elements", "Common (ANI \u2265 95%)", "Unique (ANI <95%)")) + 
   theme(strip.text.y = element_text(size = 6), legend.position='top', panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
         panel.background = element_blank(), axis.line = element_line(colour = "black"), 
         text=element_text(size=14), axis.text=element_text(size=14), axis.title=element_text(size=14)) +
   guides(colour = guide_legend(override.aes = list(size=2.5))) +
   xlab("Sequencing coverage") + ylab("Genome fraction (%)")

p <- ggarrange(plot1, plot2, ncol=2, common.legend=TRUE)

#ggsave(file="Coverage_marked.png", plot=p)
ggsave(file="Coverage.svg", plot=p)

#ggplot(df_melted1,aes(x=coverage,y=genome_fraction,colour=unique,group=assembler)) + geom_point(size=0.7) +
#   geom_point(data=df_melted2,size=0.7) + geom_point(data=df_melted3,size=0.7) + 
#   scale_x_continuous(trans='log', labels=scaleFUN) + facet_wrap(assembler ~ ., ncol = 2) + 
#   scale_y_continuous(breaks=c(0,50,100)) +
#   scale_color_manual(values=c("#1b9e77","#7570b3","#d95f02"), name="Genome groups", label=c("Circular elements", "Strains (ANI >95%)", "Unique (ANI <95%)")) + 
#   theme(strip.text.y = element_text(size = 6), legend.position='top', panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
#         panel.background = element_blank(), axis.line = element_line(colour = "black")) +
#   xlab("Sequencing coverage") + ylab("Genome fraction")


