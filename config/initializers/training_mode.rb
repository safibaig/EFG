# Flag used to indicate whether this is the training app or not. CSS can be different, etc.
EFG::Application.config.training_mode = (ENV["EFG_HOST"] =~ /training/)

if EFG::Application.config.training_mode
  ActionMailer::Base.send(:include, TrainingMailer)
end
