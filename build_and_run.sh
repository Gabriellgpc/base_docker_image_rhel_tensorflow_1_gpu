#/bin/bash

docker build . -t condados/tensorflow:tensorflow-gpu-1.14-ubi8

docker run -it --rm --gpus all condados/tensorflow:tensorflow-gpu-1.14-ubi8 /bin/bash

#tf.test.gpu_device_name()