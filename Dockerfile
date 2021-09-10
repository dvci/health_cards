FROM ruby:2.7.3

ENV INSTALL_PATH=/opt/health_cards/
ENV RAILS_ENV=production
ENV NODE_ENV=production
RUN mkdir -p $INSTALL_PATH

# Add -k to disable ssl
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg -o /root/yarn-pubkey.gpg && apt-key add /root/yarn-pubkey.gpg
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends nodejs yarn

WORKDIR $INSTALL_PATH

ADD package.json $INSTALL_PATH
ADD yarn.lock $INSTALL_PATH

# Uncomment this line to disable ssl
# RUN yarn config set "strict-ssl" false

RUN yarn install

ADD Gemfile* $INSTALL_PATH
RUN gem install bundler
RUN bundle config set --local deployment 'true'
RUN bundle config set --local without 'development' 'test'
ADD . $INSTALL_PATH
RUN bundle install

ENV KEY_PATH=config/keys/key.pem
ENV SECRET_KEY_BASE=f7c9be19114730b947c8f7f274ea7c128e792245d049ae2c808d479f7e632817dd83009fa235326953a9ab11c70e9b0be4a8cb8657626e57ca5031a584b75295
ENV RAILS_SERVE_STATIC_FILES=true

RUN bin/rails db:create db:migrate db:seed
RUN bin/rails assets:precompile

EXPOSE 3000
ENTRYPOINT ["bin/rails","s"]