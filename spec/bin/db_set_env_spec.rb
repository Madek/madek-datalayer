require 'fileutils'
require 'open3'
require 'tmpdir'

RSpec.describe 'bin/db-set-env' do
  def run_script(database_config, bundle_status: 0)
    Dir.mktmpdir do |project_dir|
      FileUtils.mkdir_p(["#{project_dir}/bin", "#{project_dir}/config"])
      FileUtils.cp(File.expand_path('../../bin/db-set-env', __dir__),
                   "#{project_dir}/bin/db-set-env")
      File.write("#{project_dir}/config/database.yml", "---\n")

      fake_bin = "#{project_dir}/fake-bin"
      FileUtils.mkdir_p(fake_bin)
      File.write("#{fake_bin}/bundle", <<~BASH)
        #!/usr/bin/env bash
        printf '%s\n' "$@" > "$BUNDLE_ARGS_FILE"
        printf 'rails boot output for %s\n' "$RAILS_ENV"
        printf '%s' "$DATABASE_CONFIG" > "$DBCONFIG_FILE"
        exit "$BUNDLE_STATUS"
      BASH
      FileUtils.chmod('+x', "#{fake_bin}/bundle")

      bundle_args_file = "#{project_dir}/bundle-args"
      env = {
        'BUNDLE_ARGS_FILE' => bundle_args_file,
        'BUNDLE_STATUS' => bundle_status.to_s,
        'DATABASE_CONFIG' => database_config,
        'PATH' => "#{fake_bin}:#{ENV.fetch('PATH')}",
        'RAILS_ENV' => nil
      }
      command = <<~BASH
        source "#{project_dir}/bin/db-set-env"
        printf 'RESULT=%s|%s|%s|%s\n' \
          "$PGDATABASE" "$PGPORT" "$PGUSER" "$PGPASSWORD"
      BASH
      result = Open3.capture3(env, 'bash', '-c', command)
      [*result, File.readlines(bundle_args_file, chomp: true)]
    end
  end

  it 'uses Rails-resolved config without capturing Rails output' do
    stdout, stderr, status, bundle_args = run_script(
      '{"database":"madek","port":6543,"username":"postgres"}'
    )

    expect(status).to be_success
    expect(bundle_args).to eq([
      'exec',
      'rails',
      'runner',
      'File.write(ENV.fetch("DBCONFIG_FILE"), ActiveRecord::Base.connection_db_config.configuration_hash.to_json)'
    ])
    expect(stdout).to include('RESULT=madek|6543|postgres|')
    expect(stdout).not_to include('rails boot output')
    expect(stderr).to include('rails boot output for development')
  end

  it 'fails when the resolved config has no database' do
    _stdout, _stderr, status = run_script(
      '{"port":6543,"username":"postgres"}'
    )

    expect(status).not_to be_success
  end

  it 'preserves a Rails runner failure' do
    _stdout, _stderr, status = run_script(
      '{"database":"madek"}', bundle_status: 42
    )

    expect(status.exitstatus).to eq(42)
  end
end
