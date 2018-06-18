FROM ubuntu

LABEL authors="zhaoqi@sysucc.org.cn,sun_yu@mail.nankai.edu.cn" \
	description="Docker image containing all requirements for CaTransPipe"

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

# Install RSeQC
RUN aria2c https://sourceforge.net/projects/rseqc/files/RSeQC-2.3.7.tar.gz/download -q -o /opt/RSeQC-2.3.7.tar.gz && \
	tar xf /opt/RSeQC-2.3.7.tar.gz --use-compress-prog=pigz -C /opt/ && \
	cd /opt/RSeQC-2.3.7 && \
	python setup.py install

# python -c ‘from qcmodule import SAM


