# Corona-test



### Run the app on Ubuntu using the Docker file

- Clone the GitHub repository into a newly created directory using the command:
```
git clone git@github.com:annaschoeps/Corona-test.git
```

- Build an image from a Dockerfile (-t = tag, . = current directory):
```
sudo docker build -t annaschoeps/corona .
```
Note: Building the image can 


- Run the docker with:
```
sudo docker run -p 80:3838 annaschoeps/corona
```
