FROM quay.io/opendatahub-contrib/workbench-images:cuda-jupyter-datascience-c9s-py39_2023b_latest
LABEL author="Erik Jacobs <erikmjacobs@gmail.com>"
USER 0
RUN dnf config-manager --set-enabled crb && \
  dnf install -y epel-release epel-next-release
RUN dnf -y install libsndfile espeak-ng portaudio portaudio-devel llvm11-libs \
  llvm11 screen && yum -y clean all && usermod -a -G tty default && chmod 777 /run/screen
USER 1001
