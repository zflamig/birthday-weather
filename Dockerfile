FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y python3-pip python3-dev wget libsqlite3-dev sqlite3 libtiff-dev \
  && ln -s /usr/bin/python3 /usr/local/bin/python \
  && pip3 install --upgrade pip \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /tmp \
    && wget https://github.com/matplotlib/basemap/archive/v1.2.2rel.tar.gz \
    && tar -xvzf v1.2.2rel.tar.gz \
    && rm v1.2.2rel.tar.gz

RUN cd /tmp \
    && wget http://download.osgeo.org/geos/geos-3.8.1.tar.bz2 \
    && tar xf geos-3.8.1.tar.bz2 \
    && cd geos-3.8.1 \
    && ./configure --prefix=/usr \
    && make -j4 \
    && make install \
    && cd .. \
    && rm -rf geos-3.8.1 \
    && rm -rf geos-3.8.1.tar.bz2

RUN cd /tmp \
    && wget http://download.osgeo.org/proj/proj-7.2.0.tar.gz \
    && tar xf proj-7.2.0.tar.gz \
    && cd proj-7.2.0 \	
    && ./configure --prefix=/usr SQLITE3_CFLAGS=-I/usr/include SQLITE3_LIBS="-L/usr/lib -lsqlite3" --without-curl \
    && make -j4 \
    && make install \
    && cd .. \
    && rm -rf proj-7.2.0 proj-7.2.0.tar.gz


RUN pip install --upgrade jupyter Cython==0.29.21 scipy==1.5.4 matplotlib==3.3.0 pandas==1.1.4 boto3==1.14.44 dask==2.30.0 distributed==2.19.0 tornado==6.0.4 cloudpickle==1.4.1 msgpack==0.6.2 blosc==1.8.1 numpy==1.17.3 lz4==3.0.2 netcdf4==1.5.3 xarray==0.16.2 bokeh==2.1.1 s3fs==0.5.1 fsspec==0.8.4 h5netcdf==0.8.0 h5py==2.10.0 zarr==2.5.0

#RUN cd /tmp \
#    && wget https://github.com/matplotlib/basemap/archive/v1.1.0.tar.gz \
#    && tar -xvzf v1.1.0.tar.gz \
##    && rm v1.1.0.tar.gz \
#    && cd basemap-1.1.0 \
#    && python setup.py install

RUN cd /tmp/basemap-1.2.2rel \
    && rm lib/mpl_toolkits/__init__.py \
    && python setup.py install

RUN jupyter notebook --generate-config

RUN echo "" > ~/.jupyter/jupyter_notebook_config.py  \
  && echo "c.NotebookApp.ip = '0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py \ 
  && echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py \
  && echo "c.NotebookApp.allow_root = True" >> ~/.jupyter/jupyter_notebook_config.py \
  && echo "c.NotebookApp.port = 8888" >> ~/.jupyter/jupyter_notebook_config.py \
  && echo "c.NotebookApp.notebook_dir = '/notebooks'" >> ~/.jupyter/jupyter_notebook_config.py \
  && echo "c.NotebookApp.password = ''" >> ~/.jupyter/jupyter_notebook_config.py \
  && echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py

CMD jupyter notebook
