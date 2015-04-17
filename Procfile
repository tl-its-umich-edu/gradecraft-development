web: bundle exec puma -p $PORT
redis: redis-server --port $REDIS_PORT
#bg: bundle exec sidekiq --config ./config/sidekiq.yml
bg: bundle exec rake resque:work
mongo: bundle exec mongod --dbpath=$MONGO_PATH --rest
