ARG RUBY_VERSION
ARG DISTRO_NAME=bullseye
FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME as dev
ARG DISTRO_NAME

RUN mkdir -p /app
WORKDIR /app

# Common dependencies
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    less \
    libcairo2-dev \
    libgirepository1.0-dev \
    libglib2.0-0 \
    libglib2.0-dev \
    libheif-dev \
    libjpeg62-turbo-dev \
    libpoppler-dev \
    libpoppler-glib-dev \
    libpoppler-glib8 \
    libvips \
    libvips-dev \
    poppler-utils \
    python2 \
    vim \
    wget

# Setup wkhtmltox
RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb && \
  apt install -yf ./wkhtmltox_0.12.6.1-2.bullseye_amd64.deb && \
  rm ./wkhtmltox_0.12.6.1-2.bullseye_amd64.deb
# Fix for wkhtmltopdf-heroku asking for libjpeg8.so.8
RUN ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so.62 /usr/lib/x86_64-linux-gnu/libjpeg.so.8

# Setup Postgres client
ARG PG_MAJOR
RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgres-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/postgres-archive-keyring.gpg] https://apt.postgresql.org/pub/repos/apt/" \
    $DISTRO_NAME-pgdg main $PG_MAJOR | tee /etc/apt/sources.list.d/postgres.list > /dev/null
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    libpq-dev \
    postgresql-client-$PG_MAJOR

# Setup Node
ARG NODE_MAJOR
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list > /dev/null
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    nodejs
RUN npm install --location=global npm@latest
ARG YARN_VERSION
RUN npm install -g yarn@$YARN_VERSION

# Cleanup apt
RUN apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3
# Store Bundler settings in the project's root
ENV BUNDLE_APP_CONFIG=.bundle
# Uncomment this line if you want to run binstubs without prefixing with `bin/` or `bundle exec`
# ENV PATH /app/bin:$PATH
# Upgrade RubyGems and install the latest Bundler version
RUN gem update --system && \
    gem install bundler

# Install Javascript and Ruby dependencies
COPY package.json yarn.lock
RUN yarn install
COPY Gemfile Gemfile.lock .
RUN bundle install

# Create a directory for the app code
COPY . .

RUN chmod ugo+rx bin/docker_web_entrypoint.sh

EXPOSE 3000
CMD ["/usr/bin/bash"]
