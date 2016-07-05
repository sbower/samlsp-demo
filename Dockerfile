FROM ruby

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile /app
RUN bundle install --quiet

COPY . /app
EXPOSE 5000

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "5000"]
