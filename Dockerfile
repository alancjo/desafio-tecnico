FROM ruby:3.3.0

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /locaweb

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["ruby", "./input_interface/view/atm/home.rb"]
