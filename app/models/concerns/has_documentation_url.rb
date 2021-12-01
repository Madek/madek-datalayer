module Concerns
  module HasDocumentationUrl
    def sanitize_documentation_url(locale = nil)
      sanitize_url(documentation_url(locale))
    end

    private

    def sanitize_url(url)
      uri = URI.parse(url)
      uri&.host && url
    rescue URI::InvalidURIError
      nil
    end
  end
end
