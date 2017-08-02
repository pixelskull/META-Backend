
### Softwarepackages to install

`pip install pika`


### Config Format

**rabbitMQ_conf.json**
```
{
  Host -> Hostname or IP to RabbitMQ
  Port -> Port definition used by your RabbitMQ instance

  Exchange -> Exchange Point (must be used for in and out)
  Read_queue -> RabbitMQ queue for input

  Write_queue -> RabbitMQ queue for output
  Routing_key -> routing key for exchange to handle output

  User -> RabbitMQ user name
  Password -> Password for given RabbitMQ user
}
```
