module ApplicationHelper
  def allowed_omniauth?(provider_name)
    return true if request.env['PATH_INFO'].end_with?('/users/sign_in')
    return true if request.env['PATH_INFO'].end_with?('/committee_requests/new')

    (available_authorizations? && request.env.dig(:available_authorizations).include?(provider_name.to_s))
  end

  private

  def available_authorizations?
    request.env.dig(:available_authorizations).present?
  end

  def omniauth_buttons_cache_version
    "omniauth_buttons/#{omniauth_buttons_cache_digest}"
  end

  def omniauth_buttons_cache_digest
    current_organization.cache_version + request_digest + request_available_authorizations
  end

  def request_digest
    return "" if frozen_cache?(request.env['PATH_INFO'])

    request.env['PATH_INFO']
  end

  # Disable cache for specific routes
  def frozen_cache?(request)
    return true if request == "/"
    return true if request.start_with?("/404")
    return true if request.start_with?("/pages")

    false
  end

  def request_available_authorizations
    return '' if request.env.dig(:available_authorizations).blank?

    '/' + request.env.dig(:available_authorizations).join('-')
  end

  def existing_author?(author_id)
    Decidim::User.find(author_id).delete_reason.nil?
  end

  def static_page_topics_in_footer
    @static_page_topics_in_footer ||= current_organization.static_page_topics.where(show_in_footer: true)
  end

  def static_pages_in_footer
    @static_pages_in_footer ||= current_organization.static_pages.where(show_in_footer: true)
  end
end
