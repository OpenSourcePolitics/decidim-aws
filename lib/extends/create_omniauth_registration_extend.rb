# frozen_string_literal: true
require 'active_support/concern'

module CreateOmniauthRegistrationExtend
  extend ActiveSupport::Concern

  included do

    def create_or_find_user
      generated_password = SecureRandom.hex

      if (verified_email || form.email).blank?

        @user = User.new(
          email: "",
          organization: organization,
          name: form.name,
          nickname: form.nickname,
          newsletter_notifications_at: nil,
          email_on_notification: false,
          accepted_tos_version: organization.tos_version,
          # managed: true,
          password: generated_password,
          password_confirmation: generated_password
        )
        @user.skip_confirmation!
      else

        @user = User.find_or_initialize_by(
          email: verified_email,
          organization: organization
        )

        if @user.persisted?
          # If user has left the account unconfirmed and later on decides to sign
          # in with omniauth with an already verified account, the account needs
          # to be marked confirmed.
          @user.skip_confirmation! if !@user.confirmed? && @user.email == verified_email
        else
          @user.email = (verified_email || form.email)
          @user.name = user_params[:name] || form.name
          @user.nickname = user_params[:nickname] || form.normalized_nickname
          @user.newsletter_notifications_at = nil
          @user.email_on_notification = true
          @user.password = generated_password
          @user.password_confirmation = generated_password
          @user.remote_avatar_url = form.avatar_url if form.avatar_url.present?
          @user.skip_confirmation! if verified_email
          @after_confirmation = true
        end
      end

      @user.tos_agreement = "1"
      @user.save!
    end

  end
end

Decidim::CreateOmniauthRegistration.send(:include, CreateOmniauthRegistrationExtend)
