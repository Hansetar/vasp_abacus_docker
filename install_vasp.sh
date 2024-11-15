#!/bin/bash

# 使用方法:
# ./install_vasp.sh [工作目录]
# 如果没有提供工作目录，默认使用 /home/src

# 默认工作目录
default_dir_src="/home/src"

# 检查是否提供了参数
if [ "$#" -eq 1 ]; then
    dir_src=$1
else
    dir_src=$default_dir_src
fi

# 如果目录不存在，则创建
if [ ! -d "$dir_src" ]; then
    mkdir -p $dir_src
fi
export dir_src

sudo apt-get update 
sudo apt-get upgrade -y 
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    cmake pkg-config build-essential wget rsync \
    python3 \
    python3-pip \
    python3-numpy \
    python3-scipy \
    python3-matplotlib \
    gfortran \
    liblapack-dev \
    libblas-dev \
    gcc g++  gfortran vim sed make unzip fonts-dejavu \
    libopenblas-openmp-dev liblapack-dev libscalapack-mpi-dev libelpa-dev libfftw3-dev libcereal-dev libxc-dev g++ make cmake bc git pkgconf \
    libcereal-dev  build-essential



# 复制必要的文件到工作目录
cp  ./vasp.6.4.2.tgz $dir_src
wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/e6ff8e9c-ee28-47fb-abd7-5c524c983e1c/l_BaseKit_p_2024.2.1.100_offline.sh
wget https://registrationcenter-download.intel.com/akdlm/IRC_NAS/d461a695-6481-426f-a22f-b5644cd1fa8b/l_HPCKit_p_2024.2.1.79_offline.sh

# 复制必要的文件到工作目录
cp  ./l_BaseKit_p_2024.2.1.100_offline.sh $dir_src
cp  ./l_HPCKit_p_2024.2.1.79_offline.sh $dir_src





# 安装编译环境
cd $dir_src
export TERM=xterm
sh ./l_BaseKit_p_2024.2.1.100_offline.sh -a --silent --cli --eula accept
sh ./l_HPCKit_p_2024.2.1.79_offline.sh -a --silent --cli --eula accept

# 写道bashrc中
echo 'source /opt/intel/oneapi/setvars.sh ' >> ~/.bashrc
source ~/.bashrc

# 修改MKL路径和权限
cd /opt/intel/oneapi/mkl/2024.2/share/mkl/interfaces/fftw3xf
chmod 777 ../fftw3xf
chmod 777 ./*
make libintel64






# 安装vasp
cd $dir_src
tar -zxvf vasp.6.4.2.tgz
cd vasp.6.4.2
cp arch/makefile.include.intel makefile.include
sed -i 's/CC_LIB      = icc/CC_LIB      = icx/g' makefile.include
sed -i 's/CXX_PARS    = icpc/CXX_PARS    = icpx/g' makefile.include

# 检测CPU架构
if [[ $(lscpu | grep 'Vendor\ ID' | awk '{print$3}') == "AuthenticAMD" ]]; then 
    # 如果是AMD CPU，执行sed命令
    sed -i 's/FC          = mpiifort/FC          = mpiifx/' makefile.include && 
    sed -i 's/FCL         = mpiifort/FCL         = mpiifx/' makefile.include && 
    sed -i 's/MKLROOT    ?= \/path\/to\/your\/mkl\/installation/MKLROOT    ?=  \/opt\/intel\/oneapi\/mkl\/2024.2/' makefile.include && 
    sed -i 's/INCS        =-I$(MKLROOT)\/include\/fftw/INCS        =-I$(MKLROOT)\/include\/fftw   -I\/opt\/intel\/oneapi\/mpi\/2021.13\/include/' makefile.include && 
    sed -i 's/FCL        += -qmkl=sequential/FCL        += -qmkl=sequential    -xCORE-Avx2/' makefile.include; 
fi

# 编译
source /opt/intel/oneapi/setvars.sh --force
make


echo "export PATH=\$PATH:$(echo $dir_src)/vasp.6.4.2/bin" >> ~/.bashrc

echo "vasp安装完毕"