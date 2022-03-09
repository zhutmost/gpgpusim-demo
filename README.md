# GPGPU-Sim Example Code

**作者**：Haozhe Zhu (GitHub @ zhutmost)

本仓库将帮助你立刻上手使用 GPGPU-Sim 运行你的 CUDA 代码。
以下将提供完整的保姆级教程。

## Dependencies

首先请确定你能访问一台配备真实 NVIDIA GPU 的服务器，服务器上已经安装了 Docker。

### Docker GPU 环境

由于缺乏服务器的管理员权限，我们需要在 Docker 中运行程序。为了在 Docker 内使用 GPU，我们使用 NVIDIA 提供的带有 CUDA 和 CuDNN Docker 镜像，而非普通的 Ubuntu 镜像。

运行下面的命令创建一个名为 `hzzhu_accelsim` 的 Docker 虚拟机：
```
docker run --name=hzzhu_accelsim -it --gpus all -v /home/haozhe/Workspace/dockerhome:/root nvidia/cuda:11.5.1-cudnn8-devel-ubuntu20.04 bash
```
其中，`-v` 用于将宿主机目录 `../dockerhome` 挂载在虚拟机的 `/root` 作为其home目录。
注意上述虚拟机命名、文件目录等都是基于我的个人环境，请自行甄别修改。

启动虚拟机：
```
docker start hzzhu_accelsim
```

以后每次想访问虚拟机时，运行：
```
docker exec -it hzzhu_accelsim zsh
```
由于本人个人喜好，这里使用 `zsh` 作为登录的 Shell 程序。在首次运行上述虚拟机时，`zsh` 还没有安装，因此需要先用 `bash` 登录，安装 `zsh` 后退出并重新用 `zsh` 登录。以下所有命令都是在 `zsh` 中运行的，理论上 `zsh` 兼容 `bash`，但我不能提供任何保证。

更多 Docker 相关的操作命令，请自行阅读 Docker 的[文档](https://docs.docker.com/get-started/)。

### 安装依赖

根据个人喜好设置开发环境：
- 安装 `zsh` 及 [Oh My Zsh](https://ohmyz.sh/)（这不是必要的，存粹是个人喜好）；
- 安装 `git`、`vim`，并进行必要的设置；
- 创建文件夹 `/root/Workspace` ，之后的开发都在此文件夹内进行。

该镜像已经原生安装好了 CUDA 等 GPU 的开发环境，只需要在 `.zshrc` 文件中设置：
```bash
export CUDA_INSTALL_PATH="/usr/local/cuda"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$CUDA_INSTALL_PATH/lib64"
export PTXAS_CUDA_INSTALL_PATH="/usr/local/cuda"
```

安装 GPGPU-Sim 所需的依赖：
```bash
apt-get install build-essential xutils-dev bison zlib1g-dev flex libglu1-mesa-dev
```

### 拷贝 GPGPU-Sim 仓库到本地

拷贝 GPGPU-Sim 仓库至 `~/Workspace` 文件夹下，并切换至 `dev` 分支：
```bash
git clone git@github.com:gpgpu-sim/gpgpu-sim_distribution.git ~/Workspace/gpgpu-sim
git checkout dev
```

### 编译 GPGPU-Sim

在 `~/Workspace/gpgpu-sim` 目录下，运行：
```bash
source setup_environment <build_type>
make -j
```
这里 `<build_type>` 可以是 `debug` 或 `release`，这取决于后续是否需要进行 GDB 调试，具体可以阅读 GPGPU-Sim 的仓库 README 文档。我这里选择 `debug`。


GPGPU-Sim 目前发展至 4.0 版本，但官方文档主要还停留在 3.x 版本。
GPGPU-Sim 4.0 同时是 [Accel-Sim](https://accel-sim.github.io/) 的组件，关于后者的信息，可以访问[官方 GitHub 仓库](https://github.com/accel-sim/accel-sim-framework)阅读其 README 文档。
Accel-Sim 的官方安装流程错误颇多，必要时可以阅读我的幻灯片。
本仓库不会涉及任何 Accel-Sim 相关内容。

至此，编译已经完成，我们可以开始运行程序了。

## Run Your CUDA Code

每次退出 Docker 虚拟机或重新启动 `zsh` 后，需要重新在 `~/Workspace/gpgpu-sim` 目录下，运行：
```bash
source setup_environment <build_type>
```
否则，GPGPU-Sim 将不起作用，后续流程会变成普通的 CUDA 编译运行流程。

### 拷贝本仓库到本地

拷贝本仓库至 `~/Workspace` 文件夹下：
```bash
git clone git@github.com:zhutmost/gpgpusim-demo.git ~/Workspace/demo
```

### 编译 Example 代码

本仓库在 `src` 文件夹下提供了一个简单的 CUDA 加法的例子。我们接下来进行编译：
```bash
make compile   # 调用 G++ 和 NVCC 编译产生可执行文件 bin/main.run
make simconfig # 拷贝 GPGPU-Sim 提供的 GPU 模型配置文件至 bin/ 文件夹下
```

清除编译和运行产生的文件：
```bash
make clean
```

GPGPU-Sim 提供了一些预置的 GPU 模型配置，在 `$(GPGPUSIM_ROOT)/configs/tested-cfgs` 文件夹下，你可以自行查看。默认情况下，本仓库使用 `SM7_QV100` 作为默认的 GPU 模型配置。
欲使用其他 GPU 模型配置，在 `make simconfig` 时可以指定：
```bash
make simconfig SIM_DEVICE=SM7_QV100 SIM_ARCH=compute_72
```
其中某一 GPU 型号对应的 `gencode` 版本（即 `SIM_ARCH=compute_xx` 中的 `xx`）可以在[该网站](https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/)查询。

编译时有一些选项可供控制我们的编译流程。这里不一一列举，具体可以阅读 `Makefile`。

### 运行仿真

编译后，会生成可执行文件 `bin/main.run`。
对其使用 `ldd` 命令，可以看到 GPGPU-Sim 的相关编译结果作为库被链接到了该程序：
```bash
ldd ./bin/main.run
```
可以看到类似这样的输出：
```
$ ldd hello
    linux-vdso.so.1 (0x00007ffd10df7000)
    libcudart.so.11.0 => /root/Workspace/gpgpu-sim/lib/...
    ...
```

运行该程序：
```bash
make run       # 运行仿真程序
```
这是一个很简单的例子，仿真大概需要十秒钟。
最后你可以看到输出 `C = A + B = 1 + 2 = 3`，以及大量仿真统计数据（Cache、Interconnect等）。
