FROM ubuntu:14.04

RUN apt-get update && apt-get install -y \
        g++ \
        gfortran \
        build-essential \
        wget \
        git \
        libssl-dev \
        libpng-dev \
        libfreetype6-dev \
        libxft-dev \
        libhdf5-dev \
        libsqlite3-dev \
        libbz2-dev \
        zlib1g-dev \
        liblapack-dev \
        texlive \
        pandoc \
        && \
    apt-get clean
    
ENV PREFIX=/scratch
RUN mkdir -p ${PREFIX} && \
    cd ${PREFIX} && \
    mkdir archive && \
    mkdir source && \
    mkdir build && \
    mkdir install

# install python
RUN export PYTHON_URL=https://www.python.org/ftp/python/2.7.10/Python-2.7.10.tar.xz && \
    export PYTHON_MD5=c685ef0b8e9f27b5e3db5db12b268ac6 && \
    export PYTHON_ARCHIVE=${PREFIX}/archive/python-2.7.10.tar.xz && \
    export PYTHON_SOURCE_DIR=${PREFIX}/source/python/2.7.10 && \
    export PYTHON_BUILD_DIR=${PREFIX}/build/python/2.7.10 && \
    export PYTHON_INSTALL_DIR=/opt/python/2.7.10 && \
    wget --quiet ${PYTHON_URL} --output-document=${PYTHON_ARCHIVE} && \
    echo "${PYTHON_MD5} ${PYTHON_ARCHIVE}" | md5sum -c && \
    mkdir -p ${PYTHON_SOURCE_DIR} && \
    tar -xf ${PYTHON_ARCHIVE} -C ${PYTHON_SOURCE_DIR} --strip-components=1 && \
    mkdir -p ${PYTHON_BUILD_DIR} && \
    cd ${PYTHON_BUILD_DIR} && \
    ${PYTHON_SOURCE_DIR}/configure \
        --prefix=${PYTHON_INSTALL_DIR} \
        CFLAGS="-fPIC" \
        && \
    make install && \
    rm -rf ${PYTHON_ARCHIVE} && \
    rm -rf ${PYTHON_BUILD_DIR} && \
    rm -rf ${PYTHON_SOURCE_DIR}

ENV PATH=/opt/python/2.7.10/bin:${PATH}

# install pip
RUN cd ${PREFIX}/source && \
    wget --quiet https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py --no-cache-dir && \
    rm -rf get-pip.py && \
    pip install -U pip --no-cache-dir && \
    pip install --no-cache-dir \
        numpy \
        scipy \
        matplotlib \
        cython \
        h5py \
        pypandoc \
        jupyter
    
# install cmake
RUN export CMAKE_URL=https://cmake.org/files/v3.3/cmake-3.3.2.tar.gz && \
    export CMAKE_SHA256=e75a178d6ebf182b048ebfe6e0657c49f0dc109779170bad7ffcb17463f2fc22 && \
    export CMAKE_ARCHIVE=${PREFIX}/archive/cmake-3.3.2.tar.gz && \
    export CMAKE_SOURCE_DIR=${PREFIX}/source/cmake/3.3.2 && \
    export CMAKE_BUILD_DIR=${PREFIX}/build/cmake/3.3.2 && \
    export CMAKE_INSTALL_DIR=/opt/cmake/3.3.2 && \
    wget --quiet ${CMAKE_URL} --output-document=${CMAKE_ARCHIVE} && \
    echo "${CMAKE_SHA256} ${CMAKE_ARCHIVE}" | sha256sum -c && \
    mkdir -p ${CMAKE_SOURCE_DIR} && \
    tar -xf ${CMAKE_ARCHIVE} -C ${CMAKE_SOURCE_DIR} --strip-components=1 && \
    mkdir -p ${CMAKE_BUILD_DIR} && \
    cd ${CMAKE_BUILD_DIR} && \
    ${CMAKE_SOURCE_DIR}/configure \
        --prefix=${CMAKE_INSTALL_DIR} \
        && \
    make install && \
    rm -rf ${CMAKE_ARCHIVE} && \
    rm -rf ${CMAKE_BUILD_DIR} && \
    rm -rf ${CMAKE_SOURCE_DIR}

ENV PATH=/opt/cmake/3.3.2/bin:${PATH}

