---
layout: post
title: Creating an easy to update personal website
---

This post will go over how to setup a personal website that's really easy to update
and see your changes. The end goal here is being able to make a change on a GitHub
repository that's automatically reflected live on a [test/staging page](staging.nathangrubb.io), then if that
looks good being able to merge that to the [real page](nathangrubb.io).

## Why do this?

Initially I just setup a simple resume type website. It was primarily just for fun so I just spun up an EC2
machine, installed nginx and pointed it to a static page that was configured on that box. When I wanted to make
changes, I'd have to SSH to that box and manually make the changes and then view them live. Obviously this isn't
good practice for a production website, but the risk for making a bad change wasn't that serious since it's not
like my page is actually used for anything productive, after all it was just fo fun.

However, over time this became kind of a hassle as I wanted to make little tweaks. I'd have to remember where
I put that SSH key, remember what the username was for that box and then remember the path to where I put the
static content. What started as fun, quickly just became annoying and I also wanted to host similar type pages
for my wife and also a friend so the nginx configuration grew in complexity. In my head, I thought wouldn't it
be nice if I could just modify something on git and see it live?


## Step 1: Containerize your website

- I will write another article on how to do this, but the just of this is when you are done with this step
you should be able to easily host your website locally with two commands:
  - Build your container: `docker build -t website .`
  - Run your container: `docker run -t website -p 8080:80`
- Visit http://localhost:8080 in your browser and this works then you have finished this step.


## Step 2: Publish on GitHub

- Put everything on from Step 1 in a Git repository and push to GitHub.


## Step 3: Register with Docker Hub

- Create a free account on https://hub.docker.com.
- Create a repository on Docker Hub.
- Under Build Settings, connect your GitHub account and chose the repository your made from Step 2.
- Create two build rules both based on branches. One for "master" and another for "staging". You can make the Source and Dokcer Tag the same.
- Now every time you make changes to either of those branches in GitHub, DockerHub will attempt to build a new container. It will take a while for Docker Hub to do this, but when it's done you should be able to run something like `docker run -p 8080:80 <docker_account_name>/<docker_repository_name>:<tag>` (i.e. `docker run -p 8080:80 silentsnowman/resume-website:staging`) locally and visit http://localhost:8080 to see your website.


## Step 4: Getting a Domain Name

The very first thing you need for this is to buy a domain name. You only need to buy one domain as you
can use a sub domain for the staging environment. I purchased this through Route 53 on AWS.


## Step 5: Setting Up A Web Server

As you'll later find out this is a little bit more than a web server, but rather more a docker container host.
For this setup, I decided on using AWS EC2 with the latest version of Ubuntu. At the end of this setup we will
have nginx running on the host machine which will proxy the request to either our production container or our
staging container.

- Create a Ubuntu 18.04 EC2 Machine on AWS.
- Run the following to install nginx, docker:
```
# Install Nginx
sudo apt install nginx
# Install Docker
sudo apt install docker.io
```
- Configure nginx:
```
# TODO: Write this
# Reload nginx configuration
nginx -s reload
```
- Run two docker containers
  - `docker run -d -p 8000:80 <docker_account_name>/<docker_repository_name>:<tag>` (i.e. `docker run -p 8000:80 silentsnowman/resume-website:staging`)
  - `docker run -d -p 8000:80 <docker_account_name>/<docker_repository_name>:<tag>` (i.e. `docker run -p 9000:80 silentsnowman/resume-website:production`)
- Create a watchtower container (this will keep your other two containers above up to date)
  - `docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower`
- You probably want to consider telling Docker to start all these containers on boot or restart when they crash. See https://docs.docker.com/config/containers/start-containers-automatically/ for more details.


## Step 4: Configure your Domain Name

Now that you have a server and a domain, you need to configure your domain to map to your server.
Since I purchased my domain through Route 53 on AWS, I also configured it there.

- Create a "A" record with the name of your domain (i.e. nathangrubb.io) and with the value
of your EC2 machine's IPv4 address (i.e. 3.80.251.117)
- Create a "CNAME" record with the name of your domain with www. prepended (i.e. www.nathangrubb.io) and the
value without the www. prepended (i.e. nathangrubb.io). This will make your website work regardless of if
someone uses www. when visiting your site or chooses to exclude it.
- Repeat 1 & 2 for a staging subdomain (i.e. staging.nathangrubb.io).


## Step 5: Add Security with Certbot

- Run the following to install certbox:
```
# Add Certbot PPA
sudo apt update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt update
# Install Certbox
sudo apt install certbot python-certbot-nginx
```
- Run `certbot` on command line and follow instructions to create certs for your main domain and staging subdomain.

## Step 6: Visit your domain!
- Type <your_domain> and/or staging.<your_domain> in a browser! (You can also go to your GitHub repository on your staging branch and make changes. When you commit them, it'll be about an hour before they go live to your staging domain though).
