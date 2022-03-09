# Check GPGPU-Sim is ready. If not, please source its setup_environment script first.
GPGPUSIM_SETUP_ENVIRONMENT_WAS_RUN ?= 0
ifneq ($(GPGPUSIM_SETUP_ENVIRONMENT_WAS_RUN), 1)
$(error GPGPU-Sim environment is not setup)
endif

SIM_CONFIG_DIR ?= $(GPGPUSIM_ROOT)/configs/tested-cfgs
SIM_DEVICE ?= SM7_QV100
SIM_ARCH ?= compute_72
SIM_CONFIG_FILE = $(SIM_CONFIG_DIR)/$(SIM_DEVICE)/gpgpusim.config

CUDA_INSTALL_PATH ?= /usr/local/cuda

CUDA_LIB_DIR= -L$(CUDA_INSTALL_PATH)/lib64
CUDA_INC_DIR= -I$(CUDA_INSTALL_PATH)/include
CUDA_LINK_LIBS= -lcudart

GXX = g++
GXX_FLAGS =
GXX_LIBS =

NVCC = nvcc
NVCC_FLAGS =
NVCC_LIBS =

NVCC_FLAGS += --cudart shared \
			  -lcublas_static \
			  -lcudnn_static \
			  -gencode arch=$(SIM_ARCH),code=$(SIM_ARCH)

TARGET_DIR = bin
SOURCE_DIR = src
OBJECT_DIR = build
INCLUDE_DIR = include

TARGET = $(TARGET_DIR)/main.run
OBJECTS = $(OBJECT_DIR)/main.o $(OBJECT_DIR)/kernel.o
TARGET_RUN_CONFIG = $(TARGET_DIR)/gpgpusim.config

.PHONY : compile
compile : $(TARGET)

# Link
$(TARGET) : $(OBJECTS) | $(TARGET_DIR)
	$(GXX) $(GXX_FLAGS) $^ -o $@ $(CUDA_INC_DIR) $(CUDA_LIB_DIR) $(CUDA_LINK_LIBS)

# Compile main.cpp file to object files:
$(OBJECT_DIR)/%.o : %.cpp | $(OBJECT_DIR)
	$(GXX) $(GXX_FLAGS) -c $< -o $@ $(GXX_LIBS)

# Compile C++ source files to object files:
$(OBJECT_DIR)/%.o : $(SOURCE_DIR)/%.cpp $(INCLUDE_DIR)/%.h | $(OBJECT_DIR)
	$(GXX) $(GXX_FLAGS) -c $< -o $@ $(GXX_LIBS)

# Compile CUDA source files to object files:
$(OBJECT_DIR)/%.o : $(SOURCE_DIR)/%.cu $(INCLUDE_DIR)/%.cuh | $(OBJECT_DIR)
	$(NVCC) $(NVCC_FLAGS) -c $< -o $@ $(NVCC_LIBS)

$(OBJECT_DIR) $(TARGET_DIR):
	mkdir -p $@

.PHONY : simconfig
simconfig :
	cp $(SIM_CONFIG_FILE) $(TARGET_RUN_CONFIG)

.PHONY : run
run : $(TARGET) simconfig
	cd $(<D); ./$(<F)

.PHONY : clean
clean :
	$(RM) -r $(OBJECT_DIR)/* $(TARGET_DIR)/*
