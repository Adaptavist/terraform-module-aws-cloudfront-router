package test

import (
	"io/ioutil"
	"math/rand"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var seededRand = rand.New(rand.NewSource(time.Now().UnixNano()))
var assumeRoleArn = os.Getenv("SANDBOX_ORG_ROLE_ARN")

func RandomString(length int) string {
	charset := "abcdefghijklmnopqrstuvwxyz"
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[seededRand.Intn(len(charset))]
	}
	return string(b)
}

// TestModule - Our test entry point
func TestModule(t *testing.T) {

	postfix := RandomString(8)

	// Terraforming
	terraformOptions := &terraform.Options{
		NoColor: true,
		Lock:    true,
		BackendConfig: map[string]interface{}{
			"key":      "modules/module-aws-cloudfront-router/tests/fixures/default/" + postfix,
			"role_arn": assumeRoleArn,
		},
		TerraformDir: "fixture",
	}
	// setup TF stack
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	outputs := terraform.OutputAll(t, terraformOptions)

	// assert outputs are wired
	assert.NotNil(t, outputs["cf_id"])
	assert.NotNil(t, outputs["cf_arn"])
	assert.NotNil(t, outputs["cf_status"])
	assert.NotNil(t, outputs["cf_domain_name"])
	assert.NotNil(t, outputs["cf_etag"])
	assert.NotNil(t, outputs["cf_hosted_zone_id"])
	assert.NotNil(t, outputs["public_domain_name"])

	publicDomainName := outputs["public_domain_name"].(string)

	// Hit root and origins, confirm HTML returned belongs to correct domain.
	testBody("<title>ScriptRunner", "https://"+publicDomainName, t)
	testBody("sr-logo.png", "https://"+publicDomainName+"/public/js/manifest.json", t)
	testBody("\"baseUrl\":\"https://scriptrunner.connect.adaptavist.com\"", "http://"+publicDomainName+"/sr-dispatcher/jira/atlassian-connect.json", t)
}

func testBody(testValue string, url string, t *testing.T) {

	resp, err := http.Get(url)

	assert.Nil(t, err, "There should not have been an error getting the url "+url)
	assert.Equal(t, resp.Status, "200 OK", "There should have been a HTTP 200 getting the url "+url)

	bodyBytes, err := ioutil.ReadAll(resp.Body)

	assert.Nil(t, err, "There should not of been an error reading response body")

	bodyString := string(bodyBytes)
	assert.True(t, strings.Contains(bodyString, testValue), url+" should contain the value "+testValue)
}
