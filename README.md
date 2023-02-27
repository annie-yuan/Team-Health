# TeamHealth

Welcome to the installation guide for the TeamHealth app, created by Team 14 
for MSCI 342! This guide will show you how to get set up on both a local 
development environment, and how to deploy this app to a production environment 
in Heroku.

## Assumptions
This guide assumes that you have Ruby, Rails, and PostgreSQL installed on your target machine. 
If deploying on Heroku, it assumes that you already have a Github and Heroku account set up.

## Setting up a Development Environment 
1. Clone this repository to your machine
2. `cd` into the repository
3. Run `bundle install` to install all the required gems
4. Run `rails db:create db:migrate db:seed` to create & seed the DB
5. Congratulations! You have now initialized the application for local use. You can now 
boot the server using `rails server` and view the app. Default login for professor 
is msmucker@gmail.com/professor. Note that in Codio, the command may need to be 
altered to `rails server -b 0.0.0.0`.

## Deploying to Heroku
1. Email us to request to be added to the Github repository
2. When those permissions have been granted, login to the Heroku web portal
3. Select "New" in the top right corner, then select "Create New App"
4. Enter your desired app name and hosting location 
5. Select "Github" as your desired deployment method. If you do not see this option, go to 
the "Deploy" tab 
6. In "Connect to Github", select the "UWaterlooMSCI342" organization, and search 
for this repository's name ("TeamHealth")
7. When this repository is displayed, select the corresponding "Connect"
8. Scroll down to "Manual Deploy", select the `main` branch, and select "Deploy Branch"
9. When that is complete, scroll to the top right and select "More", then select "Run Console"
10. Run the command `rails db:migrate db:seed` to configure & seed the DB
11. Congratulations! You have now deployed the application to Heroku. Select "Open App" in the 
top right to view the deployed application. 
12. Default login for professor is msmucker@gmail.com/professor. Once logged in using the 
default credentials, use the change password functionality to modify the password to 
a secure one.

## Getting Started 
1. Change your password by going to Logout/Account -> Change Password 
2. Create a new team by going to Create Team -> New Team
3. Invite students to signup for the app by sending them the app's URL and applicable team code. 
Students will enter the team code during signup to assign them to the correct teams.
4. Invite TAs and professors to signup for the app by sending them the app's URL and applicable admin code.
Users will enter the admin code during signup so they are issued appropriate privileges. 
5. Access the help page by clicking 'Help' for more information!
