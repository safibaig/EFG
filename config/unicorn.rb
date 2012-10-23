# Include the default config file.
def load_file_if_exists(config, file)
  config.instance_eval(File.read(file)) if File.exist?(file)
end
load_file_if_exists(self, "/etc/govuk/unicorn.rb")

# EFG lives in its own little world - it has a server all to itself.
worker_processes 4

# Currently we have some reports on the request thread that take a long-time
# to generate. Change the timeout for a worker to finish the response from
# default of 60 seconds to 120 seconds.
timeout 120
