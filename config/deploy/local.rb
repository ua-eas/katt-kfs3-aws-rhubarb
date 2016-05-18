set :stage, :local

# Set the app server host and port
role :app, %w{ssh-user@localhost:2222}

# Deploy from the develop branch
set :branch, 'development'