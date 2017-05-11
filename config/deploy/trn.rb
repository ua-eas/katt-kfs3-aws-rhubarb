set :stage, :trn

role :app, %w{ssh-user@localhost:22}

#deploy the latest tag using natural sorting because we are not using Git 2.x
set :branch, `git tag | sort -V`.split("\n").last
