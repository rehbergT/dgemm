#!/usr/bin/env bash
# this script creates all branches used for the tutorial out of the main branch

## delete local and remote branch and create a new clean branch
git branch -D      step_1_R_basic_package
git push origin -d step_1_R_basic_package
git checkout -b    step_1_R_basic_package

    ## clean up files
    rm -rf example.py dgemmPy .vscode create* cpp
    rm .github/workflows/Python_package.yml
    rm -rf dgemmR/src

    ## clean up file contents
    sed -i -e '13,26d;29,42d' dgemmR/tests/testthat/test_dgemm_equality.R
    sed -i -e '11d;20d;23,70d' dgemmR/R/dgemm.R
    sed -i -e 's/"blas"/"r_blas"/g' dgemmR/R/dgemm.R
    sed -i -e 's/} else if (algo_int == 14) {/if (algo == "r_loops") {/g' dgemmR/R/dgemm.R
    sed -i -e 's/} else {/} else if (algo == "r_blas") {/g' dgemmR/R/dgemm.R
    sed -i -e "16d" dgemmR/DESCRIPTION
    sed -i -e '1,20d;36,49d;52,65d;71,84d' example.R
    sed -i -e 's/, threads = 8//g' dgemmR/R/dgemm.R
    #sed -i -e '4,12d' .travis.yml

    ## create man files
    cd dgemmR
    echo "devtools::document()" | R --no-save --no-restore
    echo " devtools::test()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_1_R_basic_package
git checkout main


git branch -D      step_2_R_incorporating_C++
git push origin -d step_2_R_incorporating_C++
git checkout -b    step_2_R_incorporating_C++

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm .github/workflows/Python_package.yml
    rm -rf dgemmR/src/dgemm_avx2.cpp
    rm -rf dgemmR/src/dgemm_avx512.cpp
    rm -rf dgemmR/src/Parallel.h
    rm -rf dgemmR/src/dgemm_cuda.cu

    ## clean up file content
    sed -i -e '28,177d' dgemmR/src/dgemm.cpp
    sed -i -e '4,5d;7,9d;28,46d;49,76d;86,163d' dgemmR/src/dgemm.h
    sed -i -e 's/dgemm::dgemm_C(matrix_a, matrix_b, result, M, K, N, repeats, algo, threads,/dgemm::dgemm_C_loops(matrix_a, matrix_b, result, M, K, N, repeats, verbose);/g' dgemmR/src/wrapper.cpp
    sed -i -e '34d;36d;39d' dgemmR/src/wrapper.cpp
    sed -i -e "2d;4,39d" dgemmR/src/Makevars
    sed -i -e 's/\$(SHLIB_OPENMP_CXXFLAGS) //g' dgemmR/src/Makevars
    sed -i -e 's/ -pthread//g' dgemmR/src/Makevars
    sed -i -e '13,14d;16,26d;29,30d;32,42d' dgemmR/tests/testthat/test_dgemm_equality.R
    sed -i -e '11d;23,60d;66d;68d' dgemmR/R/dgemm.R
    sed -i -e 's/"blas"/"r_blas"/g' dgemmR/R/dgemm.R
    sed -i -e 's/if (algo_int < 14) {/if (algo == "loops") {/g' dgemmR/R/dgemm.R
    sed -i -e 's/(algo_int == 14)/(algo == "r_loops")/g' dgemmR/R/dgemm.R
    sed -i -e 's/} else {/} else if (algo == "r_blas") {/g' dgemmR/R/dgemm.R
    sed -i -e 's/, threads = 8//g' dgemmR/R/dgemm.R

    sed -i -e '1,20d;37,49d;53,65d;72,84d' example.R
    #sed -i -e '4,12d' .travis.yml
    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h

    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    echo " devtools::test()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_2_R_incorporating_C++
git checkout main




