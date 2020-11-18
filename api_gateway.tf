//providers
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = "eu-west-1"
}

//Create API Gateway
resource "aws_api_gateway_rest_api" "api_1" {
    name = "API1"
    description = "API 1"
}

//***API Resource to SQS***//

//Create resource
resource "aws_api_gateway_resource" "send_to_queue_resource" {
    rest_api_id = aws_api_gateway_rest_api.api_1.id
    parent_id = aws_api_gateway_rest_api.api_1.root_resource_id
    path_part = "sqs"
}

//Create method for the resource
resource "aws_api_gateway_method" "send_to_queue_method" {
    rest_api_id = aws_api_gateway_resource.send_to_queue_resource.rest_api_id
    resource_id = aws_api_gateway_resource.send_to_queue_resource.id
    http_method = "ANY"
    authorization = "NONE"
}

//Create integration between the resource and the SQS
resource "aws_api_gateway_integration" "send_to_queue" {
    rest_api_id = aws_api_gateway_method.send_to_queue_method.rest_api_id
    resource_id = aws_api_gateway_method.send_to_queue_method.resource_id
    http_method = aws_api_gateway_method.send_to_queue_method.http_method

    type = "AWS"
    uri = "arn:aws:apigateway:eu-west-1:sqs:path/${aws_sqs_queue.first_sqs_queue.name}"
    credentials = aws_iam_role.api_role.arn
    integration_http_method = "POST"
    //passthrough_behavior = "WHEN_NO_MATCH"

    //request_parameters = {
    //  "integration.request.header.Content-Type" = "'application/json'"
    //}

    //request_templates = {
    //  "application/json" = "Action=SendMessage&MessageBody=$input.body"
    //}
}

//Response resource from SQS
resource "aws_api_gateway_integration_response" "queue_response" {
    rest_api_id = aws_api_gateway_method.send_to_queue_method.rest_api_id
    resource_id = aws_api_gateway_method.send_to_queue_method.resource_id
    http_method = aws_api_gateway_method.send_to_queue_method.http_method
    selection_pattern = "^2[0-9][0-9]"
    status_code = 200

    //response_templates = {
    //  "application/json" = "{\"message\": \"Great success\"}"
    //}

    depends_on = [
      aws_api_gateway_integration.send_to_queue
    ]
}

//Response method from SQS
resource "aws_api_gateway_method_response" "api_response" {
    rest_api_id = aws_api_gateway_integration_response.queue_response.rest_api_id
    resource_id = aws_api_gateway_integration_response.queue_response.resource_id
    http_method = aws_api_gateway_integration_response.queue_response.http_method
    status_code = aws_api_gateway_integration_response.queue_response.status_code

    //response_models = {
    //  "application/json" = "Empty"
    //}
}
//******

//Deployment of the API
resource "aws_api_gateway_deployment" "api_deployment" {
    depends_on = [
        aws_api_gateway_integration.send_to_queue
    ]
    rest_api_id = aws_api_gateway_rest_api.api_1.id
    stage_name = "deployment1"
}

output "base_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}
