FROM mjmg/centos-mro-rstudio-opencpu-shiny-server

# Build packages with multiple threads
RUN \
  MAKE="make $(nproc)"

RUN \
  yum install -y cairo-devel libXt-devel opencv-devel

RUN \
  cd /tmp && \
  git clone --recursive https://github.com/dmlc/mxnet

RUN \
  cd mxnet && \
  make USE_OPENCV=1 USE_BLAS=mkl USE_MKL2017=1 USE_MKL2017_EXPERIMENTAL=1

RUN \
  echo "/usr/local/lib" >> /etc/ld.so.conf.d/local-lib.conf && \
  ldconfig

RUN \
  cd /tmp/mxnet/ && \
  make rpkg && \
  R CMD INSTALL mxnet_current_r.tar.gz

ADD \
  test-mxnet.R /tmp/test-mxnet.R

# Test MXnet on docker host
RUN \
  Rscript -e "source('/tmp/test-mxnet.R')"

# Define default command.
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
