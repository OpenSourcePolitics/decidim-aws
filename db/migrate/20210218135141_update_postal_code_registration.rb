# frozen_string_literal: true

class UpdatePostalCodeRegistration < ActiveRecord::Migration[5.2]
  def up
    affected_users = users_with_postal_code
    updated_users = 0

    affected_users&.each do |user|
      next unless user[:address].present? && user[:address]['postal_code'].present?

      current_postal_code = user[:address]["postal_code"]

      if postal_code_need_update? current_postal_code
        user[:address]["postal_code"] = reformat_postal_code current_postal_code
        user.save!
        updated_users += 1
      end
    end

    puts "#{updated_users} users updated"
  end

  private

  def users_with_postal_code
    Decidim::User.where.not(address: [nil, {}])
  end

  def postal_code_need_update?(postal_code)
    return false if postal_code.is_a?(String) && postal_code.length != 4

    true
  end

  def reformat_postal_code(postal_code)
    postal_code = postal_code.to_s if postal_code.is_a? Integer

    return "0#{postal_code}" if postal_code.length == 4

    postal_code
  end
end
