module FilterBySearchTerm
  extend ActiveSupport::Concern

  included do
    def self.filter_by_term_using_attributes(query, *attrs)
      tokens = tokenize(query)
      return all if tokens.empty?

      sql_string = attrs.map do |attr|
        sanitize_sql_for_conditions(["#{attr} ILIKE ALL (ARRAY[?]::text[])", tokens])
      end.join(' OR ')
      where(sql_string)
    end

    private

    def self.tokenize(string)
      return [] unless string.is_a?(String)

      string.split(/[[:space:]]+|[[:punct:]]+/)
        .reject(&:blank?)
        .map { |token| "%#{token}%" }
    end
  end
end
