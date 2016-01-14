# mongovis
Simple web visualization tool for geospatial MongoDB collections

# Installation
Download the source code of the application ```git clone https://github.com/glampr/mongovis.git```.
You need to have ruby and bundler installed.
If RVM is installed, then a gemset will be automatically created when navigating to the downloaded folder (because of ```.ruby-version``` file).

Run ```bundle install``` to install all the necessary libraries, then run ```rackup -p 4567``` to start the server.
Go to ```http://localhost:4567``` to use the application.
