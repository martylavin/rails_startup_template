# Gems
# ==================================================

# Segment.io as an analytics solution (https://github.com/segmentio/analytics-ruby)
gem "analytics-ruby"
# For encrypted password
gem "bcrypt-ruby"
# Useful SASS mixins (http://bourbon.io/)
gem "bourbon"

# For authorization (https://github.com/ryanb/cancan)
gem "cancan"

# HAML templating language (http://haml.info)
gem "haml-rails" if yes?("Use HAML instead of ERB?")

# Simple form builder (https://github.com/plataformatec/simple_form)
gem "simple_form"
# To generate UUIDs, useful for various things
gem "uuidtools"

gem_group :development do
  # Rspec for tests (https://github.com/rspec/rspec-rails)
  gem "rspec-rails"
  # Guard for automatically launching your specs when files are modified. (https://github.com/guard/guard-rspec)
  gem "guard-rspec"
end

gem_group :test do
  gem "rspec-rails"
  # Capybara for integration testing (https://github.com/jnicklas/capybara)
  gem "capybara" 
  gem "capybara-webkit"
  # FactoryGirl instead of Rails fixtures (https://github.com/thoughtbot/factory_girl)
  gem "factory_girl_rails"
end

gem_group :production do
  # For Rails 4 deployment on Heroku
  # paratrooper is a library(gem) for creating tasks that deploy to Heroku.
  gem "rails_12factor"
  if yes?("Are you using Heroku?")
    gem "pg" if yes?("Install the postgresql gem?")
    gem 'paratrooper' if yes?("Install the paratrooper gem?")
  end
end


# Setting up foreman to deal with environment variables and services
# https://github.com/ddollar/foreman
# ==================================================
# Use Procfile for foreman
run "echo 'web: bundle exec rails server -p $PORT' >> Procfile"
run "echo PORT=3000 >> .env"
run "echo '.env' >> .gitignore"
# We need this with foreman to see log output immediately
run "echo 'STDOUT.sync = true' >> config/environments/development.rb"



# Initialize guard
# ==================================================
run "bundle exec guard init rspec"



# Initialize CanCan
# ==================================================
run "rails g cancan:ability"



# Clean up Assets
# ==================================================
# Use SASS extension for application.css
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss"
# Remove the require_tree directives from the SASS and JavaScript files. 
# It's better design to import or require things manually.
run "sed -i '' /require_tree/d app/assets/javascripts/application.js"
run "sed -i '' /require_tree/d app/assets/stylesheets/application.css.scss"
# Add bourbon to stylesheet file
run "echo >> app/assets/stylesheets/application.css.scss"
run "echo '@import \"bourbon\";' >>  app/assets/stylesheets/application.css.scss"




# Bootstrap: install from https://github.com/twbs/bootstrap
# Note: This is 3.0.0
# ==================================================
if yes?("Download bootstrap?")
  run "wget https://github.com/twbs/bootstrap/archive/v3.0.0.zip -O bootstrap.zip -O bootstrap.zip"
  run "unzip bootstrap.zip -d bootstrap && rm bootstrap.zip"
  run "cp bootstrap/bootstrap-3.0.0/dist/css/bootstrap.css vendor/assets/stylesheets/"
  run "cp bootstrap/bootstrap-3.0.0/dist/js/bootstrap.js vendor/assets/javascripts/"
  run "rm -rf bootstrap"
  run "echo '@import \"bootstrap\";' >>  app/assets/stylesheets/application.css.scss"
  run "rails g simple_form:install --bootstrap"
end


# Font-awesome: Install from http://fortawesome.github.io/Font-Awesome/
# ==================================================
if yes?("Download font-awesome?")
  run "wget http://fortawesome.github.io/Font-Awesome/assets/font-awesome.zip -O font-awesome.zip"
  run "unzip font-awesome.zip && rm font-awesome.zip"
  run "cp font-awesome/css/font-awesome.css vendor/assets/stylesheets/"
  run "cp -r font-awesome/font public/font"
  run "rm -rf font-awesome"
  run "echo '@import \"font-awesome\";' >>  app/assets/stylesheets/application.css.scss"
end


# Ignore rails doc files, Vim/Emacs swap files, .DS_Store, and more
# ===================================================
run "echo '/.bundle' >> .gitignore"
run "echo '/db/*.sqlite3' >> .gitignore"
run "echo '/db/*.sqlite3-journal' >> .gitignore"
run "echo '/log/*.log' >> .gitignore"
run "echo '/tmp' >> .gitignore"
run "echo 'database.yml' >> .gitignore"
run "echo 'doc/' >> .gitignore"
run "echo '*.swp' >> .gitignore"
run "echo '*~' >> .gitignore"
run "echo '.project' >> .gitignore"
run "echo '.idea' >> .gitignore"
run "echo '.secret' >> .gitignore"
run "echo '.DS_Store' >> .gitignore"


# Git: Initialize
# ==================================================
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

if yes?("Initialize GitHub repository?")
  git_uri = `git config remote.origin.url`.strip
  unless git_uri.size == 0
    say "Repository already exists:"
    say "#{git_uri}"
  else
    username = ask "What is your GitHub username?"
    run "curl -u #{username} -d '{\"name\":\"#{app_name}\"}' https://api.github.com/user/repos"
    git remote: %Q{ add origin git@github.com:#{username}/#{app_name}.git }
    git push: %Q{ origin master }
  end
end
