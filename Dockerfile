FROM ruby:2.3.1-alpine
RUN apk add --no-cache build-base autoconf pkgconfig nodejs tzdata
RUN mkdir -p /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