git branch -D      step_3_R_BLAS_C++
git push origin -d step_3_R_BLAS_C++
git checkout -b    step_3_R_BLAS_C++

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm .github/workflows/Python_package.yml
    rm -rf dgemmR/src/dgemm_avx2.cpp
    rm -rf dgemmR/src/dgemm_avx512.cpp
    rm -rf dgemmR/src/Parallel.h
    rm -rf dgemmR/src/dgemm_cuda.cu

    ## clean up file content
    sed -i -e '28,40d;105,119d;103d;128,174d' dgemmR/src/dgemm.cpp
    sed -i -e '4,5d;7,9d;51,52d;55,64d;75d;96,163d' dgemmR/src/dgemm.h
    sed -i -e 's/loops = 2/loops = 0/g' dgemmR/src/dgemm.h
    sed -i -e 's/blas = 3,/blas = 1/g' dgemmR/src/dgemm.h
    sed -i -e '36d;39d' dgemmR/src/wrapper.cpp
    sed -i -e 's/threads,/verbose);/g' dgemmR/src/wrapper.cpp
    sed -i -e "2d;4,37d" dgemmR/src/Makevars
    sed -i -e 's/\$(SHLIB_OPENMP_CXXFLAGS) //g' dgemmR/src/Makevars
    sed -i -e 's/ -pthread//g' dgemmR/src/Makevars
    echo "PKG_LIBS = \$(BLAS_LIBS) \$(FLIBS)" >> dgemmR/src/Makevars
    sed -i -e '13,14d;17,26d;29,30d;33,42d' dgemmR/tests/testthat/test_dgemm_equality.R
    sed -i -e '11d;24,27d;32,51d;56,57d;68d' dgemmR/R/dgemm.R
    sed -i -e 's/} else if (algo == "loops") {/if (algo == "loops") {/g' dgemmR/R/dgemm.R
    sed -i -e 's/<- 2/<- 0/g' dgemmR/R/dgemm.R
    sed -i -e 's/<- 3/<- 1/g' dgemmR/R/dgemm.R
    sed -i -e 's/<- 14/<- 2/g' dgemmR/R/dgemm.R
    sed -i -e 's/<- 15/<- 3/g' dgemmR/R/dgemm.R
    sed -i -e 's/< 14/< 2/g' dgemmR/R/dgemm.R
    sed -i -e 's/== 14/== 2/g' dgemmR/R/dgemm.R
    sed -i -e 's/, threads = 8//g' dgemmR/R/dgemm.R
    sed -i -e '1,20d;38,49d;54,65d;73,84d' example.R
    #sed -i -e '4,12d' .travis.yml
    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h

    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    echo " devtools::test()" | R --no-save --no-restore
    cd ..

## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_3_R_BLAS_C++
git checkout main




git branch -D      step_4_R_AVX
git push origin -d step_4_R_AVX
git checkout -b    step_4_R_AVX

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm .github/workflows/Python_package.yml
    rm -rf dgemmR/src/Parallel.h
    rm -rf dgemmR/src/dgemm_cuda.cu

    ## clean up file content
    sed -i -e '103d;115,117d;132,139d;144,171d' dgemmR/src/dgemm.cpp
    sed -i -e 's/threads, //g' dgemmR/src/dgemm.cpp
    sed -i -e 's/, 0);/);/g' dgemmR/src/dgemm.cpp    
    sed -i -e '5d;9d;56,57d;59,64d;75d;112d;114d;123d;125d;126,163d' dgemmR/src/dgemm.h
    sed -i -e 's/avx512 = 7,/avx512 = 5/g' dgemmR/src/dgemm.h
    sed -i -e 's/int verbose,/int verbose);/g' dgemmR/src/dgemm.h
    sed -i -e '10d;12d;63d;84,142d' dgemmR/src/dgemm_avx2.cpp
    sed -i -e 's/int verbose,/int verbose) {/g' dgemmR/src/dgemm_avx2.cpp
    sed -i -e '10d;12d;63d;86,146d' dgemmR/src/dgemm_avx512.cpp
    sed -i -e 's/int verbose,/int verbose) {/g' dgemmR/src/dgemm_avx512.cpp
    sed -i -e '36d;39d' dgemmR/src/wrapper.cpp
    sed -i -e 's/threads,/verbose);/g' dgemmR/src/wrapper.cpp
    sed -i -e "4,6d;13d;23d;35,37d" dgemmR/src/Makevars
    sed -i -e 's/\$(SHLIB_OPENMP_CXXFLAGS) //g' dgemmR/src/Makevars
    sed -i -e 's/ -pthread//g' dgemmR/src/Makevars
    sed -i -e 's/ \$(cu_objects)//g' dgemmR/src/Makevars
    sed -i -e 's/-L\$(CUDA_HOME)\/lib64 -Wl,-rpath,\$(CUDA_HOME)\/lib64 -lcudart -lcublas//g' dgemmR/src/Makevars
    sed -i -e '18,19d;21,26d;34,35d;37,42d' dgemmR/tests/testthat/test_dgemm_equality.R
    sed -i -e '11d;34,37d;40,51d;68d' dgemmR/R/dgemm.R
    sed -i -e 's/<- 7/<- 5/g' dgemmR/R/dgemm.R
    sed -i -e 's/<- 14/<- 6/g' dgemmR/R/dgemm.R
    sed -i -e 's/<- 15/<- 7/g' dgemmR/R/dgemm.R
    sed -i -e 's/< 14/< 6/g' dgemmR/R/dgemm.R
    sed -i -e 's/== 14/== 6/g' dgemmR/R/dgemm.R
    sed -i -e 's/, threads = 8//g' dgemmR/R/dgemm.R

    sed -i -e '1,20d;41,42d;44,49d;58,65d;76,77d;79,84d' example.R
    sed -i -e 's/c9/c7/g' example.R

    #sed -i -e '4,12d' .travis.yml
    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h

    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    echo " devtools::test()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_4_R_AVX
