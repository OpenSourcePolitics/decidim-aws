class UpdateAuthUserName < ActiveRecord::Migration[5.2]
  def change
    Decidim::Authorization.where(name: 'france_connect_profile').each do |auth|
      auth.user.update_columns(name: auth.metadata[:first_name]&.split(' ')&.first)
    end
  end
end
