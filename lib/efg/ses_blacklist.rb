module EFG
  # Module to handle AWS::SES::ResponseError where an email address has been blacklisted.
  # We don't want to leak that fact to the client; email failure leaks the fact that it
  # was a valid email address within the system.
  module SESBlacklist
    def self.included(base)
      base.class_eval do
        rescue_from AWS::SES::ResponseError do |exception|
          if exception.message =~ /Address blacklisted/i
            @exception = exception
            render "shared/address_blacklisted", status: 500
          else
            raise
          end
        end
      end
    end
  end
end
