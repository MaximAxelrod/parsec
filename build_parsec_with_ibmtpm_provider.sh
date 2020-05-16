# Installation commands

# This procedure will build the following project tree: 
# - PROJECTS_FOLDER might be any folder on Linux PC, for example ~

# $PROJECTS_FOLDER
#    ├── ibmtpm1332
#    ├── parsec
#    ├── tpm2-tools
#    └── tpm2-tss


# install RUST, protoc, parsec, clang
export PROJECTS_FOLDER=/sharedhome/$USER
cd $PROJECTS_FOLDER
echo "######################################################################"
echo "# install rust"
echo "######################################################################"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env


echo "######################################################################"
echo "# install protoc"
echo "######################################################################"
sudo apt install protobuf-compiler


echo "######################################################################"
echo "# install parsec with specific build anr runtime config files"
echo "######################################################################"
git clone git@github.com:MaximAxelrod/parsec.git --branch prov-client-tools-private

cd $PROJECTS_FOLDER

echo "######################################################################"
echo "#install clang and tools"
echo "######################################################################"
sudo apt-get update -y
sudo apt install -y clang
sudo apt-get install -y clang-tools

echo "######################################################################"
echo "# install tss prerequisites"
echo "######################################################################"
sudo apt -y install autoconf-archive libcmocka0 libcmocka-dev procps iproute2 build-essential pkg-config libtool automake libssl-dev uthash-dev autoconf doxygen libjson-c-dev libini-config-dev libcurl4-openssl-dev libgcrypt-dev

echo "######################################################################"
echo "# install tss libs"
echo "######################################################################"
git clone https://github.com/tpm2-software/tpm2-tss.git --branch 2.3.3 \
&& cd tpm2-tss \
&& ./bootstrap \
&& ./configure \
&& make -j$(nproc) \
&& sudo make install \
&& sudo ldconfig

cd $PROJECTS_FOLDER

echo "######################################################################"
echo "# install tpm2-tools"
echo "######################################################################"
git clone https://github.com/tpm2-software/tpm2-tools.git --branch 4.1 \
&& cd tpm2-tools \
&& ./bootstrap \
&& ./configure --enable-unit \
&& sudo make install

cd $PROJECTS_FOLDER

echo "######################################################################"
echo "# install ibmtpm"
echo "######################################################################"
wget -nv https://sourceforge.net/projects/ibmswtpm2/files/ibmtpm1332.tar.gz \
&& mkdir ibmtpm1332 && cd ibmtpm1332 \
&& mv ../ibmtpm1332.tar.gz . \
&& tar xvzf ibmtpm1332.tar.gz \
&& cd src \
&& make


echo "######################################################################"
echo "build parsec with tpm-provider"
echo "######################################################################"
cd $PROJECTS_FOLDER/parsec
RUST_LOG=info cargo build --features tpm-provider
