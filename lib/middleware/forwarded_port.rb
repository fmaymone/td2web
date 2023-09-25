class ForwardedPort
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['HTTP_X_FORWARDED_PORT']
      env['SERVER_PORT'] = env['HTTP_X_FORWARDED_PORT']
    end
    @app.call(env)
  end
end
