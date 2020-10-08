package test

import (
	"math/rand"
	"strconv"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UnixNano())

	randId := strconv.Itoa(rand.Intn(100000))
	attributes := []string{randId}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/complete",
		// Suppress errors if there is a problem computing outputs during destroy
		EnvVars:      map[string]string{"TF_WARN_OUTPUT_ERRORS": "1"},
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
		VarFiles: []string{"fixtures.us-east-2.tfvars"},
		Vars: map[string]interface{}{
			"attributes": attributes,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "172.16.0.0/16", vpcCidr)

	// Run `terraform output` to get the value of an output variable
	privateSubnetCidrs := terraform.OutputList(t, terraformOptions, "private_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	// assert.Equal(t, []string{"172.16.0.0/19", "172.16.32.0/19"}, privateSubnetCidrs)
	assert.Equal(t, []string{"172.16.0.0/19"}, privateSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	publicSubnetCidrs := terraform.OutputList(t, terraformOptions, "public_subnet_cidrs")
	// Verify we're getting back the outputs we expect
	// assert.Equal(t, []string{"172.16.96.0/19", "172.16.128.0/19"}, publicSubnetCidrs)
	assert.Equal(t, []string{"172.16.96.0/19"}, publicSubnetCidrs)

	// Run `terraform output` to get the value of an output variable
	domainHostname := terraform.Output(t, terraformOptions, "domain_hostname")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "es-cleanup.testing.cloudposse.co", domainHostname)

	// Run `terraform output` to get the value of an output variable
	kibanaHostname := terraform.Output(t, terraformOptions, "kibana_hostname")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, "kibana-es-cleanup.testing.cloudposse.co", kibanaHostname)

	// Run `terraform output` to get the value of an output variable
	domainEndpoint := terraform.Output(t, terraformOptions, "domain_endpoint")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, domainEndpoint, "vpc-eg-test-es-cleanup")
	assert.Contains(t, domainEndpoint, "us-east-2.es.amazonaws.com")

	// Run `terraform output` to get the value of an output variable
	lambdaFunctionArn := terraform.Output(t, terraformOptions, "lambda_function_arn")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, lambdaFunctionArn, "function:eg-test-elasticsearch-cleanup")
}
