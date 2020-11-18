//===POLICY DOCUMENTS===

//Policy to assume a role
data "aws_iam_policy_document" "api_to_sqs_assume_role" {
    policy_id = "assumePolicyApi"
    statement {
        sid = ""
        effect = "Allow"
        actions = [
            "sts:AssumeRole"
        ]
        principals {
            type = "Service"
            identifiers = [
                "apigateway.amazonaws.com"
            ]
        }
    }
}

//Send messages to Queue
data "aws_iam_policy_document" "sqs1_policy_document" {
    policy_id = "sqspolicy"
    statement {
        sid = "FirstSqsPolicy"
        effect = "Allow"
        actions = [
            "sqs:SendMessage"
        ]
        resources = [
            aws_sqs_queue.first_sqs_queue.arn
        ]
    }
}
//======

//Create a role
resource "aws_iam_role" "api_role" {
    name = "apiRole"
    assume_role_policy = data.aws_iam_policy_document.api_to_sqs_assume_role.json
}

//Create a policy
resource "aws_iam_policy" "api_policy" {
    name = "apiPermissions"
    policy = data.aws_iam_policy_document.sqs1_policy_document.json
}

//Attach the policy to the role
resource "aws_iam_policy_attachment" "api_attachment" {
    name = "apiPolicyAttachment"
    roles = [
        aws_iam_role.api_role.name 
    ]
    policy_arn = aws_iam_policy.api_policy.arn
}