# env variable is only set to "true" in environments that have JWT installed
if ENV["ENABLE_COOL_FEATURE"] == "true"
  puts JWT
end
