DB_SEEDS ||= YAML.load_file(Rails.root.join('db', 'seeds_and_defaults.yml'))
  .deep_symbolize_keys

DEFAULT_CONTEXTS = DB_SEEDS[:MADEK_DEFAULT_CONTEXTS] or fail
DEFAULT_CONTEXT_SETTINGS = DB_SEEDS[:MADEK_DEFAULT_SETTINGS][:CONTEXTS] or fail
DEFAULT_CKEY_SETTINGS = DB_SEEDS[:MADEK_DEFAULT_SETTINGS][:CONTEXT_KEYS] or fail
DEFAULT_STRING_SETTINGS = DB_SEEDS[:MADEK_DEFAULT_SETTINGS][:STRINGS] or fail

# config helper
def meta_key_ids_from_config(cfg)
  cfg[:meta_keys_where] ? MetaKey.where(cfg[:meta_keys_where]).map(&:id) : []
end

namespace :db do
  desc 'Setup DB defaults (for first-time installation)'
  task defaults: :environment do

    ActiveRecord::Base.transaction do

      # Default Contexts ##########################################################

      DEFAULT_CONTEXTS.each do |ctx|
        # only create/override defaults if context does not exist:
        next if Context.find_by(id: ctx[:id])

        context_attrs = ctx.slice(:id, :labels, :descriptions, :admin_comment)
          .map do |k, v|
            if v.is_a?(Hash)
              [k, v.map { |loc, val| [loc, val.try(:strip)] }.to_h]
            else
              [k, v.try(:strip)]
            end
          end.to_h

        key_attrs = ctx[:context_key_attr] || {}

        c = Context.create!(context_attrs)

        meta_key_ids_from_config(ctx).each.with_index do |mkid, index|
          ContextKey.find_or_create_by(
            key_attrs.merge(context: c, meta_key_id: mkid, position: index))
        end

      end

      # Default Settings ##########################################################

      settings = AppSettings.first

      DEFAULT_CONTEXT_SETTINGS.each do |key, val|
        settings.update_attributes!(key => val)
      end

      DEFAULT_CKEY_SETTINGS.each do |key, cfg|
        ckeys = ContextKey.where(
          context_id: cfg[:context_id], meta_key_id: meta_key_ids_from_config(cfg))

        settings.update_attributes!(key => ckeys.map(&:id))
      end

      DEFAULT_STRING_SETTINGS.each do |key, string|
        settings.update_attributes!(key => string)
      end

    end

  end

end
