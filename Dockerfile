FROM rocker/shiny:latest
#FROM debian # for testing

MAINTAINER Kevin Son "eunwoo.son@sdstate.edu"
RUN apt-get update -qq && apt-get install -y \
  git-core \
  libcurl4-openssl-dev \
  libxml2-dev \
  libxml2  \
  libssl-dev \
  # https://stackoverflow.com/questions/42287164/install-udunits2-package-for-r3-3
  libudunits2-dev \ 
  libmariadb-client-lgpl-dev \
  wget \ 
  unzip

COPY ./RSet /usr/local/src/myscripts
COPY ./classes /usr/local/src/myscripts
COPY ./shinyapps /srv/shiny-server

RUN mkdir -p /srv/data/geneInfo
RUN mkdir -p /srv/data/gmt
RUN mkdir -p /srv/data/motif
RUN mkdir -p /srv/data/pathwayDB
RUN mkdir -p /srv/data/data_go

# Install R libraries
RUN R -e 'install.packages(c("devtools"))'
RUN R -e 'install.packages(c("shiny", "shinyAce", "shinyBS", "plotly",
  "RSQLite", "gplots", "ggplot2", "dplyr", #"tidyverse","plotly",
  "e1071", "reshape2", "DT","data.table", "Rcpp","WGCNA","flashClust","statmod","biclust","igraph","Rtsne"))'
RUN R -e 'source("https://bioconductor.org/biocLite.R"); biocLite(c("limma", "DESeq2", "edgeR", "gage", "PGSEA", "fgsea", "ReactomePA", "pathview", "PREDA",
  "impute", "runibic","QUBIC","rhdf5",
  "PREDAsampledata", "sfsmisc", "lokern", "multtest", "hgu133plus2.db", 
  "org.Ag.eg.db","org.At.tair.db","org.Bt.eg.db","org.Ce.eg.db","org.Cf.eg.db",
  "org.Dm.eg.db","org.Dr.eg.db","org.EcK12.eg.db","org.EcSakai.eg.db","org.Gg.eg.db",
  "org.Hs.eg.db","org.Hs.ipi.db","org.Mm.eg.db","org.Mmu.eg.db","org.Pf.plasmo.db",
  "org.Pt.eg.db","org.Rn.eg.db","org.Sc.sgd.db","org.Sco.eg.db","org.Ss.eg.db",
  "org.Tgondii.eg.db","org.Xl.eg.db"), suppressUpdates = T)'

# Download Required Data
RUN wget -qO- -O tmp.zip 'https://firebasestorage.googleapis.com/v0/b/firebase-bcloud.appspot.com/o/idep%2FgeneInfo%2FgeneInfo.zip?alt=media&token=a281e5cf-6900-493c-81e4-89ce423c26bb'\
  && unzip tmp.zip -d /srv/data && rm tmp.zip
# gmt file 
RUN wget -qO- -O tmp2.zip 'https://firebasestorage.googleapis.com/v0/b/firebase-bcloud.appspot.com/o/idep%2FgeneInfo%2Fgmt.zip?alt=media&token=5ee100d1-e645-41ef-a591-7a9ba208ce3c' \
  && unzip tmp2.zip -d /srv/data && rm tmp2.zip
RUN wget -qO- -O tmp3.zip 'https://firebasestorage.googleapis.com/v0/b/firebase-bcloud.appspot.com/o/idep%2FgeneInfo%2Fmotif.zip?alt=media&token=dc1e5972-ffd9-43a1-bbcc-49b78da6f047' \
  && unzip tmp3.zip -d /srv/data && rm tmp3.zip
RUN wget -qO- -O tmp4.zip 'https://firebasestorage.googleapis.com/v0/b/firebase-bcloud.appspot.com/o/idep%2FgeneInfo%2FpathwayDB.zip?alt=media&token=e602f2f7-102a-4cc4-8412-be2b05997daa' \
  && unzip tmp4.zip -d /srv/data && rm tmp4.zip
RUN wget -qO- -O tmp5.zip 'https://firebasestorage.googleapis.com/v0/b/firebase-bcloud.appspot.com/o/idep%2FgeneInfo%2FconvertIDs.db.zip?alt=media&token=55c80e8c-d5c1-43a5-995f-5e0c56242013' \
  && unzip tmp5.zip -d /srv/data && rm tmp5.zip
RUN wget -qO- -O tmp6.zip 'https://firebasestorage.googleapis.com/v0/b/firebase-bcloud.appspot.com/o/idep%2FgeneInfo%2Fdata_go.zip?alt=media&token=96ddcf70-ead4-4386-b582-18afe0386b8d' \
  && unzip tmp6.zip -d /srv/data && rm tmp6.zip

WORKDIR /usr/local/src/myscripts
# Install required R libraries
CMD ["Rscript", "librarySetup.R"]
#CMD ["/usr/bin/shiny-server.sh"] #If you don't use docker-compose need to comment out