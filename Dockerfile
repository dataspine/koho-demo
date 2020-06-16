FROM docker.io/dataspine/predict-cpu:0.1.1prod

LABEL DATASPINE_IMAGE_REGISTRY_URL=docker.io
LABEL DATASPINE_IMAGE_REGISTRY_REPO=dataspine
LABEL DATASPINE_IMAGE_REGISTRY_NAMESPACE=predict
LABEL DATASPINE_IMAGE_REGISTRY_BASE_TAG=0.1.1prod
LABEL DATASPINE_MODEL_NAME=mnisttest
LABEL DATASPINE_MODEL_TYPE=xgboost
LABEL DATASPINE_MODEL_RUNTIME=python
LABEL DATASPINE_MODEL_CHIP=cpu

ENV \
  DATASPINE_MODEL_NAME=mnisttest

ENV \
  DATASPINE_MODEL_TYPE=xgboost

ENV \
  DATASPINE_MODEL_RUNTIME=python

ENV \
  DATASPINE_MODEL_CHIP=cpu

ENV \
  DATASPINE_MODEL_PATH=/root/ml/model
#  DATASPINE_MODEL_PATH=/opt/ml/model

ENV \
  DATASPINE_INPUT_PATH=/opt/ml/input

ENV \
  DATASPINE_OUTPUT_PATH=/opt/ml/output

RUN \
   echo "DATASPINE_MODEL_PATH=$DATASPINE_MODEL_PATH"

ENV \
  DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME=dataspine-predict
#-mnist-v1-xgboost-jvm-cpu

RUN \
  echo $DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME \ 
  && echo ""

# Note:  If you see the following error, you don't have HTTP_PROXY and HTTPS_PROXY env variables set properly:
#  CondaHTTPError: HTTP 000 CONNECTION FAILED for url <https://repo.continuum.io/pkgs/free/noarch/repodata.json.bz2>
RUN \
  conda create --name $DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME \
  && echo "source activate $DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME" >> ~/.bashrc 

# Note:  This runs *after* the environment is setup above.
COPY ./dataspine_setup.sh $DATASPINE_MODEL_PATH/dataspine_setup.sh

RUN \
  chmod a+x $DATASPINE_MODEL_PATH/dataspine_setup.sh \
  && mkdir -p /opt/conda/envs/$DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME/etc/conda/activate.d/ \
  && cd /opt/conda/envs/$DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME/etc/conda/activate.d/ \
  && ln -s $DATASPINE_MODEL_PATH/dataspine_setup.sh \
  && echo "" \
  && ls /opt/conda/envs/$DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME/etc/conda/activate.d/ \
  && echo "" \
  && cat /opt/conda/envs/$DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME/etc/conda/activate.d/dataspine_setup.sh \
  && echo "" \
  && echo "Installing init script 'dataspine_setup.sh' into conda environment '$DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME'..." \
  && echo "" \
  && echo "...Conda Environment Updated!" \
  && echo ""; 
  


COPY . $DATASPINE_MODEL_PATH

RUN \
  echo "set -o allexport; source $DATASPINE_MODEL_PATH/dataspine_modelserver.properties; set +o allexport" >> ~/.bashrc

# Moved these to the bottom to avoid re-doing everything above when DATASPINE_MODEL_TAG changes
LABEL DATASPINE_MODEL_TAG=v1xg
ENV \
  DATASPINE_MODEL_TAG=v1xg

RUN \
  source activate $DATASPINE_MODEL_PREDICT_CONDA_ENV_NAME \
  && conda list \
  && export
