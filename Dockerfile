FROM ubuntu

LABEL authors="zhaoqi@sysucc.org.cn,sun_yu@mail.nankai.edu.cn" \
	description="Docker image containing all requirements for CaTransPipe"

# Update OS
# DEBIAN_FRONTEND=noninteractive is for relieving the dependence of readline perl library by prohibiting interactive frontend
# default-jre is for NextFlow (run groovy)
# gcc and g++ is for compiling CPAT, PLEK as well as some R packages
# gfortran is for compiling R package hexbin (required by plotly)
# May need libblas-dev, liblapack-dev and libgsl0ldbl (this one perhaps no longer existed) for rMATS
# make is for executing makefiles for several tools
# Cython provides C header files like Python.h for CPAT compiling
# DO NOT use pip for installing Cython, which will cause missing .h files
# libudunits2-dev is for installing R package units
# liblzo2-dev is for compiling during RSeQC installation
# zlib1g-dev is for CPAT compiling dependency
# libncurses5-dev for samtools (may be used later)
# libssl-dev is for R package openssl
# libxml2-dev is for R package XML, which is needed by DESeq2
# libcurl4-openssl-dev is for R package curl
# perl brings us FindBin module, which is required by FastQC
# ca-certificates is required by aria2
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get -qq update && \
	apt-get -qq install -y --no-install-recommends \
	default-jre \
	unzip \
	pbzip2 \
	pigz \
	aria2 \
	gcc \
	g++ \
	gfortran \
	make \
	python-dev \
	cython \
	libudunits2-dev \
	liblzo2-dev \
	zlib1g-dev \
	libssl-dev \
	libxml2-dev \
	libcurl4-openssl-dev \
	perl \
	ca-certificates

# Install STAR
RUN aria2c https://github.com/alexdobin/STAR/raw/master/bin/Linux_x86_64_static/STAR -q -o /opt/STAR && \
	chmod 777 /opt/STAR && \
	ln -s /opt/STAR /usr/local/bin

# Use bash instead for shopt only works with bash
SHELL ["/bin/bash", "-c"]

# Install FastQC
RUN aria2c https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.7.zip -q -o /opt/fastqc_v0.11.7.zip && \
	unzip -qq /opt/fastqc_v0.11.7.zip -d /opt/ && \
	rm /opt/fastqc_v0.11.7.zip && \
	cd /opt/FastQC && \
	shopt -s extglob && \
	rm -rfv !\("fastqc"\|*.jar\) && \
	chmod 777 * && \
	ln -s /opt/FastQC/fastqc /usr/local/bin/

# Set back to default shell
SHELL ["/bin/sh", "-c"]

# Install latest pip WITHOUT wheel but WITH setuptools
# DO NOT use apt-get python-pip in ubuntu for preventing from complicated related tools and libraries
# setuptools is required by RSeQC during its installation
RUN aria2c https://bootstrap.pypa.io/get-pip.py -q -o /opt/get-pip.py && \
	python /opt/get-pip.py --no-wheel && \
	rm /opt/get-pip.py

# Install RSeQC
RUN pip install RSeQC

# Install QualiMap
# http://qualimap.bioinfo.cipf.es/doc_html/intro.html#installation
RUN aria2c https://bitbucket.org/kokonech/qualimap/downloads/qualimap_v2.2.1.zip -q -o /opt/qualimap_v2.2.1.zip && \
	unzip -qq /opt/qualimap_v2.2.1.zip -d /opt/ && \
	rm /opt/qualimap_v2.2.1.zip && \
	cd /opt/qualimap_v2.2.1 && \
	rm HISTORY QualimapManual.pdf qualimap.bat && \
	ln -s /opt/qualimap_v2.2.1/qualimap /usr/local/bin/

# Install MultiQC
RUN pip install multiqc

# Install STAR-Fusion
RUN aria2c https://github.com/STAR-Fusion/STAR-Fusion/releases/download/STAR-Fusion-v1.4.0/STAR-Fusion-v1.4.0.FULL.tar.gz -q -o /opt/STAR-Fusion-v1.4.0.FULL.tar.gz && \
	tar xf /opt/STAR-Fusion-v1.4.0.FULL.tar.gz --use-compress-prog=pigz -C /opt/ && \
	cd /opt/STAR-Fusion-v1.4.0 && \
	make && \
	rm -rf Docker ChangeLog *notes *wiki test* Makefile README.md STAR-Fusion.github.io Changelog.txt Changelog.txt && \
	rm /opt/STAR-Fusion-v1.4.0.FULL.tar.gz && \
	ln -s /opt/STAR-Fusion-v1.4.0/STAR-Fusion /usr/local/bin/

