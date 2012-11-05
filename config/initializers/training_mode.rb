EFG::Application.config.training_mode = true

if EFG::Application.config.training_mode
  ActionMailer::Base.send(:include, TrainingMailer)
end
