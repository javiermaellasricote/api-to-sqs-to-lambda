//===POLICY DOCUMENTS===

//Policy to assume a role
data "aws_iam_policy_document" "lambda_to_assume_role" {
    policy_id = "assumePolicyLambda"
    statement {
        sid = ""
        effect = "Allow"
        actions = [
            "sts:AssumeRole"
        ]
        principals {
            type = "Service"
            identifiers = [
                "lambda.amazonaws.com"
            ]
        }
    }
}

//Receive messages from Queue
data "aws_iam_policy_document" "sqs_to_lambda_policy" {
    policy_id = "sqsToLambdaPolicy"
    statement {
        sid = "SqsToLambdaPolicy"
        effect = "Allow"
        actions = [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
        ]
        resources = [
            aws_sqs_queue.first_sqs_queue.arn
        ]
    }
}
//======

//Create a role
resource "aws_iam_role" "lambda_role" {
    name = "lambdaRole"
    assume_role_policy = data.aws_iam_policy_document.lambda_to_assume_role.json
}

//Create a policy
resource "aws_iam_policy" "lambda_policy" {
    name = "lambdaPermissions"
    policy = data.aws_iam_policy_document.sqs_to_lambda_policy.json
}

//Attach the policy to the role
resource "aws_iam_policy_attachment" "lambda_attachment" {
    name = "lambdaPolicyAttachment"
    roles = [
        aws_iam_role.lambda_role.name 
    ]
    policy_arn = aws_iam_policy.lambda_policy.arn
}