# Install GATK
RUN aria2c https://github.com/broadinstitute/gatk/releases/download/4.0.5.1/gatk-4.0.5.1.zip -q -o /opt/gatk-4.0.5.1.zip && \
	unzip -qq /opt/gatk-4.0.5.1.zip -d /opt/ && \
	rm /opt/gatk-4.0.5.1.zip && \
	cd /opt/gatk-4.0.5.1 && \
	rm -rf GATKConfig.EXAMPLE.properties README.md gatkdoc && \
	ln -s /opt/gatk-4.0.5.1/gatk /usr/local/bin/

# Install Picard
# https://broadinstitute.github.io/picard/
RUN aria2c https://github.com/broadinstitute/picard/releases/download/2.18.7/picard.jar -q -o /opt/picard.jar

# Install ANNOVAR
RUN aria2c http://www.openbioinformatics.org/annovar/download/0wgxR2rIVP/annovar.latest.tar.gz -q -o /opt/annovar.latest.tar.gz && \
	tar xf /opt/annovar.latest.tar.gz --use-compress-prog=pigz -C /opt/ && \
	rm /opt/annovar.latest.tar.gz && \
	rm /opt/annovar/example/README && \
	ln -s /opt/STAR-Fusion-v1.4.0/*.pl /usr/local/bin/

# Install cpanm
RUN echo 'yes' | cpan App::cpanminus

# Install necessary Perl modules
# Use commands like perldoc -l XML::Simple to check if modules installed
RUN cpanm VCF Statistics::Basic

# Install rMATS
# http://rnaseq-mats.sourceforge.net/user_guide.htm
RUN aria2c https://sourceforge.net/projects/rnaseq-mats/files/MATS/rMATS.4.0.2.tgz/download -q -o /opt/rMATS.4.0.2.tgz && \
	tar xf /opt/rMATS.4.0.2.tgz --use-compress-prog=pigz -C /opt/ && \
	rm -rf /opt/rMATS.4.0.2/rMATS-turbo-Linux-UCS2 && \
	rm /opt/rMATS.4.0.2/rMATS-turbo-Linux-UCS4/README-rMATS-turbo.md && \
	rm /opt/rMATS.4.0.2.tgz && \
	ln -s /opt/rMATS.4.0.2/rMATS-turbo-Linux-UCS4/rmats.py /usr/local/bin/

# Install Microsoft-R-Open with MKL, you must use MRO v3.4.2 or later
# For more, see this GitHub issue comment: https://github.com/Microsoft/microsoft-r-open/issues/26#issuecomment-340276347
RUN aria2c https://mran.blob.core.windows.net/install/mro/3.5.0/microsoft-r-open-3.5.0.tar.gz -q -o /opt/microsoft-r-open-3.5.0.tar.gz && \
	tar xf /opt/microsoft-r-open-3.5.0.tar.gz --use-compress-prog=pigz -C /opt/ && \
	cd /opt/microsoft-r-open && \
	./install.sh -au && \
	rm -rf /opt/microsoft-r*

# Cleaning up the apt cache helps keep the image size down (must be placed here, since MRO installation need the cache)
RUN rm -rf /var/lib/apt/lists/*

# To fix problem by mozjepg (will cause error when running MRO)
# See https://github.com/tcoopman/image-webpack-loader/issues/95
RUN aria2c http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb -q -o /tmp/libpng12.deb && \
	dpkg -i /tmp/libpng12.deb && \
	rm /tmp/libpng12.deb

# Setup R configs
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile

# Install R packages from CRAN
# Shiny is for htmlwidgets
RUN Rscript -e "install.packages('shiny')" \
			-e "install.packages('optparse')" \
			-e "install.packages('getopt')" \
			-e "install.packages('ggplot2')" \
			-e "install.packages('pheatmap')" \
			-e "install.packages('reshape2')"

# Install R packages from Bioconductor
RUN Rscript -e "source('http://bioconductor.org/biocLite.R');" \ 
			-e 'biocLite("NOISeq")' \
			-e 'biocLite("EBSeq")' \
			-e 'biocLite("NOISeq")' \
			-e 'biocLite("DESeq2")' \
			-e 'biocLite("edgeR")' \
			-e 'biocLite("chimeraviz")' \
			-e 'biocLite("clusterProfiler")' \
			-e 'biocLite("ReactomePA")' \