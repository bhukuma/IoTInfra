resource "random_string" "thing_suffix" {
  length  = 3
  lower   = true
  special = false
  numeric  = true
}

resource "aws_iot_thing" "esp32" {
  name = "thing-esp32-${random_string.thing_suffix.result}"

  attributes = {
    "environment" = "development"
    "version"     = "v1"
  }
}
# Output the IoT Thing name
output "iot_thing_name" {
  value = aws_iot_thing.esp32.name
  description = "The name of the IoT Thing"
}
