# init folder with " cmake . " and build with "make" or "make VERBOSE=1" for 
# more build details
# rm -rf build; mkdir build; cd build; cmake -DCMAKE_BUILD_TYPE=Release .. ; make VERBOSE=1; ./dgemm; cd ..;
cmake_minimum_required(VERSION 3.10)
project(dgemm CXX)

## compile time cuda check
include(CheckLanguage)
check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
  enable_language(CUDA)
else()
  message(STATUS "No CUDA compiler found")
endif()


## set C++11 as standard
set (CMAKE_CXX_STANDARD 11)

## check for link time optimization (LTO, INTERPROCEDURAL_OPTIMIZATION)
include(CheckIPOSupported)
check_ipo_supported(RESULT lto_supported OUTPUT error)

## define where headers are located
include_directories(${PROJECT_SOURCE_DIR})

include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-mavx" mavx_supported)
if (mavx_supported)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mavx")
else()
    CHECK_CXX_COMPILER_FLAG("/arch:AVX" msvc_avx_supported)
    if(msvc_avx_supported)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:AVX")
    endif()
endif()

################################################################################
##                 definition of the dgemmlib as static lib                   ##
################################################################################
find_package(CUDA 5.0)
if (CUDA_FOUND)
    if(NOT DEFINED CMAKE_CUDA_STANDARD)
        set(CMAKE_CUDA_STANDARD 11)
        set(CMAKE_CUDA_STANDARD_REQUIRED ON)
    endif()

    add_library(dgemmlib STATIC dgemm.cpp dgemm_avx2.cpp dgemm_avx512.cpp dgemm_cuda.cu)

    # set(CUDA_SEPARABLE_COMPILATION ON)
    # set(CUDA_PROPAGATE_HOST_FLAGS OFF)
    # set_target_properties(dgemmlib PROPERTIES
    #         POSITION_INDEPENDENT_CODE ON
    #         CUDA_SPARABLE_COMPILATION ON)

    LIST(APPEND CUDA_NVCC_FLAGS "--gpu-architecture=compute_50")

    target_link_libraries(dgemmlib -lcublas)
else()
    add_library(dgemmlib STATIC dgemm.cpp dgemm_avx2.cpp dgemm_avx512.cpp dgemm_cuda.cpp)
endif()



## enable compiler warnings
if (MSVC)
    target_compile_options(dgemmlib PUBLIC $<$<COMPILE_LANGUAGE:CXX>:/W4 /WX>)
else()
    target_compile_options(dgemmlib PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-Wall -Wextra -pedantic -Werror>)
    target_compile_options(dgemmlib PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-Wunreachable-code -Werror=format-security>)
endif()

## check for Openmp and enable it if available
find_package(OpenMP)
IF (OPENMP_FOUND)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif()

## check for threadlib and add it, 
## causes that lpthread is added twice due to openmp, which however is optional
find_package(Threads REQUIRED)
target_link_libraries(dgemmlib Threads::Threads)

## enable LTO is supported
if (lto_supported)
    set_property(TARGET dgemmlib PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()

if (MSVC)
    set_source_files_properties(dgemm_avx2.cpp PROPERTIES COMPILE_FLAGS /arch:AVX2)
    set_source_files_properties(dgemm_avx2.cpp PROPERTIES COMPILE_FLAGS -mfma)
    set_source_files_properties(dgemm_avx512.cpp PROPERTIES COMPILE_FLAGS /arch:AVX512)
else()
    set_source_files_properties(dgemm_avx2.cpp PROPERTIES COMPILE_FLAGS -mavx2)
    set_source_files_properties(dgemm_avx2.cpp PROPERTIES COMPILE_FLAGS -mfma)
    set_source_files_properties(dgemm_avx512.cpp PROPERTIES COMPILE_FLAGS -mavx512f)
endif()

set(BLA_VENDOR Generic)
find_package(BLAS REQUIRED)
target_link_libraries(dgemmlib ${BLAS_LIBRARIES})

################################################################################
##                  definition of the main/executable                         ## 
################################################################################
add_executable(dgemm main.cpp)
## define that dgemm depends on the dgemmlib
target_link_libraries(dgemm dgemmlib)

## enable LTO is supported
if (lto_supported)
    set_property(TARGET dgemm PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()