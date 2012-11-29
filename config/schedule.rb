# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :runner_with_file, "cd :path && script/rails runner -e :environment :task :output"

every 1.day, at: '2:00am' do
  rake "loans:update_expired"
end

every :sunday, at: '00:25am' do
  rake "data:extract"
end

every :friday, at: '4:00am' do
  rake "sic_codes:update_loans"
end
