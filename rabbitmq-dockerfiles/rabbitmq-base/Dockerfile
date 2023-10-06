FROM ub8:1

# Install dependencies
RUN dnf -y update && dnf -y install \
    openssl-devel \
    tar \
    gcc \
    perl \
    ncurses-devel \
    wget \
    procps \
    logrotate \
    unzip \
    autoconf \
    m4 \
    openssl \
    wget \
    make \
    git \
    socat \
    less 

# Add OpenSSL 3.0.11
RUN yum install perl-core zlib-devel -y
WORKDIR /usr/local/src
RUN wget https://www.openssl.org/source/openssl-3.0.11.tar.gz
RUN tar -zxf openssl-3.0.11.tar.gz
WORKDIR /usr/local/src/openssl-3.0.11
RUN ./config enable-fips \
    --prefix="/opt/openssl" \
    --openssldir="/opt/openssl/etc/ssl" \
    --libdir="/opt/openssl/lib" \
    -Wl,-rpath="/opt/openssl/lib" 

RUN make
RUN make install_sw install_ssldirs install_fips
RUN make install

RUN ldconfig -v
RUN mv /bin/openssl /bin/openssl.bak
RUN ln -s /opt/openssl/bin/openssl /usr/bin/
ENV OPENSSL_PATH="/usr/local/src/openssl-3.0.11"
ENV PATH=$OPENSSL_PATH:$PATH
ENV OPENSSLDIR="/opt/openssl/etc/ssl"

# Copy RedHats CA
RUN rm -rf /opt/openssl/etc/ssl/certs \
    rm -rf /opt/openssl/etc/ssl/private && \
    ln -sf /etc/ssl/certs /etc/ssl/private /opt/openssl/etc/ssl

# FIPS enabe OpenSSL
RUN openssl fipsinstall -out /opt/openssl/etc/ssl/fipsmodule.cnf -module /opt/openssl/lib/ossl-modules/fips.so
COPY openssl.cnf /opt/openssl/etc/ssl/openssl.cnf

# Verification Tasks
RUN echo $PATH
RUN which openssl
RUN openssl version -a

# Download and build Erlang 26.1 with FIPS 140-2 compliant cryptography
RUN wget https://github.com/erlang/otp/archive/OTP-26.1.tar.gz
RUN tar xvzf OTP-26.1.tar.gz
WORKDIR otp-OTP-26.1
RUN ./otp_build configure --prefix="/opt/erlang" \
    --with-ssl="/opt/openssl" \
    --enable-fips

RUN make
RUN make install

# Check that Erlang/OTP crypto & ssl were compiled against OpenSSL correctly
ENV ERLANG_INSTALL_PATH_PREFIX=/"opt/erlang"
ENV OPENSSL_INSTALL_PATH_PREFIX="/opt/openssl"
ENV PATH $ERLANG_INSTALL_PATH_PREFIX/bin:$PATH

# Download and install RabbitMQ 3.12.5
WORKDIR /
RUN wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.12.5/rabbitmq-server-3.12.5-1.el8.noarch.rpm
RUN rpm -ivh --nodeps rabbitmq-server-3.12.5-1.el8.noarch.rpm

# Set environment variables
ENV PATH /opt/rabbitmq/sbin:$PATH

# Expose the RabbitMQ ports
EXPOSE 5672 15672

# Set the default command to run when the container starts
CMD ["rabbitmq-server"]

