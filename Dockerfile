FROM node:16-alpine as builder

RUN apk add --no-cache git python3 build-base

EXPOSE 3000

WORKDIR /src/

# This is super-ugly, but it means we don't have to re-run npm install every time any of the source
# files change- only when any dependencies change- which is a superior developer experience when
# relying on docker-compose.
COPY ./src/package.json ./package.json
COPY ./src/package-lock.json ./package-lock.json
COPY ./src/lib/cache/package.json ./lib/cache/package.json
COPY ./src/lib/check/package.json ./lib/check/package.json
COPY ./src/lib/model/lib/requests/package.json ./lib/model/lib/requests/package.json
COPY ./src/lib/model/lib/shared/package.json ./lib/model/lib/shared/package.json
COPY ./src/lib/model/package.json ./lib/model/package.json
COPY ./src/lib/randomphrase/package.json ./lib/randomphrase/package.json
COPY ./src/lib/router/package.json ./lib/router/package.json
COPY ./src/lib/validate/package.json ./lib/validate/package.json
COPY ./src/lib/metrics/package.json ./lib/metrics/package.json
RUN npm ci --only=production

FROM node:16-alpine

ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF
ARG VERSION

# See http://label-schema.org/rc1/ for label schema info
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="mojaloop-connector"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-url=$VCS_URL
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.url="https://modusbox.com"
LABEL org.label-schema.version=$VERSION

COPY --from=builder /src/ /src
COPY ./src ./src
COPY ./secrets /

CMD ["node", "src/index.js"]
