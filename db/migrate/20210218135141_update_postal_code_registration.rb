# frozen_string_literal: true

class UpdatePostalCodeRegistration < ActiveRecord::Migration[5.2]
  def up
    affected_users = users_with_postal_code

    unless affected_users.present? && affected_users.respond_to?(:each)
      puts 'No users affected by migration, migration aborted !'
      return
    end

    updated_users = 0
    affected_users.each do |user|
      next unless user[:address].present?
      next unless user[:address]['postal_code'].present?

      current_postal_code = user[:address]['postal_code']
      next unless postal_code_need_update? current_postal_code

      user[:address]['postal_code'] = reformat_postal_code current_postal_code
      user.save!
      updated_users += 1
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

    if postal_code.length == 4 && postal_code.respond_to?(:to_s)
      return "0#{postal_code}"
    end

    postal_code
  end
end
