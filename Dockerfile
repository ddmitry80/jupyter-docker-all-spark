# Start from a core stack version
# manual https://jupyter-docker-stacks.readthedocs.io/en/latest/
# based on https://github.com/jupyter/docker-stacks/tree/master/pyspark-notebook
# based on https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile
ARG BASE_CONTAINER=jupyter/all-spark-notebook:spark-3.2.0
FROM $BASE_CONTAINER

LABEL maintainer="Dmitry Dementiev <ddmitry@gmail.com>"

USER root

# WORKDIR /usr/local/bin/start-notebook.d
COPY ssh-agent.sh /usr/local/bin/start-notebook.d/
RUN chmod +x /usr/local/bin/start-notebook.d/ssh-agent.sh

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-client mc ncdu htop tig maven language-pack-ru && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3 packages
RUN mamba install -c conda-forge --quiet --yes \
    jupyterlab-git \
    python-snappy \
    jupyterlab_widgets \
    mamba_gator \
    && \
    conda clean --all -f -y 

# Install Python 3 packages
# RUN conda install -c conda-forge --yes \
#     xeus-python \
#     && \
#     conda clean --all -f -y 

# Install Python 3 packages
RUN mamba install -c conda-forge --quiet --yes \
    catboost \
    xgboost \
    lightgbm \
    && \
    conda clean --all -f -y 

# Install Python 3 packages
RUN mamba install -c conda-forge --quiet --yes \
    psycopg2 \
    plotly \
    hyperopt \
    shap \
    graphviz \
    kaggle \
    # lxml \
    # html5lib \
    theme-darcula \
    && \
    mamba clean --all -f -y 

    # Activate ipywidgets extension in the environment that runs the notebook server
# RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
#     # Also activate ipywidgets extension for JupyterLab
#     # Check this URL for most recent compatibilities
#     # https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager
#     jupyter labextension install jupyterlab-theme-solarized-dark  --no-build && \
#     conda upgrade --all && \
#     jupyter lab build -y && \
#     jupyter lab clean -y && \
#     npm cache clean --force && \
#     rm -rf "/home/${NB_USER}/.cache/yarn" && \
#     rm -rf "/home/${NB_USER}/.node-gyp" && \
#     fix-permissions "${CONDA_DIR}" && \
#     fix-permissions "/home/${NB_USER}"


RUN echo "env_dirs:" >> $HOME/.conda/condarc && \
    echo "- $HOME/conda-envs" >> $HOME/.conda/condarc && \
    echo "- /opt/conda/envs" >> $HOME/.conda/condarc

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME="/home/${NB_USER}/.cache/"

# RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
#     fix-permissions "/home/${NB_USER}"

USER $NB_UID

WORKDIR $HOME

EXPOSE 8888 4040 4041
