//Create SQS queue
resource "aws_sqs_queue" "first_sqs_queue" {
  name                      = "my-sqs-queue"
  delay_seconds             = 0              // how long to delay delivery of records
  max_message_size          = 262144         // = 256KiB, which is the limit set by AWS
  message_retention_seconds = 86400          // = 1 day in seconds
  receive_wait_time_seconds = 10             // how long to wait for a record to stream in when ReceiveMessage is called
}

//Connect SQS with lambda function
resource "aws_lambda_event_source_mapping" "first_event_source_mapping" {
    event_source_arn = aws_sqs_queue.first_sqs_queue.arn
    function_name = aws_lambda_function.lambda_1.arn
    enabled = true
    batch_size = 1
}