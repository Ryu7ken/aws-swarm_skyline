<h1>AWS Cloud Project Overview</h1>

***<h3>1. VPC Creation:</h3>***
I designed a Virtual Private Cloud (VPC) with 2 public subnets and 2 private subnets across 2 Availability Zones (AZs). This setup ensures high availability and fault tolerance by distributing resources across multiple AZs, minimizing the risk of downtime due to failures in a single AZ. Additionally, a NAT Gateway was provisioned in each AZ to enable outbound internet access for resources in private subnets. Having a NAT Gateway in each AZ ensures uninterrupted connectivity even if one AZ experiences issues.

***<h3>2. Launch Template for Auto Scaling Group:</h3>***
To streamline instance creation, I created a Launch Template that defines the configurations required for EC2 instances, such as instance type, AMI, security groups, and key pairs.

***<h3>3. Auto Scaling Group (ASG):</h3>***
An Auto Scaling Group (ASG) was configured to maintain between 1 and 4 EC2 instances, with a desired count of 2. These instances were deployed exclusively in the private subnets to enhance security by isolating them from direct internet access, which is essential for sensitive workloads.

***<h3>4. Bastion Host:</h3>***
To securely manage EC2 instances in private subnets, I deployed a Bastion Host in one of the public subnets. The Bastion Host serves as the sole entry point for SSH access, ensuring controlled and secure administrative access to private resources.

![Bastion Host and Private EC2 Instances](/assets/images/ec2-instances.png)

***<h3>5. Target Groups and Load Balancer:</h3>***
I created Target Groups to group the EC2 instances from private subnets, enabling them to be used behind an Application Load Balancer (ALB). The ALB distributes incoming traffic efficiently, ensuring seamless access to hosted applications.

***<h3>6. Docker Setup and Deployment:</h3>***
Using the Bastion Host, I SSH-ed into the private EC2 instances to install Docker. I then initialized a Docker Swarm with one instance as the Manager Node and the other as a Worker Node. Afterward, I deployed a Docker service with 2 replicas to host my weather React app. The container image was pulled from my Docker Hub repository.

![List of Swarm Nodes, Services and Container](/assets/images/docker-swarm-details.png)

***<h3>7. Accessing the Application:</h3>***
The React-based weather application was accessible via the DNS of the Application Load Balancer, providing a highly available and secure endpoint for users.

![Weather React Application](/assets/images/weather-react-app.png)


***<h3>This project showcases a robust, scalable, and secure AWS infrastructure for hosting containerized applications with fault-tolerant and high-availability considerations.</h3>***