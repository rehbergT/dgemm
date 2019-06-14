#!/usr/bin/env bash
# this script creates all branches used for the tutorial out of the master branch

## delete local and remote branch and create a new clean branch
git branch -D   step_1_R_basic_package
git push origin :step_1_R_basic_package
git checkout -b step_1_R_basic_package

    ## clean up files
    rm -rf example.py dgemmPy .vscode create*
    rm -rf dgemmR/src dgemmR/R/*C* cpp
    rm -rf dgemmR/tests/testthat/test_checkForEquality2.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality3.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality4.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality5.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality6.R

    ## clean up file content
    sed -i -e "16d" dgemmR/DESCRIPTION
    sed -i -e '1,20d;36,44d;47,55d;61,69d' example.R
    sed -i -e '4,12d' .travis.yml

    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_1_R_basic_package
git checkout master


git branch -D   step_2_R_incorporating_C++
git push origin :step_2_R_incorporating_C++
git checkout -b step_2_R_incorporating_C++

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm -rf dgemmR/R/dgemm_C_blas.R cpp
    rm -rf dgemmR/R/dgemm_C_loops_avx_omp.R
    rm -rf dgemmR/R/dgemm_C_loops_avx_tp.R
    rm -rf dgemmR/R/dgemm_C_loops_avx.R
    rm -rf dgemmR/src/dgemm_avx2.cpp
    rm -rf dgemmR/src/dgemm_avx512.cpp
    rm -rf dgemmR/src/Parallel.h
    rm -rf dgemmR/tests/testthat/test_checkForEquality3.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality4.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality5.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality6.R

    ## clean up file content
    sed -i -e '41,134d;139,142d' dgemmR/src/wrapper.cpp
    sed -i -e '26,164d' dgemmR/src/dgemm.cpp
    sed -i -e '4d;6d;18,47d;50,52d;61,124d' dgemmR/src/dgemm.h
    sed -i -e "2,30d" dgemmR/src/Makevars
    echo "PKG_CXXFLAGS = -DCOLUMN_MAJOR" >> dgemmR/src/Makevars
    sed -i -e '1,20d;37,44d;48,55d;62,69d' example.R
    sed -i -e '4,12d' .travis.yml

    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_2_R_incorporating_C++
git checkout master


git branch -D   step_3_R_BLAS_C++
git push origin :step_3_R_BLAS_C++
git checkout -b step_3_R_BLAS_C++

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm -rf dgemmR/R/dgemm_C_loops_avx_omp.R
    rm -rf dgemmR/R/dgemm_C_loops_avx_tp.R
    rm -rf dgemmR/R/dgemm_C_loops_avx.R
    rm -rf dgemmR/src/dgemm_avx2.cpp
    rm -rf dgemmR/src/dgemm_avx512.cpp
    rm -rf dgemmR/src/Parallel.h
    rm -rf dgemmR/tests/testthat/test_checkForEquality4.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality5.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality6.R

    ## clean up file content
    sed -i -e '64,134d;140,142d' dgemmR/src/wrapper.cpp
    sed -i -e '76,164d' dgemmR/src/dgemm.cpp
    sed -i -e '4d;6d;18,28d;50,52d;69,124d' dgemmR/src/dgemm.h
    sed -i -e "5,30d" dgemmR/src/Makevars
    sed -i -e 's/\$(SHLIB_OPENMP_CXXFLAGS) //g' dgemmR/src/Makevars
    sed -i -e '1,20d;38,44d;49,55d;63,69d' example.R
    sed -i -e '4,12d' .travis.yml

    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h
    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_3_R_BLAS_C++
git checkout master


git branch -D   step_4_R_AVX
git push origin :step_4_R_AVX
git checkout -b step_4_R_AVX

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm -rf dgemmR/R/dgemm_C_loops_avx_omp.R
    rm -rf dgemmR/R/dgemm_C_loops_avx_tp.R
    rm -rf dgemmR/src/Parallel.h
    rm -rf dgemmR/tests/testthat/test_checkForEquality5.R
    rm -rf dgemmR/tests/testthat/test_checkForEquality6.R

    ## clean up file content
    sed -i -e '81s/repeats,/repeats);/g' dgemmR/src/wrapper.cpp
    sed -i -e '82d;88,134d;141,142d' dgemmR/src/wrapper.cpp
    sed -i -e '82s/int repeats,/int repeats) {/g' dgemmR/src/dgemm.cpp
    sed -i -e '83d;136d;139,145d;147d;150,156d' dgemmR/src/dgemm.cpp
    sed -i -e '75s/int repeats,/int repeats);/g' dgemmR/src/dgemm.h
    sed -i -e '22,28d;51,52d;76d;93,124d' dgemmR/src/dgemm.h
    sed -i -e '33,103d' dgemmR/src/dgemm_avx2.cpp
    sed -i -e '34,106d' dgemmR/src/dgemm_avx512.cpp
    sed -i -e 's/\$(SHLIB_OPENMP_CXXFLAGS) //g' dgemmR/src/Makevars
    sed -i -e '1,20d;39,44d;50,55d;64,69d' example.R
    sed -i -e '4,12d' .travis.yml

    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h
    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_4_R_AVX
git checkout master


git branch -D   step_5_R_OpenMP
git push origin :step_5_R_OpenMP
git checkout -b step_5_R_OpenMP

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp
    rm -rf dgemmR/R/dgemm_C_loops_avx_tp.R
    rm -rf dgemmR/src/Parallel.h
    rm -rf dgemmR/tests/testthat/test_checkForEquality6.R

    ## clean up file content   
    sed -i -e '112,134d;142d' dgemmR/src/wrapper.cpp
    sed -i -e '142,144d;153,155d' dgemmR/src/dgemm.cpp
    sed -i -e '51s/, stdThreads//g' dgemmR/src/dgemm.h
    sed -i -e '22,23d;27d;109,124d' dgemmR/src/dgemm.h
    sed -i -e '70,103d' dgemmR/src/dgemm_avx2.cpp
    sed -i -e '73,106d' dgemmR/src/dgemm_avx512.cpp
    sed -i -e '1,20d;40,44d;51,55d;65,69d' example.R
    sed -i -e '4,12d' .travis.yml

    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h
    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_5_R_OpenMP
git checkout master


git branch -D   step_6_R_C++Threads
git push origin :step_6_R_C++Threads
git checkout -b step_6_R_C++Threads

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp

    ## clean up file content
    sed -i -e '1,20d;41,44d;52,55d;66,69d' example.R
    sed -i -e '4,12d' .travis.yml

    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h
    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    cd ..


## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_6_R_C++Threads
git checkout master

git branch -D   step_7_R_Cuda
git push origin :step_7_R_Cuda
git checkout -b step_7_R_Cuda

    bash createCudaRPackage.sh

    ## clean up
    rm -rf example.py dgemmPy .vscode create* cpp .travis.yml
    
    clang-format -i dgemmR/src/*.cpp
    clang-format -i dgemmR/src/*.h
    clang-format -i dgemmR/src/*.cu
    ## create man files
    cd dgemmR
    echo "pkgbuild::compile_dll(); devtools::document()" | R --no-save --no-restore
    cd ..

## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_7_R_Cuda
git checkout master


## delete local and remote branch and create a new clean branch
git branch -D   step_1_Python_basic_package
git push origin :step_1_Python_basic_package
git checkout -b step_1_Python_basic_package

    ## clean up files
    rm -rf example.R dgemmR cpp .vscode create*
    rm -rf dgemmPy/dgemmPy/src
    rm -rf dgemmPy/tests/test_checkForEquality2.py
    rm -rf dgemmPy/tests/test_checkForEquality3.py
    rm -rf dgemmPy/tests/test_checkForEquality4.py
    rm -rf dgemmPy/tests/test_checkForEquality5.py
    rm -rf dgemmPy/tests/test_checkForEquality6.py

    ## clean up file content
    sed -i -e '8s/\"dgemm_py_loops\",/\"dgemm_py_loops\"]/g' dgemmPy/dgemmPy/__init__.py
    sed -i -e '3,6d;9,11d' dgemmPy/dgemmPy/__init__.py

    sed -i -e 's/, Extension//g' dgemmPy/setup.py
    sed -i -e '61s/],/]/g' dgemmPy/setup.py
    sed -i -e '1,3d;8,41d;62,63d' dgemmPy/setup.py

    sed -i -e '1,20d;38,46d;49,57d;70,106d' example.py
    sed -i -e '13,24d' .travis.yml


## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_1_Python_basic_package
git checkout master


git branch -D   step_2_Python_incorporating_C++
git push origin :step_2_Python_incorporating_C++
git checkout -b step_2_Python_incorporating_C++

    ## clean up
    rm -rf example.R dgemmR cpp .vscode create* 
    rm -rf dgemmPy/dgemmPy/src/dgemm_avx2.cpp
    rm -rf dgemmPy/dgemmPy/src/dgemm_avx512.cpp
    rm -rf dgemmPy/dgemmPy/src/Parallel.h
    rm -rf dgemmPy/tests/test_checkForEquality3.py
    rm -rf dgemmPy/tests/test_checkForEquality4.py
    rm -rf dgemmPy/tests/test_checkForEquality5.py
    rm -rf dgemmPy/tests/test_checkForEquality6.py

    ## clean up file content
    sed -i -e '56,183d;188,198d' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e '26,164d' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e '4d;6d;18,47d;50,52d;61,124d' dgemmPy/dgemmPy/src/dgemm.h

    sed -i -e '3s/import (/import dgemm_C_loops/g' dgemmPy/dgemmPy/__init__.py
    sed -i -e '8s/\"dgemm_py_loops\",/\"dgemm_py_loops\", \"dgemm_C_loops\"]/g' dgemmPy/dgemmPy/__init__.py
    sed -i -e '4,6d;9,11d' dgemmPy/dgemmPy/__init__.py

    sed -i -e '34s/,/],/g' dgemmPy/setup.py
    sed -i -e '39s/\"-O3\",/\"-O3\"])/g' dgemmPy/setup.py
    sed -i -e '62s/],/]/g' dgemmPy/setup.py
    sed -i -e '1d;3d;8,30d;35,36d;40,41d;63d' dgemmPy/setup.py

    sed -i -e '1,20d;39,46d;50,57d;74,106d' example.py
    sed -i -e '13,24d' .travis.yml

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h

## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_2_Python_incorporating_C++
git checkout master


git branch -D   step_3_Python_BLAS_C++
git push origin :step_3_Python_BLAS_C++
git checkout -b step_3_Python_BLAS_C++

    ## clean up
    rm -rf example.R dgemmR cpp .vscode create* 
    rm -rf dgemmPy/dgemmPy/src/dgemm_avx2.cpp
    rm -rf dgemmPy/dgemmPy/src/dgemm_avx512.cpp
    rm -rf dgemmPy/dgemmPy/src/Parallel.h
    rm -rf dgemmPy/tests/test_checkForEquality4.py
    rm -rf dgemmPy/tests/test_checkForEquality5.py
    rm -rf dgemmPy/tests/test_checkForEquality6.py

    ## clean up file content
    sed -i -e '88,183d;190,198d' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e '76,164d' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e '4d;6d;18,28d;50,52d;69,124d' dgemmPy/dgemmPy/src/dgemm.h

    sed -i -e '4s/, dgemm_C_loops_avx,//g' dgemmPy/dgemmPy/__init__.py
    sed -i -e '9s/, \"dgemm_C_loops_avx\",/]/g' dgemmPy/dgemmPy/__init__.py
    sed -i -e '5d;10d' dgemmPy/dgemmPy/__init__.py

    sed -i -e '34s/,/],/g' dgemmPy/setup.py
    sed -i -e '39s/\"-O3\",/\"-O3\"],/g' dgemmPy/setup.py
    sed -i -e '41s/...-lgomp.//g' dgemmPy/setup.py
    sed -i -e '62s/],/]/g' dgemmPy/setup.py
    sed -i -e '1d;3d;8,30d;35,36d;40d;63d' dgemmPy/setup.py

    sed -i -e '1,20d;40,46d;51,57d;78,106d' example.py
    sed -i -e '13,24d' .travis.yml

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h

## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_3_Python_BLAS_C++
git checkout master


git branch -D   step_4_Python_AVX
git push origin :step_4_Python_AVX
git checkout -b step_4_Python_AVX

    ## clean up
    rm -rf example.R dgemmR cpp .vscode create* 
    rm -rf dgemmPy/dgemmPy/src/Parallel.h
    rm -rf dgemmPy/tests/test_checkForEquality5.py
    rm -rf dgemmPy/tests/test_checkForEquality6.py

    ## clean up file content
    sed -i -e '113s/repeats,/repeats);/g' dgemmPy/dgemmPy/src/wrapper.cpp
    sed -i -e '114d;119,183d;193,198d' dgemmPy/dgemmPy/src/wrapper.cpp

    sed -i -e '82s/int repeats,/int repeats) {/g' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e '83d;136d;139,145d;147d;150,156d' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e '75s/int repeats,/int repeats);/g' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e '22,28d;51,52d;76d;93,124d' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e '33,103d' dgemmPy/dgemmPy/src/dgemm_avx2.cpp
    sed -i -e '34,106d' dgemmPy/dgemmPy/src/dgemm_avx512.cpp

    sed -i -e '4s/avx,/avx/g' dgemmPy/dgemmPy/__init__.py
    sed -i -e '9s/avx\",/avx\"]/g' dgemmPy/dgemmPy/__init__.py
    sed -i -e '5d;10d' dgemmPy/dgemmPy/__init__.py

   
    sed -i -e '39s/\"-O3\",/\"-O3\"],/g' dgemmPy/setup.py
    sed -i -e '41s/...-lgomp.//g' dgemmPy/setup.py    
    sed -i -e '40d' dgemmPy/setup.py

    sed -i -e '1,20d;41,46d;52,57d;82,106d' example.py
    sed -i -e '13,24d' .travis.yml

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h


## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_4_Python_AVX
git checkout master


git branch -D   step_5_Python_OpenMP
git push origin :step_5_Python_OpenMP
git checkout -b step_5_Python_OpenMP

    ## clean up
    rm -rf example.R dgemmR cpp .vscode create* 
    rm -rf dgemmPy/dgemmPy/src/Parallel.h
    rm -rf dgemmPy/tests/test_checkForEquality6.py

    ## clean up file content
    sed -i -e '152,183d;196,198d' dgemmPy/dgemmPy/src/wrapper.cpp

    sed -i -e '142,144d;153,155d' dgemmPy/dgemmPy/src/dgemm.cpp
    sed -i -e '51s/, stdThreads//g' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e '22,23d;27d;109,124d' dgemmPy/dgemmPy/src/dgemm.h
    sed -i -e '70,103d' dgemmPy/dgemmPy/src/dgemm_avx2.cpp
    sed -i -e '73,106d' dgemmPy/dgemmPy/src/dgemm_avx512.cpp

    sed -i -e '5s/, dgemm_C_loops_avx_tp//g' dgemmPy/dgemmPy/__init__.py
    sed -i -e '10s/, \"dgemm_C_loops_avx_tp\"//g' dgemmPy/dgemmPy/__init__.py     
    
    sed -i -e '40s/...-std=c++11.//g' dgemmPy/setup.py  

    sed -i -e '1,20d;42,46d;53,57d;86,106d' example.py
    sed -i -e '13,24d' .travis.yml

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h


## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_5_Python_OpenMP
git checkout master


git branch -D   step_6_Python_C++Threads
git push origin :step_6_Python_C++Threads
git checkout -b step_6_Python_C++Threads

    ## clean up
    rm -rf example.R dgemmR cpp .vscode create* 

    ## clean up file content
    sed -i -e '1,20d;43,46d;54,57d;90,106d' example.py

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h
    sed -i -e '13,24d' .travis.yml

## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_6_Python_C++Threads
git checkout master


git branch -D   step_7_Python_Cuda
git push origin :step_7_Python_Cuda
git checkout -b step_7_Python_Cuda

    bash createCudaPythonPackage.sh

    ## clean up
    rm -rf example.R dgemmR cpp .vscode create* .travis.yml 

    clang-format -i dgemmPy/dgemmPy/src/*.cpp
    clang-format -i dgemmPy/dgemmPy/src/*.h
    clang-format -i dgemmPy/dgemmPy/src/*.cu

## git commit & push all changes and go back to master
git add .
git commit -m "automated commit"
git push origin step_7_Python_Cuda
git checkout master
