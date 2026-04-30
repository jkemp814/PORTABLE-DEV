FROM fedora:44
RUN dnf install -y bash git make automake gcc bison \
    && git clone https://github.com/rofl0r/bashdb.git /tmp/bashdb \
    && cd /tmp/bashdb && ./autogen.sh && ./configure && make && make install \
    && rm -rf /tmp/bashdb
