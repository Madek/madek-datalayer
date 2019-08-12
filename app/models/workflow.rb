class Workflow < ApplicationRecord
  belongs_to :user
  has_many :collections
  has_and_belongs_to_many :owners, class_name: 'User'

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

  def prepare_data(ar_relation)
    ar_relation.map do |obj|
      { uuid: obj.id, type: obj.class.name }
    end
  end

  def random_user_id
    User.pluck(:id).sample
  end

  def random_users
    prepare_data User.where(id: User.pluck(:id).sample(3))
  end

  def random_groups
    prepare_data Group.where(id: Group.pluck(:id).sample(2))
  end

  def random_api_client
    prepare_data ApiClient.where(id: ApiClient.pluck(:id).sample)
  end

  def default_common_permissions
    {
      responsible: random_user_id,
      write: [random_users, random_groups].flatten,
      read: [random_users, random_groups, random_api_client].flatten,
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
        value: ["Material zur Verfügung gestellt im Rahmen des Forschungsprojekts «#{name}»"]
      },
      {
        key: 'Copyright Notice',
        meta_key_id: 'madek_core:copyright_notice',
        value: ["This resource is a part of the project #{name}"]
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
