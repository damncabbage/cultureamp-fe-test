require './api'

# Map /api (or whatever) off to the backend API service.
map "/#{ENV.fetch('API_BASE_PATH')}" do
  run SurveyAPI
end

RACK_ENV = ENV.fetch('RACK_ENV', 'development')
case RACK_ENV
when 'development'
  WEBPACK_PORT = ENV['WEBPACK_PORT'] or raise(
    'WEBPACK_PORT environment variable needs to be set; see .env.development'
  )

  require 'rack-proxy'
  class WebpackProxy < Rack::Proxy
    def rewrite_env(env)
      env['HTTP_HOST'] = "localhost:#{Integer(WEBPACK_PORT)}"
      env['REQUEST_PATH'] = env[Rack::PATH_INFO]
      env
    end
  end

  run Rack::URLMap.new({
    "/" => WebpackProxy.new,
  })

when 'production'
  use Rack::Static, {
    urls: ['/assets'],
    root: 'dist'
  }
  run -> (env) do
    env[Rack::PATH_INFO] = '/index.html'
    Rack::File.new('dist').call(env)
  end

else
  raise "Unrecognised RACK_ENV value: #{ENV['RACK_ENV']}"
end
