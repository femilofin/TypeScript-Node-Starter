# Setting up infrastructure on AWS using terraform
1. Follow steps to install the terraform CLI [here](https://www.terraform.io/intro/getting-started/install.html)

2. Open `dev/terraform.tfvars` and ensure the variables are what you want. You'd want to change the `domain` variable to one that already exists on your AWS account, the ``MONGODB_URI`` and the ``public_key`` to your own.

3. Create a bucket to store the state files
```sh
$ cd dev/state
$ terraform init
$ terraform apply
```

4. Do the following to create the infrastructure, ensure that you've configured your access and secret key in `~/.aws/credentials` before proceeding:
```sh
$ cd ..
$ terraform init
$ terraform apply
```
Note: Incase you get a message like the one below while applying, visit the URL in the message and accept terms to use AMIs in AWS Marketplace and run `terraform apply` again.
> StatusMessage: "In order to use this AWS Marketplace product you need to accept terms and subscribe. To do so please visit https://aws.amazon.com/marketplace/pp?sku=ryg425ue2hwnsok9ccfastg4. Launching EC2 instance failed."

5. Copy and save the access and secret key output, add it as a travis global variable.
