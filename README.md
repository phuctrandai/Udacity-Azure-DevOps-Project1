# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository
2. Create your infrastructure as code
3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
**Your words here**
To use the code in this project, follow the steps below:

1. Build the Machine Image with Packer.

  * Open Windows PowerShell and navigate to the packer directory:
    - `cd packer`
  * Review the packer.json file and add any additional information if needed.
  * Run the following command to build the image:
    - `packer build template.json`

2. Deploy the infrastructure with Terraform.

  * Navigate to terraform directory:
    - `cd terraform`
  * Modify the variables.tf file to customize the variables as needed.
  * Run the following command to plan the infrastructure.
    - `terraform plan --out solution.plan`
  * Run the following command to apply the changes and create the infrastructure.
    - `terraform apply "solution.plan"`

3. Customization.

To customize this project for your specific use case, follow the steps below:
  * Open the variables.tf file in the terraform directory.
  * Modify the variables according to your requirements.

### Output
**Your words here**
After successfully running the Packer and Terraform templates, you can expect the following output:

1. Packer:
  * A custom machine image will be built based on the provided template.
  * The image will be uploaded to the Azure Image.

2. Terraform:
  * Infrastructure resources will be provisioned, including:
    - Availability set
    - Virtual machine(s)
    - Disk(s)
    - Load balancer
    - Virtual network
    - Network security group
    - Network Interface(s)
    - Public IP address

3. Verification:

You can verify the successful deployment by accessing the Azure portal and review the resources.