git checkout main






git branch -D      step_5_R_OpenMP
git push origin -d step_5_R_OpenMP
git checkout -b    step_5_R_OpenMP

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm .github/workflows/Python_package.yml
    rm -rf dgemmR/src/Parallel.h
    rm -rf dgemmR/src/dgemm_cuda.cu

    ## clean up file content
    sed -i -e '115,117d;136,139d;148,171d' dgemmR/src/dgemm.cpp  
    sed -i -e '9d;57d;60,64d;126,163d' dgemmR/src/dgemm.h
    sed -i -e 's/avx512 = 7,/avx512 = 6,/g' dgemmR/src/dgemm.h
    sed -i -e 's/avx512_omp = 8,/avx512_omp = 7/g' dgemmR/src/dgemm.h
    sed -i -e '113,141d' dgemmR/src/dgemm_avx2.cpp
    sed -i -e '116,145d' dgemmR/src/dgemm_avx512.cpp    
    sed -i -e "4,6d;13d;23d;35,37d" dgemmR/src/Makevars    
    sed -i -e 's/ -pthread//g' dgemmR/src/Makevars
    sed -i -e 's/ \$(cu_objects)//g' dgemmR/src/Makevars
    sed -i -e 's/-L\$(CUDA_HOME)\/lib64 -Wl,-rpath,\$(CUDA_HOME)\/lib64 -lcudart -lcublas//g' dgemmR/src/Makevars
    sed -i -e '19d;22,26d;35d;38,42d' dgemmR/tests/testthat/test_dgemm_equality.R
    sed -i -e '36,37d;42,51d' dgemmR/R/dgemm.R 
    sed -i -e 's/<- 7/<- 6/g' dgemmR/R/dgemm.R
    sed -i -e 's/<- 8/<- 7/g' dgemmR/R/dgemm.R    
    sed -i -e 's/<- 14/<- 8/g' dgemmR/R/dgemm.R    
    sed -i -e 's/<- 15/<- 9/g' dgemmR/R/dgemm.R
    sed -i -e 's/< 14/< 8/g' dgemmR/R/dgemm.R
    sed -i -e 's/== 14/== 8/g' dgemmR/R/dgemm.R
    sed -i -e '1,20d;42d;45,49d;60,65d;77d;80,84d' example.R
    sed -i -e '22s/c9/c8/g' example.R
    sed -i -e '23s/c10/c9/g' example.R

    #sed -i -e '4,12d' .travis.yml
    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h

    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    echo " devtools::test()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_5_R_OpenMP
git checkout main



