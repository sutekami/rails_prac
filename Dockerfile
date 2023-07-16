FROM ruby:3.2.2

ENV LANG C.UTF-8
ENV RUBY_YJIT_ENABLE=1

WORKDIR /app
COPY Gemfile Gemfile.lock ./

RUN apt-get update -qq && \
    apt-get install -y build-essential \
    vim \
    nodejs \
    fonts-vlgothic \
    default-mysql-client

RUN bundle install --jobs=3
COPY . .
