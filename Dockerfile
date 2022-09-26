FROM ruby:2.6.5

ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy

# Install NodeJS
RUN curl https://deb.nodesource.com/setup_lts.x | bash && \
    apt install -y nodejs && \
    apt update && \
    npm install -g npm@8.19.2 && \
    npm install --global yarn && \
    apt install -y libicu-dev postgresql-client && \
    gem install bundler:2.2.17

COPY Gemfile* ./
RUN bundle install

ADD . /app
WORKDIR /app

RUN bundle exec rails assets:precompile

# Configure endpoint.
COPY ./entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
