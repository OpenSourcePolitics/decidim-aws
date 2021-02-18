class UpdatePostalCodeRegistration < ActiveRecord::Migration[5.2]
  def up

    affected_users = users_with_postal_code
    if affected_users.blank?
      puts "Update postal code migration : No users affected.
End of migration"
      return

    else
      puts "#{affected_users.count} users will be affected, are you sure ? [y/n]"
      choice = $stdin.gets.chomp

      if choice.downcase != "y"
        puts "Migration aborted"
        return
      end
    end

    affected_users&.each do |user|
      next unless user[:address].present? && user[:address]['postal_code'].present?

      current_postal_code = user[:address]["postal_code"]

      user[:address]["postal_code"] = reformat_postal_code current_postal_code
      user.save!
    end
  end

  def users_with_postal_code
    Decidim::User.where.not(address: [nil, {}])
  end

  def reformat_postal_code(postal_code)
    postal_code = postal_code.to_s if postal_code.is_a? Integer

    return "0#{postal_code}" if postal_code.length == 4

    postal_code
  end
end
