FROM ubuntu:18.04

WORKDIR /SOFT

#Install dependencies for samtools compilation
RUN apt-get update && apt-get -y upgrade && \
	apt-get install -y build-essential wget git libssl-dev dh-autoreconf\
		libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev libcurl3-dev && \
	apt-get clean && apt-get purge && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Install samtools with htslib plugins
RUN wget https://github.com/samtools/samtools/releases/download/1.12/samtools-1.12.tar.bz2 && \
	tar jxf samtools-1.12.tar.bz2 && \
	rm samtools-1.12.tar.bz2 && \
	cd samtools-1.12 && \
	./configure --enable-plugins --prefix $(pwd) && \
	make all all-htslib && \
	make install install-htslib

ENV PATH=${PATH}:/SOFT/samtools-1.12:/SOFT/samtools-1.12/bin

#Install libdeflate
RUN git clone https://github.com/ebiggers/libdeflate.git && cd libdeflate && make

ENV PATH=${PATH}:/SOFT/libdeflate

#Install gcc/g++ 9 for libmaus2 compilation
RUN apt-get update && \
	apt-get install software-properties-common -y && \
	add-apt-repository ppa:ubuntu-toolchain-r/test && \
	apt-get install gcc-9 g++-9 -y && \
	update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 \
	--slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9

#Compile libmaus2 (prerequisite for biobambam2)
RUN wget https://gitlab.com/german.tischler/libmaus2/-/archive/2.0.794-release-20210706224245/libmaus2-2.0.794-release-20210706224245.tar.gz &&\
	tar -xvzf libmaus2-2.0.794-release-20210706224245.tar.gz && \
	rm libmaus2-2.0.794-release-20210706224245.tar.gz && \
	cd libmaus2-2.0.794-release-20210706224245 && \
	./configure --prefix=/SOFT/libmaus2 && \
	make -j8 && \
	make -j8 install && \
	rm -r /SOFT/libmaus2-2.0.794-release-20210706224245

#Install biobambam2
RUN wget https://gitlab.com/german.tischler/biobambam2/-/archive/2.0.182-release-20210412001032/biobambam2-2.0.182-release-20210412001032.tar.gz && \
	tar -xvzf biobambam2-2.0.182-release-20210412001032.tar.gz && \
	rm biobambam2-2.0.182-release-20210412001032.tar.gz &&\
	cd biobambam2-2.0.182-release-20210412001032 && \
	apt-get install autoconf automake libtool nasm pkgconf -y && \ 
	autoreconf -i -f && \
	export PKG_CONFIG_PATH=/SOFT/libmaus2/lib/pkgconfig && \
	./configure --prefix=/SOFT/biobambam2/ && \
	make -j8 install && \
	rm -r /SOFT/biobambam2-2.0.182-release-20210412001032  

ENV PATH=${PATH}:/SOFT/biobambam2/bin
