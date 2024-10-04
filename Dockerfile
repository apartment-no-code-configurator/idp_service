# Use the official Ruby base image
FROM ruby:3.1.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  nodejs \
  default-mysql-client \
  default-libmysqlclient-dev \
  vim

# Set the working directory inside the container
WORKDIR /root/app/idp_service

# Copy the Gemfile and Gemfile.lock to the container
COPY Gemfile /root/app/idp_service/Gemfile
COPY Gemfile.lock /root/app/idp_service/Gemfile.lock

# Install gems using bundler
RUN bundle install

# Copy the rest of the application code to the container
COPY . /root/app/idp_service

# Precompile Rails assets if you are using Rails assets (optional)
# RUN RAILS_ENV=production bundle exec rake assets:precompile

# Expose the port that the Rails app will run on (each service will run on different ports)
EXPOSE 3002

# The command to start the Rails server
CMD ["git", "config", "--global", "user.email", "'apartixtechnologies@gmail.com'"]
CMD ["git", "config", "--global", "user.name", "Apartix"]
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3002"]
# CMD ["bash"]
