REDIS = Redis.new(:host =>  ENV['REDIS_HOST_IP'], :port => ENV['REDIS_PORT'])
Resque.redis = REDIS