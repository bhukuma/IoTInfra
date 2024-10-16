# Lab Monitoring System using IoT Device

# Objective:

1. This project aims to create a comprehensive monitoring system that tracks environmental conditions within a lab setting, ensuring a safe and optimal environment.
2. Using ESP32 IOT Device we will monitor parameters such as temperature, humidity, and air quality using IoT sensors connected to AWS IoT Core.
3. Data will be collected in real-time and can be accessed remotely.

# ESP32 IoT Device:

1. The ESP32 is a powerful, low-cost microcontroller with integrated Wi-Fi and Bluetooth capabilities, making it ideal for IoT applications. It supports various sensors and can connect to AWS IoT Core for real-time data transmission.
2. It has features like Dual-Core Processor, Built-in Wi-Fi and Bluetooth and Low Power Consumption.
3. The ESP32 can interface with a variety of sensors to monitor different environmental parameters crucial for lab conditions. Below are the sensors used in this project.
   - Temperature and Humidity Sensor
   - Air Quality Sensor
   - Light Sensor
<img width="1198" alt="image" src="https://github.com/user-attachments/assets/757c45cf-55ca-42c8-a566-4f67c5644d65">
   

# Technologies Used:

AWS Services:
* AWS IoT Core
* AWS Lambda
* Amazon S3
* Amazon SNS (for notifications)
  
Monitoring and Notification Tools:
* Redash
* Slack
  
Infrastructure as Code
* Github
* Github Actions
  
3rd Party Software tools:
* Ardunio

Hardware: 
IoT devices - ESP 32

Programming Languages: 
Python

# System Architecture and its Diagram

# ESP32 Data Collection:

  The ESP32 connects to Wi-Fi and collects data from various sensors (e.g., DHT22, MQ-135) and the collected data is formatted into JSON and sent to AWS IoT Core via MQTT.

# AWS IoT Core:

  Acts as the entry point for the ESP32, securely receiving data from the devices and triggers AWS Lambda functions to process incoming data.

# AWS Lambda:
  Processes the incoming data and formats it for storage and stores the processed data in an S3 bucket.

# AWS S3:

  Serves as the data lake, storing all incoming sensor data in a structured format (e.g., CSV, JSON). Enables easy access for downstream analytics.

# AWS Athena:

  Queries the data stored in S3, allowing  to run SQL queries against the data without needing a database and configured to create tables based on the data structure in S3.

# Redash Dashboards:

  Connects to AWS Athena to visualize the queried data and Dashboards display real-time data insights, trends, and alerts for lab conditions.

# Slack

  Based on the threasholds defined for each dashboard, alert will be notified via slack channel.
   
# Infrastructure Architecture Diagram
