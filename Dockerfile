ARG ES_VERSION
FROM docker.elastic.co/elasticsearch/elasticsearch:$ES_VERSION as builder

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN microdnf update -y && microdnf install -y cmake git wget tar gcc gcc-c++ make automake autoconf

ENV JAVA_HOME=/usr/share/elasticsearch/jdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Build coccoc-tokenizer
RUN echo "Build coccoc-tokenizer..."
WORKDIR /tmp
RUN git clone https://github.com/khangpropk123/coccoc-tokenizer.git
RUN mkdir /tmp/coccoc-tokenizer/build
WORKDIR /tmp/coccoc-tokenizer/build
RUN cmake -DBUILD_JAVA=1 ..
RUN make install

# Build analysis-vietnamese
RUN echo "analysis-vietnamese..wsssssssss.sdsaf"
WORKDIR /tmp
RUN wget https://dlcdn.apache.org/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz \
    && tar xvf apache-maven-3.8.8-bin.tar.gz
ENV MVN_HOME=/tmp/apache-maven-3.8.8
ENV PATH=$MVN_HOME/bin:$PATH

ARG ES_VERSION
WORKDIR /
RUN git clone https://github.com/khangpropk123/elasticsearch-analysis-vietnamese.git
WORKDIR /elasticsearch-analysis-vietnamese
RUN mvn verify clean --fail-never
RUN mvn --batch-mode -Dmaven.test.skip -e package -DprojectVersion=$ES_VERSION

# FROM docker.elastic.co/elasticsearch/elasticsearch:$ES_VERSION
# ARG ES_VERSION
# ARG COCCOC_INSTALL_PATH=/usr/local
# ARG COCCOC_DICT_PATH=$COCCOC_INSTALL_PATH/share/tokenizer/dicts

# COPY --from=builder $COCCOC_INSTALL_PATH/lib/libcoccoc_tokenizer_jni.so /usr/lib
# COPY --from=builder $COCCOC_DICT_PATH $COCCOC_DICT_PATH
# COPY --from=builder /elasticsearch-analysis-vietnamese/target/releases/elasticsearch-analysis-vietnamese-$ES_VERSION.zip /
# RUN echo "Y" | /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch file:///elasticsearch-analysis-vietnamese-$ES_VERSION.zip