git branch -D      step_6_R_C++Threads
git push origin -d step_6_R_C++Threads
git checkout -b    step_6_R_C++Threads

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm .github/workflows/Python_package.yml
    rm -rf dgemmR/src/dgemm_cuda.cu

    ## clean up file content
    sed -i -e '115,117d;152,171d' dgemmR/src/dgemm.cpp
    sed -i -e '61,64d;126,163d' dgemmR/src/dgemm.h
    sed -i -e "4,6d;13d;23d;35,37d" dgemmR/src/Makevars 
    sed -i -e 's/ \$(cu_objects)//g' dgemmR/src/Makevars
    sed -i -e 's/-L\$(CUDA_HOME)\/lib64 -Wl,-rpath,\$(CUDA_HOME)\/lib64 -lcudart -lcublas//g' dgemmR/src/Makevars
    sed -i -e '23,26d;39,42d' dgemmR/tests/testthat/test_dgemm_equality.R
    sed -i -e '44,51d' dgemmR/R/dgemm.R
    sed -i -e 's/<- 14/<- 10/g' dgemmR/R/dgemm.R
    sed -i -e 's/<- 15/<- 11/g' dgemmR/R/dgemm.R
    sed -i -e 's/< 14/< 10/g' dgemmR/R/dgemm.R
    sed -i -e 's/== 14/== 10/g' dgemmR/R/dgemm.R
    sed -i -e '1,20d;46,49d;62,65d;81,84d' example.R

    #sed -i -e '4,12d' .travis.yml
    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h

    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    echo " devtools::test()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_6_R_C++Threads
git checkout main


git branch -D      step_7_R_Cuda
git push origin -d step_7_R_Cuda
git checkout -b    step_7_R_Cuda

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm .github/workflows/Python_package.yml

    ## clean up file content
    sed -i -e '1,20d' example.R

    #sed -i -e '4,12d' .travis.yml
    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h

    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    echo " devtools::test()" | R --no-save --no-restore
    cd ..

## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_7_R_Cuda
git checkout main



## delete local and remote branch and create a new clean branch
git branch -D      step_1_Python_basic_package
git push origin -d step_1_Python_basic_package
git checkout -b    step_1_Python_basic_package

    ## clean up files
    rm -rf example.R dgemmR cpp .vscode create*
    rm .github/workflows/R_package.yml
    rm -rf dgemmPy/dgemmPy/src

    ## clean up file content
    sed -i -e '20,33d' dgemmPy/tests/test_dgemm_equality.py
    sed -i -e '7d;16d;29d;34,68d;74,76d' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/verbose: bool = False,/verbose: bool = False):/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 14/algo == "py_loops"/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 15/algo == "py_blas"/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e '1,3d;8,63d;84,85d' dgemmPy/setup.py
    sed -i -e 's/, Extension//g' dgemmPy/setup.py
    sed -i -e '24s/],/]/g' dgemmPy/setup.py
    sed -i -e '1,20d;38,51d;54,68d;81,136d' example.py
    sed -i -e '31s/ +/)/g' example.py

    # sed -i -e '13,24d' .travis.yml
    pip3 install ./dgemmPy
    python3 -m pytest


## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_1_Python_basic_package
git checkout main


