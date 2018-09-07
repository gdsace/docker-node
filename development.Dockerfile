ARG ALPINE_VERSION="3.8"
FROM alpine:${ALPINE_VERSION}
LABEL maintainer="dev@joeir.net" \
      version="1.0.0" \
      description="A minimal Node + Yarn base image to work with."
ARG NODE_CODE="v9.x"
ARG NODE_BUILD_FLAGS=""
ENV INSTALL_PATH=/tmp
ENV APK_TO_INSTALL="bash curl gcc g++ make python linux-headers binutils-gold libstdc++ gnupg git xvfb" \
    NODE_LATEST_URL="https://nodejs.org/dist/latest-${NODE_CODE}" \
    PATHS_TO_REMOVE="\
      ${INSTALL_PATH}/* \
      /root/.gnupg/* \
      /root/.node-gyp/* \
      /root/.npm/* \
      /usr/include/* \
      /usr/lib/node_modules/npm/man/* \
      /usr/lib/node_modules/npm/doc/* \
      /usr/lib/node_modules/npm/html/* \
      /usr/lib/node_modules/npm/scripts/* \
      /usr/share/man/* \
      /var/cache/apk/*" \
    SYSTEM_BIN_PATH=/usr/local/bin/ \
    YARN_TAR_URL="https://yarnpkg.com/latest.tar.gz" \
    YARN_GPG_KEY_URL="https://dl.yarnpkg.com/debian/pubkey.gpg" \
    YARN_INSTALLED_PATH="/usr/local/share/yarn/"
WORKDIR /tmp
COPY ./version-info /usr/bin/
RUN apk add --update --upgrade --no-cache ${APK_TO_INSTALL} \
    && gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      FD3A5288F042B6850C66B31F09FE44734EB7990E \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
      56730D5401028683275BD23C23EFEFE93C4CFFFE \
    && curl -sS ${YARN_GPG_KEY_URL} | gpg --import \
    && curl "${NODE_LATEST_URL}/" | egrep "node-v[0-9]+\.[0-9]+\.[0-9]+\.tar.xz" | cut -d '>' -f 2 | cut -d '<' -f 1 > /tmp/node_filename \
    && printf "$(cat /tmp/node_filename)" | cut -d 'v' -f 2 | cut -d '.' -f 1,2,3       > /tmp/node_version \
    && printf "${INSTALL_PATH}/node-v$(cat /tmp/node_version)"                          > /tmp/node_install_dir \
    && printf "${INSTALL_PATH}/$(cat /tmp/node_filename)"                               > /tmp/node_install_path \
    && printf "${NODE_LATEST_URL}/$(cat /tmp/node_filename)"                            > /tmp/node_url \
    && printf "https://nodejs.org/dist/v$(cat /tmp/node_version)/SHASUMS256.txt.asc"    > /tmp/node_gpg_url \
    && printf "$(cat /tmp/node_install_path).asc"                                       > /tmp/node_install_gpg_path \
    && printf "$(curl -sSlf ${YARN_TAR_URL} | cut -f 2 -d 'v' | cut -f 1 -d '/')"       > /tmp/yarn_version \
    && printf "${INSTALL_PATH}/yarn-v$(cat /tmp/yarn_version)"                          > /tmp/yarn_install_dir \
    && printf "${INSTALL_PATH}/yarn-v$(cat /tmp/yarn_version).tar.gz"                   > /tmp/yarn_install_path \
    && printf "https://github.com/yarnpkg/yarn/releases/download/v$(cat /tmp/yarn_version)/yarn-v$(cat /tmp/yarn_version).tar.gz.asc" > /tmp/yarn_gpg_url \
    && printf "$(cat /tmp/yarn_install_path).asc"                                       > /tmp/yarn_install_gpg_path \
    && curl -sSL $(cat /tmp/node_url) -o $(cat /tmp/node_install_path) \
    && curl -sSL $(cat /tmp/node_gpg_url) -o $(cat /tmp/node_install_gpg_path) \
    && curl -sSL ${YARN_TAR_URL} -o $(cat /tmp/yarn_install_path) \
    && curl -sSL $(cat /tmp/yarn_gpg_url) -o $(cat /tmp/yarn_install_gpg_path) \
    && cat $(cat /tmp/node_install_gpg_path) | grep $(cat /tmp/node_filename) | sha256sum -c - \
    && tar -xf $(cat /tmp/node_install_path) -C ${INSTALL_PATH} \
    && gpg --verify $(cat /tmp/yarn_install_gpg_path) $(cat /tmp/yarn_install_path) \
    && tar -xf $(cat /tmp/yarn_install_path) -C ${INSTALL_PATH} \
    && mkdir -p ${YARN_INSTALLED_PATH} \
    && mv $(cat /tmp/yarn_install_dir)/* ${YARN_INSTALLED_PATH} \
    && ln -s ${YARN_INSTALLED_PATH}/bin/yarn ${SYSTEM_BIN_PATH} \
    && ln -s ${YARN_INSTALLED_PATH}/bin/yarnpkg ${SYSTEM_BIN_PATH} \
    && cd $(cat /tmp/node_install_dir) \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) > /dev/null \
    && make install \
    && chmod +x /usr/bin/version-info \
    && rm -rf ${PATHS_TO_REMOVE} \
    && mkdir /app
WORKDIR /app
USER root