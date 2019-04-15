# like https://en.wikipedia.org/wiki/Help:Authority_control
module UriAuthorityControl
  AUTHORITY_CONTROL_PROVIDERS = {
    LCCN: {
      label: 'LCCN',
      name: 'Library of Congress Control Number',
      url: 'https://lccn.loc.gov/lccnperm-faq.html',
      patterns: [
        # https://lccn.loc.gov/no97021030
        lambda do |uri|
          uri.host == 'lccn.loc.gov' && uri.path.match(%r{/([a-zA-Z]*\d+)/?})
        end,
        # https://id.loc.gov/authorities/names/n79022889
        lambda do |uri|
          uri.host == 'id.loc.gov' &&
            uri.path.match(%r{/authorities/names/([a-zA-Z]*\d+)/?})
        end
      ]
    },
    GND: {
      label: 'GND',
      name: 'Gemeinsame Normdatei',
      url: 'https://www.dnb.de/DE/Standardisierung/GND/gnd_node.html',
      patterns: [
        lambda do |uri|
          # https://d-nb.info/gnd/118529579
          uri.host == 'd-nb.info' && uri.path.match(%r{/gnd/([a-zA-Z0-9]+)/?})
        end
      ]
    },
    VIAF: {
      label: 'VIAF',
      name: 'Virtual International Authority File',
      url: 'https://viaf.org',
      patterns: [
        # https://viaf.org/viaf/75121530
        ->(uri) { uri.host == 'viaf.org' && uri.path.match(%r{/viaf/(\d+)/?}) }
      ]
    }
  }.freeze

  def self.detect(uri)
    throw TypeError unless uri.is_a?(URI)

    res =
      AUTHORITY_CONTROL_PROVIDERS.lazy.map do |kind, provider|
        match =
          provider[:patterns].lazy.map { |pat| pat.call(uri) }.detect(&:itself)
        { kind: kind, label: match[1] } if match
      end.detect(&:itself)

    if res
      res.merge(
        provider: AUTHORITY_CONTROL_PROVIDERS[res[:kind]].except(:patterns)
      )
    end
  end

end
