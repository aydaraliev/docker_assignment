# docker assignment

#### This repository contains Dockerfile that builds an image that is based on Ubuntu 18.04 and contains the following software with all the dependencies:
	
	* samtools version 1.12 with htslib plugins
	* libdeflate version 1.7
	* biobambam2 version 2.0.182-release-20210412001032

All software is installed on a separate layer in /SOFT directory.

##### To build the image go to the directory containing dockerfile and enter:
`docker image build -t docker_assignment`
##### To run the container:
`docker container run docker_assignment`
##### If you want to go to the container sh:
`docker container run -it docker_assignment`
