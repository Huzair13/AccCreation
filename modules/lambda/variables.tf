variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "MyEnrollLambda"
}

variable "source_path" {
  description = "Path to lambda_function.py"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 60
}

variable "memory_size" {
  description = "Lambda memory in MB"
  type        = number
  default     = 256
}
