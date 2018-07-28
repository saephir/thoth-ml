FROM ubuntu:18.04

RUN apt update && apt install -y git wget unzip make gcc-4.8 g++-4.8 libjpeg-dev libpng-dev python python-pip swig libatlas-base-dev libblas-dev 

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8;

RUN pip install Pillow numpy matplotlib

RUN wget http://pascal.inrialpes.fr/data2/deepmatching/files/DeepFlow_release2.0.tar.gz && tar -xvf DeepFlow_release2.0.tar.gz

RUN wget http://lear.inrialpes.fr/src/deepmatching/code/deepmatching_1.2.2.zip && unzip deepmatching_1.2.2.zip

WORKDIR /deepmatching_1.2.2_c++
RUN perl -pi -e 's/LAPACKLDFLAGS=\/usr\/lib64\/atlas\/libsatlas.so   # single-threaded blas/LAPACKLDFLAGS=\/usr\/lib\/x86_64-linux-gnu\/atlas\/libblas.so \/usr\/lib\/x86_64-linux-gnu\/atlas\/liblapack.so/g' Makefile
RUN perl -pi -e 's/CPYTHONFLAGS=-I\/usr\/include\/python2.7/CPYTHONFLAGS=-I\/usr\/include\/python2.7 -I\/usr\/local\/lib\/python2.7\/dist-packages\/numpy\/core\/include/g' Makefile
RUN perl -pi -e 's/g\+\+ -shared \$\(LDFLAGS\) \$\(LAPACKLDFLAGS\) deepmatching_wrap.o \$\(OBJ\) -o _deepmatching.so \$\(LIBFLAGS\)/g++ -shared \$\(LAPACKLDFLAGS) deepmatching_wrap.o \$\(OBJ) -o _deepmatching.so \$\(LIBFLAGS) \$\(LDFLAGS)/gn' Makefile
RUN perl -pi -e 's/LDFLAGS=-fPIC -Wall -g -ljpeg -lpng -fopenmp/LDFLAGS=-fPIC -Wall -g -ljpeg -lpng -fopenmp -lblas/g' Makefile
RUN make clean && make && make python
RUN perl -pi -e 's/if None in \(im1,im2\):/if im1 is None or im2 is None:/g' deepmatching.py

WORKDIR /DeepFlow_release2.0
RUN perl -pi -e 's/CPYTHONFLAGS=-I\/usr\/include\/python2.7/CPYTHONFLAGS=-I\/usr\/include\/python2.7 -I\/usr\/local\/lib\/python2.7\/dist-packages\/numpy\/core\/include/g' Makefile
RUN make clean && make && make python
RUN perl -pi -e 's/if None in \(im1,im2\):/if im1 is None or im2 is None:/g' deepflow2.py

WORKDIR /
ENV PYTHONPATH=/deepmatching_1.2.2_c++:/DeepFlow_release2.0