# install boost
RUN export BOOST_URL=http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.bz2 && \
    export BOOST_SHA1=b94de47108b2cdb0f931833a7a9834c2dd3ca46e && \
    export BOOST_ARCHIVE=${PREFIX}/archive/boost_1_59_0.tar.bz2 && \
    export BOOST_SOURCE_DIR=${PREFIX}/source/boost/1.59.0 && \
    export BOOST_BUILD_DIR=${PREFIX}/build/boost/1.59.0 && \
    export BOOST_INSTALL_DIR=/opt/boost/1.59.0 && \
    wget --quiet ${BOOST_URL} --output-document=${BOOST_ARCHIVE} && \
    echo "${BOOST_SHA1} ${BOOST_ARCHIVE}" | sha1sum -c && \
    mkdir -p ${BOOST_SOURCE_DIR} && \
    tar -xf ${BOOST_ARCHIVE} -C ${BOOST_SOURCE_DIR} --strip-components=1 && \
    cd ${BOOST_SOURCE_DIR} && \
    ./bootstrap.sh \
        --prefix=${BOOST_INSTALL_DIR} \
        && \
    ./b2 install \
        variant=release \
        link=static \
        cxxflags="-fPIC" \
        --build-dir=${BOOST_BUILD_DIR} \
        && \
    rm -rf ${BOOST_ARCHIVE} && \
    rm -rf ${BOOST_BUILD_DIR} && \
    rm -rf ${BOOST_SOURCE_DIR}

# install dealii
RUN export DEAL_II_URL=https://github.com/dealii/dealii/releases/download/v8.3.0/dealii-8.3.0.tar.gz && \
    export DEAL_II_SHA1=274288b09c053b461239040816129a9eb9d45914 && \
    export DEAL_II_ARCHIVE=${PREFIX}/archive/dealii-8.3.0.tar.gz && \
    export DEAL_II_SOURCE_DIR=${PREFIX}/source/dealii/8.3.0 && \
    export DEAL_II_BUILD_DIR=${PREFIX}/build/dealii/8.3.0 && \
    export DEAL_II_INSTALL_DIR=/opt/dealii/8.3.0 && \
    wget --quiet ${DEAL_II_URL} --output-document=${DEAL_II_ARCHIVE} && \
    echo "${DEAL_II_SHA1} ${DEAL_II_ARCHIVE}" | sha1sum -c && \
    mkdir -p ${DEAL_II_SOURCE_DIR} && \
    tar -xf ${DEAL_II_ARCHIVE} -C ${DEAL_II_SOURCE_DIR} --strip-components=1 && \
    mkdir -p ${DEAL_II_BUILD_DIR} && \
    cd ${DEAL_II_BUILD_DIR} && \
    cmake \
        -D CMAKE_INSTALL_PREFIX=${DEAL_II_INSTALL_DIR} \
        -D CMAKE_BUILD_TYPE=Release \
        -D BOOST_DIR=/opt/boost/1.59.0 \
        ${DEAL_II_SOURCE_DIR} && \
    make install && \
    rm -rf ${DEAL_II_ARCHIVE} && \
    rm -rf ${DEAL_II_BUILD_DIR} && \
    rm -rf ${DEAL_II_SOURCE_DIR}

# install cap
ENV LD_LIBRARY_PATH=/opt/dealii/8.3.0/lib:${LD_LIBRARY_PATH}
ENV LD_LIBRARY_PATH=/opt/boost/1.59.0/lib:${LD_LIBRARY_PATH}
RUN cd ${PREFIX}/source && \
    git clone https://github.com/dalg24/cap.git && \
    git clone https://github.com/dalg24/cap-data.git && \
    mkdir -p ${PREFIX}/build/cap && \
    cd ${PREFIX}/build/cap && \
    cmake \
        -D CMAKE_INSTALL_PREFIX=/opt/cap \
        -D CMAKE_CXX_FLAGS="-fPIC" \
        -D BOOST_INSTALL_DIR=/opt/boost/1.59.0 \
        -D DEAL_II_INSTALL_DIR=/opt/dealii/8.3.0 \
        -D PYTHON_INSTALL_DIR=/opt/python/2.7.10 \
        -D CAP_DATA_DIR=${PREFIX}/source/cap-data \
        ${PREFIX}/source/cap && \
   make install

ENV PYTHONPATH=/opt/cap/python:${PYTHONPATH}

# run tests for the python wrappers
RUN cd ${PREFIX}/build/cap/python && \
   ctest -V

# install tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.7.0/tini && \
    echo "c6af7d7e95acfe0c840c2e65ed4a80400a7f73bb  tini" | shasum -c && \
    chmod +x tini && \
    mv tini /usr/local/bin/
    
ENV SHELL /bin/bash
ENV NB_USER jovyan
ENV NB_UID 1000

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir /home/$NB_USER/.jupyter && \
    mkdir /home/$NB_USER/.local && \
    chown -R $NB_USER:users /home/$NB_USER

RUN cd /home/$NB_USER && \
    git clone https://github.com/dalg24/cap-notebooks.git && \
    chown -R $NB_USER:users /home/$NB_USER/cap-notebooks


EXPOSE 8888
WORKDIR /home/$NB_USER
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]


COPY start-notebook.sh /usr/local/bin/
COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/
RUN chown -R $NB_USER:users /home/$NB_USER/.jupyter
