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
