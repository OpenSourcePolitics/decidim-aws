#!/usr/bin/env ruby
# frozen_string_literal: true

rollout = `kubectl rollout restart deployment`
status = `kubectl rollout status deployment`

if status.split("\n").select { |s| s.include?("successfully rolled out") }.count == rollout.split("\n").count
  puts "Deployment was successful"
  puts "Applying migration..."
  system("kubectl apply -f k8s/decidim/app-migrate-job.yml")

  migration_status = `kubectl wait --for=condition=complete job/decidim-an-migration-job`
  if migration_status.include?("condition met")
    puts "Migration was successful"
    exit 0
  else
    puts "Migration failed"
    exit 1
  end
else
  puts "Deployment failed"
  exit 1
end
