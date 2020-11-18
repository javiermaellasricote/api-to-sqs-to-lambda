variable "lambda_version" {
}

resource "aws_lambda_function" "lambda_1" {
    function_name = "lambda1"
    s3_bucket = "testing-lambda-functions-from-london2"
    s3_key = "testingTf/v${var.lambda_version}/example.zip"

    handler = "index.handler"
    runtime = "nodejs10.x"

    role = aws_iam_role.lambda_role.arn
}