# Corona-test

This Shiny app uses data from the European Centre for Disease Prevention and Control to visualize the number of confirmed cases of SARS-CoV-2 worldwide.



### Run the app

The Corona app is implemented in R using the Shiny Server web application framework. You will need R and Shiny Server installed to run the app.

Follow the steps below to run the app on Ubuntu using the Docker file:

- Run the docker using the command:
```
sudo docker run -p 80:3838 annaschoeps/corona
```



To build an image from the Dockerfile first (if necessary), use the following commands:

- Clone the GitHub repository into a newly created directory using the command:
```
git clone git@github.com:annaschoeps/Corona-test.git
```

- Build an image from a Dockerfile (-t = tag, . = current directory):
```
sudo docker build -t annaschoeps/corona .
```
Note: Building the image can take a few minutes.
