<h1>Building the Docker Image for the Weather React App</h1> 

***<h3>1. Clone the GitHub Repository</h3>***
I started by cloning my GitHub repository for the Weather React App onto my local virtual machine.
My repository link - https://github.com/Ryu7ken/celestaclima
```bash
git clone <github-repo-url>
cd <repo-folder>
```  

***<h3>2. Install NPM Dependencies</h3>***
After navigating to the project directory, I installed all the required dependencies using NPM.  
```bash
npm install
```  

***<h3>3. Create a Production Build of the React App</h3>***
To optimize the app for production, I built the project using the following command:  
```bash
npm run build
```  

***<h3>4. Build and Run the Docker Image</h3>***
I used the `Dockerfile` (present on the master branch) to containerize the React App and serve it via Nginx.

***<h3>Steps to Build the Docker Image:</h3>***
Run the following commands to build the Docker image and start the container:  
```bash
# Build the Docker image
docker build -t weather-react-app:latest .

# Run the Docker container
docker run -d -p 80:80 weather-react-app:latest
```  