git branch -D      step_2_Python_incorporating_C++
git push origin -d step_2_Python_incorporating_C++
git checkout -b    step_2_Python_incorporating_C++


    ## copy cpp/cu files
    cp dgemmR/src/dgemm.cpp dgemmPy/dgemmPy/src/
    cp dgemmR/src/dgemm.h   dgemmPy/dgemmPy/src/

    ## clean up files
    rm -rf example.R dgemmR cpp .vscode create*
    rm .github/workflows/R_package.yml

    ## clean up file content
    sed -i -e '28,177d' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e '4,5d;7,9d;28,46d;49,76d;86,163d' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e '20,21d;23,33d' dgemmPy/tests/test_dgemm_equality.py
    sed -i -e '16d;29d;34,68d;76d' dgemmPy/dgemmPy/python/dgemm.py
    
    sed -i -e 's/verbose: bool = False,/verbose: bool = False):/g' dgemmPy/dgemmPy/python/dgemm.py    
    sed -i -e 's/algo_int == 14/algo == "py_loops"/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 15/algo == "py_blas"/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/else:/elif algo == "loops":/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e '38s/repeats,/repeats, verbose)/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e '1d;3d;8,42d;47,50d;53,55d;58,63d;85d' dgemmPy/setup.py
    sed -i -e 's/..\/dgemmR\/src/dgemmPy\/src/g' dgemmPy/setup.py
    sed -i -e '9s/,/],/g' dgemmPy/setup.py
    sed -i -e '11s/,/],/g' dgemmPy/setup.py
    sed -i -e '13s/{'\''cxx'\'': //g' dgemmPy/setup.py
    sed -i -e '13s/'\''-O3'\'',/'\''-O3'\''])/g' dgemmPy/setup.py
    sed -i -e '34s/],/]/g' dgemmPy/setup.py
    sed -i -e '13d;15d' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/iiii/ii/g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/&algo, //g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/, &threads//g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/algo, threads, //g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/dgemm::dgemm_C/dgemm::dgemm_C_loops/g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e '1,20d;39,51d;55,68d;85,136d' example.py
    sed -i -e '37s/ +/)/g' example.py

    # sed -i -e '13,24d' .travis.yml
    pip3 install ./dgemmPy
    python3 -m pytest

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h

## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_2_Python_incorporating_C++
git checkout main




git branch -D      step_3_Python_BLAS_C++
git push origin -d step_3_Python_BLAS_C++
git checkout -b    step_3_Python_BLAS_C++


    ## copy cpp/cu files
    cp dgemmR/src/dgemm.cpp dgemmPy/dgemmPy/src/
    cp dgemmR/src/dgemm.h   dgemmPy/dgemmPy/src/

    ## clean up files
    rm -rf example.R dgemmR cpp create* #.vscode
    rm .github/workflows/R_package.yml

    ## clean up file content
    sed -i -e '28,40d;105,119d;103d;128,174d' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e '4,5d;7,9d;51,52d;55,64d;75d;96,163d' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e 's/loops = 2/loops = 0/g' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e 's/blas = 3,/blas = 1/g' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e '20,21d;24,33d' dgemmPy/tests/test_dgemm_equality.py
    sed -i -e '16d;29d;35,38d;43,62d;76d' dgemmPy/dgemmPy/python/dgemm.py    
    sed -i -e 's/verbose: bool = False,/verbose: bool = False):/g' dgemmPy/dgemmPy/python/dgemm.py  
    sed -i -e 's/elif algo == "loops"/if algo == "loops"/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e '49s/repeats,/repeats, algo_int, verbose)/g' dgemmPy/dgemmPy/python/dgemm.py

    sed -i -e 's/algo_int = 2/algo_int = 0/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 3/algo_int = 1/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 14/algo_int = 2/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 15/algo_int = 3/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 14/algo_int == 2/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 15/algo_int == 3/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e '1d;3d;8,42d;47,50d;53,55d;58,62d;85d' dgemmPy/setup.py
    sed -i -e 's/..\/dgemmR\/src/dgemmPy\/src/g' dgemmPy/setup.py
    sed -i -e '9s/,/],/g' dgemmPy/setup.py
    sed -i -e '11s/,/],/g' dgemmPy/setup.py    
    sed -i -e '13s/{'\''cxx'\'': //g' dgemmPy/setup.py
    sed -i -e '13s/'\''-O3'\'',/'\''-O3'\''],/g' dgemmPy/setup.py
    sed -i -e 's/, '\''-fopenmp'\'', '\''-lcublas'\'', '\''-lcudart'\''//g' dgemmPy/setup.py
    sed -i -e '35s/],/]/g' dgemmPy/setup.py
    sed -i -e '15d' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/iiii/iii/g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/, &threads//g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/threads, //g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e '1,20d;40,51d;56,68d;89,136d' example.py
    sed -i -e '43s/ +/)/g' example.py


    # sed -i -e '13,24d' .travis.yml
    pip3 install ./dgemmPy
    python3 -m pytest

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h
 

## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_3_Python_BLAS_C++
git checkout main








