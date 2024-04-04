FROM ruby:3.3.0

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /locaweb

COPY Gemfile ./

RUN bundle install

COPY . .

EXPOSE 3000
