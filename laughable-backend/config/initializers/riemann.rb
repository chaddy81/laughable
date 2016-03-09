RailsApi::Application.configure do
  config.riemann_metrics.enabled = true
  config.riemann_metrics.service_name = "#{Rails.env}-rails_api"
  config.riemann_metrics.host = '172.31.25.13'
  config.riemann_metrics.ttl = 5
  config.riemann_metrics.riemann_env = Rails.env
end
