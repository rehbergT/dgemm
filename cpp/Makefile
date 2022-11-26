ARCH = native
CXXFLAGS = -std=gnu++11 -O3 -flto -march=$(ARCH) -mtune=$(ARCH) -fopenmp -DCOLUMN_MAJOR
WARNINGS = -Wall -Wextra -Wunreachable-code -Werror=format-security -pedantic-errors
LIBS = -lcudart -lcublas -fopenmp -lblas

NVCC_FLAGS = -DCOLUMN_MAJOR -arch=sm_61 -Xcompiler -fopenmp
CUDA_INC = /usr/local/cuda/include

### Detect normal cpp file, avx2/avx512 cpp files and cuda files
cpp_sources = $(wildcard ../dgemmR/src/*.cpp)
avx2_sources = $(wildcard ../dgemmR/src/*avx2.cpp)
avx512_sources = $(wildcard ../dgemmR/src/*avx512.cpp)
cu_sources = $(wildcard ../dgemmR/src/*.cu)

### avx sources are also in cpp_sources -> filter them
cpp_sources += main.cpp
cpp_sources := $(filter-out $(avx2_sources),$(cpp_sources))
cpp_sources := $(filter-out $(avx512_sources),$(cpp_sources))
cpp_sources := $(filter-out ../dgemmR/src/wrapper.cpp, $(cpp_sources))

### create variables for the specific objects
cpp_objects := $(patsubst %.cpp, %.o, $(cpp_sources))
avx2_objects := $(patsubst %.cpp, %.o, $(avx2_sources))
avx512_objects := $(patsubst %.cpp, %.o, $(avx512_sources))
cu_objects := $(patsubst %.cu, %.o, $(cu_sources))

### change output path for the target objects
cpp_objects := $(subst ../dgemmR/src/, , $(cpp_objects))
avx2_objects := $(subst ../dgemmR/src/, , $(avx2_objects))
avx512_objects := $(subst ../dgemmR/src/, , $(avx512_objects))
cu_objects := $(subst ../dgemmR/src/, , $(cu_objects))

OBJECTS = $(cpp_objects) $(avx2_objects) $(avx512_objects) $(cu_objects)

all: $(OBJECTS)
	$(CXX) $(OBJECTS) $(LIBS) -o dgemm

$(cpp_objects): $(cpp_sources)
	$(CXX) $(CXXFLAGS) $(WARNINGS) -c $(filter %$*.cpp, $^) -o $@

$(avx2_objects): $(avx2_sources)
	$(CXX) $(CXXFLAGS) $(WARNINGS) -mavx2 -mfma -c $(filter %$*.cpp, $^) -o $@

$(avx512_objects): $(avx512_sources)
	$(CXX) $(CXXFLAGS) $(WARNINGS) -mavx512f -c $(filter %$*.cpp, $^) -o $@

$(cu_objects): $(cu_sources)
	nvcc $(NVCC_FLAGS) -I$(CUDA_INC) -c $(filter %$*.cu, $^) -o $@

clean:
	-rm -f *.o dgemm