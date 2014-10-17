set :stage, :prd

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, %w{kualiadm@uaz-kc-a50.mosaic.arizona.edu kualiadm@uaz-kc-a51.mosaic.arizona.edu}

#deploy the latest tag
set :branch, `git tag`.split("\n").last