class Workflow < ApplicationRecord
  belongs_to :user
  has_many :collections

  before_create :set_default_configuration

  def master_collection
    collections.find_by(is_master: true)
  end

  def finish
    WorkflowLocker.new(self).call
  end

  private

  def random_user_id
    User.pluck(:id).sample
  end

  def random_group_ids
    Group.pluck(:id).sample(3)
  end

  def random_api_client_ids
    ApiClient.pluck(:id).sample(2)
  end

  def common_permissions
    {
      responsible: random_user_id,
      write: random_group_ids,
      read: random_api_client_ids,
      read_public: true
    }
  end

  def common_meta_data
    [
      {
        key: 'Beschreibungstext',
        meta_key_id: 'madek_core:description', # TMP!
        value:
          'Material zur Verfügung gestellt im Rahmen des Forschungsprojekts «Sound Colour Space»'
      },
      {
        key: 'Copyright Notice',
        meta_key_id: 'madek_core:copyright_notice',
        value: "This resource is a part of the project #{name}"
      },
      { key: 'Rechtsschutz', meta_key_id: 'copyright:license', value: 'CC-By-SA-CH: Attribution Share Alike' },
      { key: 'ArkID', value: 'http://pid.zhdk.ch/ark:99999/x9t38rk45c' }
    ]
  end

  def set_default_configuration
    self.configuration = {
      common_permissions: common_permissions,
      common_meta_data: common_meta_data  
    }
  end
end
