debugger

if Rails.env.development?
  ActiveSupport::Dependencies.load_paths << lib_path
end

require 'lash'