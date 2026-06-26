# DevOps CI/CD Lifecycle Demo

A small, fully working project built to demonstrate the **complete DevOps lifecycle** end to end:
Plan -> Code -> Build -> Test -> Release -> Deploy -> Operate -> Monitor.

Stack: **GitHub + Jenkins + Maven + JUnit + Docker + Terraform + AWS EC2**

---

## 1. What this project actually is

A tiny Spring Boot REST app (two endpoints) that gets:
1. Built and unit tested by Maven
2. Packaged into a Docker image
3. Pushed to Docker Hub
4. Deployed onto an AWS EC2 instance that Terraform provisions
5. Verified by hitting the public IP in a browser

The app itself is intentionally simple. The point of the demo is the **pipeline**, not the app.

---

## 2. Architecture

```
 Developer                Jenkins (controller + remote Ubuntu agent)
     |                              |
     | git push                    |
     v                              v
 GitHub repo  ----webhook---->  Checkout -> Build (Maven) -> Test (JUnit)
                                       |
                                       v
                              Docker build & tag
                                       |
                                       v
                         Push image -> Docker Hub (Release)
                                       |
                                       v
                          SSH deploy -> AWS EC2 (Deploy)
                                       |
                                       v
                     App running on port 80 (Operate)
                                       |
                                       v
                     CloudWatch / docker logs (Monitor)
```

Terraform provisions the EC2 instance, security group (ports 22 and 80), and installs Docker
via a `user_data` script at boot. Jenkins handles everything from checkout to deployment.

---

## 3. Lifecycle stage to tool mapping (for your slides)

| Stage   | What happens                          | Tool                  |
|---------|----------------------------------------|------------------------|
| Plan    | Track work, requirements               | GitHub Issues          |
| Code    | Write and version the app              | Git + GitHub           |
| Build   | Compile, resolve dependencies          | Maven                  |
| Test    | Run unit tests automatically           | JUnit (via Maven)      |
| Release | Package as image, version it           | Docker, Docker Hub     |
| Deploy  | Provision infra, ship the container    | Terraform, AWS EC2     |
| Operate | Keep the app running                   | Docker on EC2          |
| Monitor | Watch logs/health, feed back to Plan   | CloudWatch / docker logs |

---

## 4. Repo structure

```
devops-cicd-demo/
├── app/                  Spring Boot app (Maven project)
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/
├── terraform/            AWS infra as code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── user_data.sh
├── Jenkinsfile           The pipeline itself
└── README.md
```

---

## 5. Setup steps

### a) Provision the AWS infrastructure (Terraform)

```bash
cd terraform
terraform init
terraform plan -var="key_pair_name=YOUR_AWS_KEY_PAIR_NAME"
terraform apply -var="key_pair_name=YOUR_AWS_KEY_PAIR_NAME"
```

This creates the EC2 instance and prints its public IP as `instance_public_ip`. Note it down,
you'll need it for Jenkins.

> Use an AWS free tier account and `t2.micro` (already the default) so this costs nothing for a demo.

### b) Jenkins setup

1. Push this repo to your own GitHub.
2. In Jenkins, create a new **Pipeline** job pointing at your repo, "Pipeline script from SCM" using the included `Jenkinsfile`.
3. Add these credentials in Jenkins (Manage Jenkins -> Credentials):
   - `dockerhub-creds` — Username/password type, your Docker Hub login
   - `ec2-host` — Secret text, the EC2 public IP from Terraform's output
   - `ec2-ssh-key` — SSH private key matching the key pair used in Terraform
4. Edit `IMAGE_NAME` in the `Jenkinsfile` to use your own Docker Hub username.
5. Run the pipeline.

### c) Verify the demo

Once the pipeline finishes, open `http://<EC2_PUBLIC_IP>` in a browser. You should see:

```
DevOps CI/CD Demo is live! Deployed via Jenkins + Docker + Terraform on AWS EC2.
```

And `http://<EC2_PUBLIC_IP>/version` shows the build timestamp, proof of which build is running.

---

## 6. How to present this (suggested flow)

1. **Show the lifecycle diagram first** — name all 8 stages before touching the terminal.
2. **Make a small code change** (e.g. edit the message in `App.java`) and `git push`.
3. **Switch to Jenkins** and trigger/show the pipeline running stage by stage live.
4. **Point out the JUnit test stage** — explain that a failing test would stop the pipeline (this is the "quality gate" talking point).
5. **Show the Docker Hub page** with the new image tag that was just pushed.
6. **Refresh the browser** on the EC2 public IP — show the updated message, with the `/version` timestamp proving it's a fresh deploy.
7. **Close with the lifecycle diagram again**, now pointing at Operate/Monitor and explaining the feedback loop back to Plan.

This "change -> push -> pipeline -> live in under 2 minutes" moment is the strongest part of the demo. Rehearse it once before presenting.

---

## 7. Cheat sheet

- `terraform destroy` — tear down the EC2 instance when you're done (avoid leaving it running)
- `docker ps` on the EC2 box — confirm the container is running
- `docker logs devops-demo` — quick way to show "Monitor" live during Q&A
- If the pipeline fails on `docker push`, check `dockerhub-creds` is correct
- If `Deploy to EC2` hangs, the EC2 security group probably isn't allowing your Jenkins agent's IP on port 22

---

## 8. Possible extensions if you want to go further later

- Add a staging + production environment split in Terraform (workspaces)
- Add SonarQube as a code quality gate stage
- Replace manual EC2 deploy with ECS or EKS
- Add Prometheus + Grafana for real dashboards instead of raw logs
