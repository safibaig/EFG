module Ithc
  class Generator
    class << self
      def seed(email)
        re = /([^@]+)(@.+)/
        match = email.match re
        %w{CfeAdmin CfeUser PremiumCollectorUser AuditorUser}.each do |user_class|
          find_or_create(user_class, match)
        end

        biggest_lender = find_biggest_lender

        if biggest_lender
          %w{LenderAdmin LenderUser}.each do |user_class|
            find_or_create(user_class, match, biggest_lender)
          end
        end
      end
    private
      def create_user_email(user_class, email)
        "#{email[1]}+#{user_class.underscore}#{email[2]}"
      end

      # Return the Lender that has the most loans
      def find_biggest_lender
        lender_id = Lender.find_by_sql("SELECT le.id, count(*) from lenders le inner join loans lo on lo.lender_id = le.id group by le.id order by count(*) desc").first
        return Lender.find(lender_id) if lender_id
      end

      def find_or_create(user_class, email, lender = nil)
        email = create_user_email(user_class, email)
        klass = Kernel.const_get(user_class)
        existing = klass.find_by_email(email)
        if not existing
          result = klass.create(email:email,
            password:"password",
            password_confirmation:"password",
            first_name:"Pen", last_name:"Test")
          if lender
            result.lender = lender
            result.save!
          end
          puts "Created #{user_class} with username '#{result.username}'"
        else
          puts "Found #{user_class} with username '#{existing.username}'"
        end
      end
    end
  end
end