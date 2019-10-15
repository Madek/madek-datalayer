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
    [
      {
        key: 'Beschreibungstext',
        meta_key_id: 'madek_core:description',
        value: [{string: "Material zur Verfügung gestellt im Rahmen des Forschungsprojekts «#{name}»"}]
      },
      {
        key: 'Copyright Notice',
        meta_key_id: 'madek_core:copyright_notice',
        value: [{string: "This resource is a part of the project #{name}"}]
      }
    ]
    # FIXME: re-enable this, but as Keywords!!!
    # {
    #   key: 'Rechtsschutz',
    #   meta_key_id: 'copyright:license',
    #   value: 'CC-By-SA-CH: Attribution Share Alike'
    # }
  end

  def set_default_configuration
    self.common_permissions = default_common_permissions
    self.common_meta_data = default_common_meta_data
  end
end
