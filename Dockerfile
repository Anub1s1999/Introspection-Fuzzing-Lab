FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Base dependencies (including gnupg for apt-key)
RUN apt-get update && apt-get install -y \
    wget \
    git \
    make \
    cmake \
    build-essential \
    gdb \
    openssh-server \
    sudo \
    vim \
    python3 \
    python3-pip \
    graphviz \
    lcov \
    gcovr \
    curl \
    perl \
    gnupg \
    lsb-release \
    libssl-dev \
    libpsl-dev \
    gcc-12\
    g++-12\
    && rm -rf /var/lib/apt/lists/*

# 2. Add LLVM repository key (using apt-key, which handles GPG natively)
RUN wget -O- https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -

# 3. Add the LLVM 14 repository to sources.list
RUN echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-14 main" > /etc/apt/sources.list.d/llvm.list

# 4. Install Clang 14, LLVM, and XRay tools
RUN apt-get update && apt-get install -y \
    clang-14 \
    lld-14 \
    llvm-14 \
    libclang-rt-14-dev \
    && rm -rf /var/lib/apt/lists/*

# 5. Create symlinks for convenience
RUN ln -s /usr/bin/clang-14 /usr/bin/clang && \
    ln -s /usr/bin/clang++-14 /usr/bin/clang++ && \
    ln -s /usr/bin/llvm-xray-14 /usr/bin/llvm-xray

# 6. Create symlinks for convenience
RUN ln -sf /usr/bin/clang-14 /usr/bin/clang && \
    ln -sf /usr/bin/clang++-14 /usr/bin/clang++ && \
    ln -sf /usr/bin/llvm-xray-14 /usr/bin/llvm-xray

# 6.5 Install flex and bison (required to build cyclo)
RUN apt-get update && apt-get install -y flex bison && rm -rf /var/lib/apt/lists/*

# 7. Install lizard (modern cyclomatic complexity analyzer)
RUN pip3 install lizard
# 8. Install AFL++ 
COPY AFLplusplus /opt/AFLplusplus
RUN cd /opt/AFLplusplus && make && make install

# 9. Install Flame Graph script
RUN git clone https://github.com/brendangregg/FlameGraph.git /opt/FlameGraph

WORKDIR /workspace
CMD ["/bin/bash"]