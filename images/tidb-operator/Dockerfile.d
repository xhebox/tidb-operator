FROM alpine:edge as builder

ADD https://raw.githubusercontent.com/njhallett/apk-fastest-mirror/c4ca44caef3385d830fea34df2dbc2ba4a17e021/apk-fastest-mirror.sh /
RUN sh /apk-fastest-mirror.sh -t 50 && apk add --no-cache --progress git make go
ARG BUILDFLAGS
ARG GOPROXY
ADD . /src
RUN export BUILDFLAGS=${BUILDFLAGS} && export GOPROXY=${GOPROXY} && export E2E=y && cd /src && go mod download
RUN export BUILDFLAGS=${BUILDFLAGS} && export GOPROXY=${GOPROXY} && export E2E=y && cd /src && make build

FROM alpine:latest

RUN apk add tzdata bind-tools --no-cache --progress

COPY --from=builder /src/images/tidb-operator/bin/tidb-scheduler /usr/local/bin/tidb-scheduler
COPY --from=builder /src/images/tidb-operator/bin/tidb-discovery /usr/local/bin/tidb-discovery
COPY --from=builder /src/images/tidb-operator/bin/tidb-controller-manager /usr/local/bin/tidb-controller-manager
COPY --from=builder /src/images/tidb-operator/bin/tidb-admission-webhook /usr/local/bin/tidb-admission-webhook
