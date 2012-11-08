module TrainingMailer
  extend ActiveSupport::Concern

  included do
    alias_method_chain :mail, :training_subject
  end

  def mail_with_training_subject(headers = {}, &block)
    message = mail_without_training_subject(headers, &block)
    message.subject = "[TRAINING] #{message.subject}"
    message
  end
end
