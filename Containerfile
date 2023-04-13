FROM quay.io/opendatahub-contrib/workbench-images:cuda-jupyter-datascience-c9s-py39_2023b_latest
LABEL auhtor="Erik Jacobs <erikmjacobs@gmail.com>"
USER 0
RUN dnf -y install libsndfile espeak-ng && yum -y clean all
USER 1001