git branch -D      step_4_Python_AVX
git push origin -d step_4_Python_AVX
git checkout -b    step_4_Python_AVX


    ## copy cpp/cu files
    cp dgemmR/src/dgemm*.cpp dgemmPy/dgemmPy/src/
    cp dgemmR/src/dgemm.h   dgemmPy/dgemmPy/src/

    ## clean up files
    rm -rf example.R dgemmR cpp create* .vscode
    rm .github/workflows/R_package.yml

    ## clean up file content
    sed -i -e '103d;115,117d;132,139d;144,171d' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e 's/threads, //g' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e 's/, 0);/);/g' dgemmPy/dgemmPy/src/dgemm.cpp    
    sed -i -e '5d;9d;56,57d;59,64d;75d;112d;114d;123d;125d;126,163d' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e 's/avx512 = 7,/avx512 = 5/g' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e 's/int verbose,/int verbose);/g' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e '10d;12d;63d;84,142d' dgemmPy/dgemmPy/src/dgemm_avx2.cpp
    sed -i -e 's/int verbose,/int verbose) {/g' dgemmPy/dgemmPy/src/dgemm_avx2.cpp
    sed -i -e '10d;12d;63d;86,146d' dgemmPy/dgemmPy/src/dgemm_avx512.cpp
    sed -i -e 's/int verbose,/int verbose) {/g' dgemmPy/dgemmPy/src/dgemm_avx512.cpp
    sed -i -e '25,26d;28,33d' dgemmPy/tests/test_dgemm_equality.py
    sed -i -e '16d;29d;45,48d;51,62d;76d' dgemmPy/dgemmPy/python/dgemm.py    
    sed -i -e 's/verbose: bool = False,/verbose: bool = False):/g' dgemmPy/dgemmPy/python/dgemm.py 
    sed -i -e '57s/repeats,/repeats, algo_int, verbose)/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 7/algo_int = 5/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 14/algo_int = 6/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 15/algo_int = 7/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 14/algo_int == 6/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 15/algo_int == 7/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e '8,11d;22,27d;49d;53,55d;58,62d' dgemmPy/setup.py
    sed -i -e 's/..\/dgemmR\/src/dgemmPy\/src/g' dgemmPy/setup.py   
    sed -i -e '38s/,//g' dgemmPy/setup.py
    sed -i -e '43s/{'\''cxx'\'': //g' dgemmPy/setup.py
    sed -i -e '43s/'\''-O3'\'',/'\''-O3'\''],/g' dgemmPy/setup.py
    sed -i -e '41s/,/],/g' dgemmPy/setup.py
    sed -i -e 's/, '\''-fopenmp'\'', '\''-lcublas'\'', '\''-lcudart'\''//g' dgemmPy/setup.py    
    sed -i -e '15d' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/iiii/iii/g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/, &threads//g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e 's/threads, //g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e '1,20d;43,44d;46,51d;60,67d;101,108d;113,136d' example.py
    sed -i -e 's/c9/c7/g' example.py
    sed -i -e '68s/ +/)/g' example.py


    # sed -i -e '13,24d' .travis.yml
    pip3 install ./dgemmPy
    python3 -m pytest

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h



## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_4_Python_AVX
git checkout main




