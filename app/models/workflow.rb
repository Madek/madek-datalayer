# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength

class Workflow < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :owners, class_name: 'User'
  has_many :collections

  before_create :set_default_configuration

  store_accessor :configuration, :common_permissions, :common_meta_data

  def common_permissions
    super.map do |key, value|
      if key.to_s == 'read_public' && ![true, false].include?(value)
        [key, value == 'true']
      else
        [key, value]
      end
    end.to_h
  end

  def master_collection
    collections.find_by(is_master: true)
  end

  def finish
    WorkflowLocker.new(self).call
  end

  def mandatory_meta_key_ids
    self.common_meta_data
      .select { |cfg| cfg['is_mandatory'] }
      .map { |cfg| cfg['meta_key_id'] }
  end

  private

  def default_responsible_user
    creator
  end

  def default_common_permissions
    {
      responsible: default_responsible_user.id,
      write: [],
      read: [],
      read_public: true
    }
  end

  def default_common_meta_data
    # NOTE: defaults will be empty OR provided by "WorkflowTemplates",
    # for now the hardcoded values are fitting for a research project.

    # NOTE: currently keys come from this context: https://madek-spiel.kiste.li/admin/contexts/fair-data
    [
      {
        meta_key_id: 'madek_core:authors',
        is_common: false,
        is_mandatory: true,
        is_overridable: true
      },
      {
        meta_key_id: 'madek_core:title',
        is_common: false,
        is_mandatory: true,
        is_overridable: true
      },
      {
        meta_key_id: 'zhdk_bereich:​project_title',
        is_common: true,
        is_mandatory: false,
        is_overridable: false
      },
      {
        meta_key_id: 'zhdk_bereich:​project_title_english',
        is_common: true,
        is_mandatory: false,
        is_overridable: false
      },
      {
        meta_key_id: 'zhdk_bereich:​project_leader',
        is_common: true,
        is_mandatory: false,
        is_overridable: false
      },
      {
        meta_key_id: 'copyright:publication_date',
        is_common: false,
        is_mandatory: false,
        is_overridable: true
      },
      {
        meta_key_id: 'madek_core:keywords',
        is_common: false,
        is_mandatory: false,
        is_overridable: true
      },
      {
        meta_key_id: 'media_content:type',
        is_common: false,
        is_mandatory: false,
        is_overridable: true
      },
      {
        meta_key_id: 'media_object:other_creative_participants',
        is_common: false,
        is_mandatory: false,
        is_overridable: true
      },
      {
        meta_key_id: 'madek_core:portrayed_object_date',
        is_common: false,
        is_mandatory: false,
        is_overridable: true
      },
      {
        meta_key_id: 'madek_core:description',
        is_common: false,
        is_mandatory: false,
        is_overridable: true,
        value: [
          {
            string:
              'Material zur Verfügung gestellt im Rahmen des ' \
                "Forschungsprojekts «#{name}»"
          }
        ]
      },
      {
        meta_key_id: 'madek_core:copyright_notice',
        is_common: true,
        is_mandatory: true,
        is_overridable: true,
        value: [{ string: "This resource is a part of the project #{name}" }]
      },
      {
        meta_key_id: 'copyright:license',
        is_common: true,
        is_mandatory: false,
        is_overridable: true,
        value: Keyword.where(term: 'CC-By-SA-CH: Attribution Share Alike')
      },
      {
        meta_key_id: 'copyright:copyright_usage',
        is_common: true,
        is_mandatory: true,
        is_overridable: true
      },
      {
        meta_key_id: 'madek_core:subtitle',
        is_common: true,
        is_mandatory: false,
        is_overridable: true
      },
      {
        meta_key_id: 'media_content:portrayed_object_dimensions',
        is_common: true,
        is_mandatory: false,
        is_overridable: true
      }
    ]
  end

  def append_type_to_values(data)
    data.map do |entry|
      entry[:value] = Array.wrap(entry[:value])
      entry[:value] =
        entry[:value].map do |val|
          type = val.class.name
          if val.respond_to?(:serializable_hash)
            val = val.serializable_hash
            val['type'] = type
            val['uuid'] = val.delete('id')
          end
          val
        end
      entry
    end
  end

  def set_default_configuration
    self.common_permissions = default_common_permissions
    self.common_meta_data = append_type_to_values(default_common_meta_data)
  end
end
