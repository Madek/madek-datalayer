require 'spec_helper'

describe UriAuthorityControl do
  describe 'detects correct data' do
    EXAMPLES = [
      { input: 'https://example.com', output: nil },

      { input: 'https://another.example.com/viaf/75121530', output: nil },

      {
        input: 'https://d-nb.info/gnd/118529579',
        output: {
          kind: :GND,
          label: '118529579',
          provider: {
            label: 'GND',
            name: 'Gemeinsame Normdatei',
            url: 'https://www.dnb.de/DE/Standardisierung/GND/gnd_node.html'
          }
        }
      },

      {
        input: 'https://lccn.loc.gov/no97021030',
        output: {
          kind: :LCCN,
          label: 'no97021030',
          provider: {
            label: 'LCCN',
            name: 'Library of Congress Control Number',
            url: 'https://lccn.loc.gov/lccnperm-faq.html'
          }
        }
      },
      {
        input: 'https://id.loc.gov/authorities/names/n79022889',
        output: {
          kind: :LCCN,
          label: 'n79022889',
          provider: {
            label: 'LCCN',
            name: 'Library of Congress Control Number',
            url: 'https://lccn.loc.gov/lccnperm-faq.html'
          }
        }
      },

      {
        input: 'https://viaf.org/viaf/75121530',
        output: {
          kind: :VIAF,
          label: '75121530',
          provider: {
            label: 'VIAF',
            name: 'Virtual International Authority File',
            url: 'https://viaf.org'
          }
        }
      },

      {
        input: 'http://www.wikidata.org/entity/Q42',
        output: {
          kind: :WIKIDATA,
          label: 'Q42',
          provider: {
            label: 'Wikidata',
            name: 'Wikidata Entity URI',
            url: 'https://www.wikidata.org'
          }
        }
      },

      {
        input: 'https://orcid.org/0000-0002-1825-0097',
        output: {
          kind: :ORCID,
          label: '0000-0002-1825-0097',
          provider: {
            label: 'ORCID iD',
            name: 'Open Researcher and Contributor ID',
            url: 'https://www.orcid.org'
          }
        }
      },

      {
        input: 'https://www.imdb.com/name/nm0251868/',
        output: {
          kind: :IMDB,
          label: 'nm0251868',
          provider: {
            label: 'IMDb ID',
            name: 'Internet Movie Database identifier',
            url: 'https://www.imdb.com/'
          }
        }
      },

      {
        input: 'https://researcherid.com/rid/K-8011-2013',
        output: {
          kind: :ResearcherID,
          label: 'K-8011-2013',
          provider: {
            label: 'ResearcherID',
            name: 'Web of Science ResearcherID',
            url: 'https://www.researcherid.com'
          }
        }
      },
      {
        input: 'https://www.researcherid.com/rid/K-8011-2013',
        output: {
          kind: :ResearcherID,
          label: 'K-8011-2013',
          provider: {
            label: 'ResearcherID',
            name: 'Web of Science ResearcherID',
            url: 'https://www.researcherid.com'
          }
        }
      }

    ]

    EXAMPLES.each do |item|
      example("URI: <#{item[:input]}>") do
        output = UriAuthorityControl.detect(URI.parse(item[:input]))
        expect(output).to eq item[:output]
      end
    end
  end
end
