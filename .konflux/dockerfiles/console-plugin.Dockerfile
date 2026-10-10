ARG NJS_BUILDER=registry.redhat.io/ubi9/nodejs-22@sha256:99cef5d0a64011463c411db508b1570f9edc37219dd38eabbf90bb8c0e45ccc3
ARG NGX_RUNTIME=registry.access.redhat.com/ubi9/nginx-124@sha256:da54bbccb61ef4c1229b501276e6af35878455471598426346bb3014571843ed

FROM $NJS_BUILDER AS builder-ui

WORKDIR /go/src/github.com/openshift-pipelines/console-plugin
COPY upstream .
#Install Yarn
RUN if [[ -d /cachi2/output/deps/npm/ ]]; then \
      npm install -g /cachi2/output/deps/npm/yarnpkg-cli-dist-4.6.0.tgz; \
      YARN_ENABLE_NETWORK=0; \
    else \
      npm install -g corepack; \
      corepack enable ;\
      corepack prepare yarn@4.6.0 --activate;  \
    fi

# Install dependencies & build
USER root
RUN CYPRESS_INSTALL_BINARY=0 yarn install --immutable && \
    yarn build


FROM $NGX_RUNTIME

COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/dist /usr/share/nginx/html
COPY --from=builder-ui /go/src/github.com/openshift-pipelines/console-plugin/nginx.conf /etc/nginx/nginx.conf

USER 1001

ENTRYPOINT ["nginx", "-g", "daemon off;"]

LABEL \
    com.redhat.component="openshift-pipelines-console-plugin-pf5-rhel9-container" \
    cpe="cpe:/a:redhat:openshift_pipelines:1.22::el9" \
    description="Red Hat OpenShift Pipelines console-plugin-pf5 console-plugin" \
    io.k8s.description="Red Hat OpenShift Pipelines console-plugin-pf5 console-plugin" \
    io.k8s.display-name="Red Hat OpenShift Pipelines console-plugin-pf5 console-plugin" \
    io.openshift.tags="tekton,openshift,console-plugin-pf5,console-plugin" \
    maintainer="pipelines-extcomm@redhat.com" \
    name="openshift-pipelines/pipelines-console-plugin-pf5-rhel9" \
    summary="Red Hat OpenShift Pipelines console-plugin-pf5 console-plugin" \
    version="v1.22.7"
