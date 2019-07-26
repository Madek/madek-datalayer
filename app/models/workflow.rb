class Workflow < ApplicationRecord
  belongs_to :user
  has_many :collections

  before_create :set_default_configuration

  def master_collection
    collections.find_by(is_master: true)
  end

  private

  def random_user_id
    User.pluck(:id).sample
  end

  def random_group_id
    Group.pluck(:id).sample
  end

  def random_api_client_id
    ApiClient.pluck(:id).sample
  end

  def common_permissions
    {
      responsible: random_user_id,
      write: [random_group_id],
      read: [random_api_client_id],
      read_public: true
    }
  end

  def common_meta_data
    [
      {
        key: 'Beschreibungstext',
        value:
          'Material zur Verfügung gestellt im Rahmen des Forschungsprojekts «Sound Colour Space»'
      },
      { key: 'Rechtsschutz', value: 'CC-By-SA-CH: Attribution Share Alike' },
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
