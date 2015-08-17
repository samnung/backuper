
module Backuper
  module Constants
    CONFIG_FOLDER_BASE_PATH = '.backuper'
    CONFIG_FILE_BASE_PATH = File.join(CONFIG_FOLDER_BASE_PATH, 'config.rb')

    def config_path(home = Dir.home)
      File.join(home, CONFIG_FILE_BASE_PATH)
    end

    # ======= backup paths ================

    BACKUP_CONFIG_FOLDER_BASE_PATH = 'config'

    def backup_config_file_path(backup_path)
      File.join(backup_path, BACKUP_CONFIG_FOLDER_BASE_PATH, 'config.rb')
    end

    BACKUP_DATA_BASE_PATH = 'data'
    BACKUP_INFO_BASE_PATH = 'backuper_info.yaml'
  end
end