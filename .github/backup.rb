#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

instance_id = ENV["INSTANCE_ID"]
database_name = ENV["DATABASE_NAME"]
scw_access_key = ENV["SCW_ACCESS_KEY"]
scw_secret_key = ENV["SCW_SECRET_KEY"]
scw_zone = ENV["SCW_ZONE"]
name = "#{database_name}-backup-#{Time.now.strftime("%Y%m%d%H%M%S")}"

backup_output = ""

puts "Performing backup ..."
backup = -> { backup_output = `SCW_ACCESS_KEY=#{scw_access_key} SCW_SECRET_KEY=#{scw_secret_key} scw rdb backup create instance-id=#{instance_id} database-name=#{database_name} name=#{name} region=#{scw_zone} -o json` }

while backup.call.empty?
  puts "Backup enqueuing failed, a backup may be already running"
  sleep 10
  backup.call
end

puts "Backup successful enqueued"

puts "Waiting for backup to be ready ..."
backup_id = -> { `scw rdb backup get #{JSON.parse(backup_output)["id"]} -o json` }
backup_status = -> { JSON.parse(backup_id.call)["status"] }

while backup_status.call != "ready"
  puts "Backup not ready yet, waiting ..."
  sleep 10
  backup_id.call
end

puts "Backup done"
exit 0
