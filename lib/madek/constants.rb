module Madek

  module Constants

    MADEK_V2_PERMISSION_ACTIONS = [:download, :edit, :manage, :view]

    ZIP_STORAGE_DIR      = Rails.root.join('tmp', 'zipfiles')
    DOWNLOAD_STORAGE_DIR = Rails.root.join('tmp', 'downloads')
    FILE_STORAGE_DIR     = Rails.root.join('db', 'media_files',
                                           Rails.env, 'attachments')
    THUMBNAIL_STORAGE_DIR = Rails.root.join('db', 'media_files',
                                            Rails.env, 'attachments')

  end
end
