ARG ML=manylinux2014_x86_64

FROM quay.io/pypa/$ML

ARG PY=cp38-cp38
ARG CY=Cython

WORKDIR /root

RUN git clone --depth 1 https://github.com/epics-base/setuptools_dso \
 && git clone --depth 1 --recursive https://github.com/epics-base/epicscorelibs \
 && git clone --depth 1 --recursive https://github.com/epics-base/pvxs \
 && git clone --depth 1 https://github.com/epics-base/p4p

RUN ls /opt/python

ENV PATH=/opt/python/$PY/bin:$PATH

RUN pip install -U pip virtualenv \
 && pip download -d wheels \
    --only-binary numpy \
    --only-binary Cython \
    $CY setuptools wheel numpy ply nose2

ENV SETUPTOOLS_DSO_PLAT_NAME=$ML

RUN virtualenv env \
 && ./env/bin/pip install --no-index -f ./wheels setuptools \
 && ( cd setuptools_dso && ../env/bin/python setup.py sdist -d ../wheels ) \
 && rm -rf env

RUN pip wheel -w ./wheels --no-index -f ./wheels setuptools_dso

RUN virtualenv env \
 && ./env/bin/pip install --no-index -f ./wheels setuptools_dso \
 && ( cd epicscorelibs && ../env/bin/python setup.py sdist -d ../wheels ) \
 && rm -rf env

RUN pip wheel -w ./wheels --no-index -f ./wheels epicscorelibs

RUN virtualenv env \
 && ./env/bin/pip install --no-index -f ./wheels setuptools_dso epicscorelibs \
 && ( cd pvxs && ../env/bin/python setup.py sdist -d ../wheels ) \
 && rm -rf env

RUN pip wheel -w ./wheels --no-index -f ./wheels pvxslibs

RUN virtualenv env \
 && ./env/bin/pip install --no-index -f ./wheels setuptools_dso epicscorelibs pvxslibs \
 && ( cd p4p && ../env/bin/python setup.py sdist -d ../wheels ) \
 && rm -rf env

RUN pip wheel -w ./wheels --no-index -f ./wheels p4p

RUN pip install --no-index -f ./wheels p4p nose2

RUN python -m nose2 -v epicscorelibs pvxslibs p4p
