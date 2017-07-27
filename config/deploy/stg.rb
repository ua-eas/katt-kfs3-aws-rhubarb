set :stage, :stg

role :app, %w{ssh-user@localhost:22}

# set :rails_env, :stg
set :branch, 'master'
