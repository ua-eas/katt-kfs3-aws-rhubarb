set :stage, :tst

# Set the app server host and port
role :app, %w{ssh-user@localhost:22}

# Deploy from the develop branch
set :branch, 'development'
