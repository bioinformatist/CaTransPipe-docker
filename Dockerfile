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
