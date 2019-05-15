# Madek Authority Control Providers
#
# concept like https://en.wikipedia.org/wiki/Help:Authority_control
# see their implementation: https://www.wikidata.org/w/index.php?title=MediaWiki:Gadget-AuthorityControl.js&oldid=802023356
# also the early version: https://www.wikidata.org/w/index.php?title=MediaWiki:Gadget-AuthorityControl.js&oldid=179329592

module UriAuthorityControl
  AUTHORITY_CONTROL_PROVIDERS = {

    GND: {
      label: 'GND',
      name: 'Gemeinsame Normdatei',
      url: 'https://www.dnb.de/DE/Standardisierung/GND/gnd_node.html',
      patterns: [
        lambda do |uri|
          # https://d-nb.info/gnd/118529579
          uri.host == 'd-nb.info' && uri.path.match(%r{^/gnd/([a-zA-Z0-9]+)})
        end
      ]
    },

    LCCN: {
      label: 'LCCN',
      name: 'Library of Congress Control Number',
      url: 'https://lccn.loc.gov/lccnperm-faq.html',
      patterns: [
        # https://lccn.loc.gov/no97021030
        lambda do |uri|
          uri.host == 'lccn.loc.gov' && uri.path.match(%r{^/([a-zA-Z]*\d+)})
        end,
        # https://id.loc.gov/authorities/names/n79022889
        lambda do |uri|
          uri.host == 'id.loc.gov' &&
            uri.path.match(%r{^/authorities/names/([a-zA-Z]*\d+)})
        end
      ]
    },

    IMDB: {
      # technical info, via wikidata: https://www.wikidata.org/wiki/Property:P345
      label: 'IMDb ID',
      name: 'Internet Movie Database identifier',
      url: 'https://www.imdb.com/',
      patterns: [
        # https://www.imdb.com/name/nm0251868/
        lambda do |uri|
          uri.host.sub(/^www./, '') == 'imdb.com' &&
            uri.path.match(%r{^/name/(nm\d{7,8})})
        end
      ]
    },

    ORCID: {
      label: 'ORCID iD',
      name: 'Open Researcher and Contributor ID',
      url: 'https://www.orcid.org',
      patterns: [
        # https://orcid.org/0000-0002-1825-0097
        lambda do |uri|
          pathr = %r{^/(\d{4}-\d{4}-\d{4}-\d{3}[\dX]{1})}
          uri.host == 'orcid.org' && uri.path.match(pathr)
        end
      ]
    },

    ResearcherID: {
      # technical info, via wikidata: https://www.wikidata.org/wiki/Property_talk:P1053
      label: 'ResearcherID',
      name: 'Web of Science ResearcherID',
      url: 'https://www.researcherid.com',
      patterns: [
        # https://www.researcherid.com/rid/K-8011-2013
        lambda do |uri|
          uri.host.sub(/^www./, '') == 'researcherid.com' &&
            uri.path.match(%r{^/rid/([a-zA-Z\d-]+)})
        end
      ]
    },

    VIAF: {
      label: 'VIAF',
      name: 'Virtual International Authority File',
      url: 'https://viaf.org',
      patterns: [
        # https://viaf.org/viaf/75121530
        ->(uri) { uri.host == 'viaf.org' && uri.path.match(%r{^/viaf/(\d+)}) }
      ]
    },

    WIKIDATA: {
      # technical info: <https://www.wikidata.org/wiki/Wikidata:Data_access/de>
      label: 'Wikidata',
      name: 'Wikidata Entity URI',
      url: 'https://www.wikidata.org',
      patterns: [
        # http://www.wikidata.org/entity/Q42
        lambda do |uri|
          uri.host.sub(/^www./, '') == 'wikidata.org' &&
            uri.path.match(%r{^/entity/(Q\d+)})
        end
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
  # rubocop:disable Lint/HandleExceptions
  rescue
  end

end