git branch -D      step_5_Python_OpenMP
git push origin -d step_5_Python_OpenMP
git checkout -b    step_5_Python_OpenMP

    
    ## copy cpp/cu files
    cp dgemmR/src/dgemm*.cpp dgemmPy/dgemmPy/src/
    cp dgemmR/src/dgemm.h   dgemmPy/dgemmPy/src/

    ## clean up files
    rm -rf example.R dgemmR cpp create* .vscode
    rm .github/workflows/R_package.yml

    ## clean up file content
    sed -i -e '115,117d;136,139d;148,171d' dgemmPy/dgemmPy/src/dgemm.cpp  
    sed -i -e '9d;57d;60,64d;126,163d' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e 's/avx512 = 7,/avx512 = 6,/g' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e 's/avx512_omp = 8,/avx512_omp = 7/g' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e '113,141d' dgemmPy/dgemmPy/src/dgemm_avx2.cpp
    sed -i -e '116,145d' dgemmPy/dgemmPy/src/dgemm_avx512.cpp
    sed -i -e '26d;29,33d' dgemmPy/tests/test_dgemm_equality.py


    sed -i -e '47,48d;53,62d' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 7/algo_int = 6/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 8/algo_int = 7/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 14/algo_int = 8/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 15/algo_int = 9/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 14/algo_int == 8/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 15/algo_int == 9/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e '8,11d;22,27d;49d;53,55d;59,62d' dgemmPy/setup.py
    sed -i -e 's/..\/dgemmR\/src/dgemmPy\/src/g' dgemmPy/setup.py   
    sed -i -e '38s/,//g' dgemmPy/setup.py
    sed -i -e '43s/{'\''cxx'\'': //g' dgemmPy/setup.py
    sed -i -e '41s/,/],/g' dgemmPy/setup.py
    sed -i -e 's/, '\''-lcublas'\'', '\''-lcudart'\''//g' dgemmPy/setup.py



    sed -i -e '1,20d;44d;47,51d;62,67d;105,108d;117,136d' example.py
    sed -i -e '24s/c9/c8/g' example.py
    sed -i -e '25s/c10/c9/g' example.py
    sed -i -e '68s/ +/)/g' example.py


    # sed -i -e '13,24d' .travis.yml
    pip3 install ./dgemmPy
    python3 -m pytest

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h


## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_5_Python_OpenMP
git checkout main







git branch -D      step_6_Python_C++Threads
git push origin -d step_6_Python_C++Threads
git checkout -b    step_6_Python_C++Threads

    ## copy cpp/cu files
    cp dgemmR/src/dgemm*.cpp dgemmPy/dgemmPy/src/
    cp dgemmR/src/*.h   dgemmPy/dgemmPy/src/

    ## clean up files
    rm -rf example.R dgemmR cpp create* #.vscode
    rm .github/workflows/R_package.yml

    ## clean up file content
    sed -i -e '115,117d;152,171d' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e '61,64d;126,163d' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e '30,33d' dgemmPy/tests/test_dgemm_equality.py
    sed -i -e '55,62d' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 14/algo_int = 10/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int = 15/algo_int = 11/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 14/algo_int == 10/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e 's/algo_int == 15/algo_int == 11/g' dgemmPy/dgemmPy/python/dgemm.py
    sed -i -e '8,11d;22,27d;49d;53,55d;59,62d' dgemmPy/setup.py
    sed -i -e 's/..\/dgemmR\/src/dgemmPy\/src/g' dgemmPy/setup.py   
    sed -i -e '38s/,//g' dgemmPy/setup.py
    sed -i -e '43s/{'\''cxx'\'': //g' dgemmPy/setup.py
    sed -i -e '41s/,/],/g' dgemmPy/setup.py
    sed -i -e 's/, '\''-lcublas'\'', '\''-lcudart'\''//g' dgemmPy/setup.py
    sed -i -e '1,20d;48d;48,51d;64,67d;121,136d' example.py
    sed -i -e '91s/ +/)/g' example.py


    # sed -i -e '13,24d' .travis.yml
    pip3 install ./dgemmPy
    python3 -m pytest

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h

## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_6_Python_C++Threads
git checkout main






git branch -D      step_7_Python_Cuda
git push origin -d step_7_Python_Cuda
git checkout -b    step_7_Python_Cuda

    ## copy cpp/cu files
    cp dgemmR/src/dgemm*.cpp dgemmPy/dgemmPy/src/
    cp dgemmR/src/*.cu  dgemmPy/dgemmPy/src/
    cp dgemmR/src/*.h   dgemmPy/dgemmPy/src/

    ## clean up files
    rm -rf example.R dgemmR cpp create* .vscode
    rm .github/workflows/R_package.yml
    sed -i -e 's/..\/dgemmR\/src/dgemmPy\/src/g' dgemmPy/setup.py   

    # sed -i -e '13,24d' .travis.yml
    pip3 install ./dgemmPy
    python3 -m pytest

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h
    clang-format -i dgemmPy/dgemmPy/src/*.cu

## git commit & push all changes and go back to main
git add .
git commit -m "automated commit"
git push origin step_7_Python_Cuda
git checkout main
