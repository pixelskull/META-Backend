package metaRabbitMQAdapter

import ("github.com/streadway/amqp")


// message for publishing to RabbitMQ
// takes channel, exchange name, queue name and body
// handles error when occures
func Publish(ch *amqp.Channel,
             conf Config,
             body string) {

    _, err := ch.QueueDeclare(conf.Queue,     // queue name
                              false,          // durable
                              false,          // delete when used
                              false,          // exclusive
                              false,          // no wait
                              nil)            // arguments

    failOnError(err, "metaRabbitMQAdapter::: Failed to declare Queue")

    err = ch.Publish(conf.Exchange,             // exchange name
                     conf.Routing_key,          // routing key
                     false,                     // mandatory
                     false,                     // imediate
                     amqp.Publishing {
                       ContentType: "text/plain",
                       Body:        []byte(body),
                     })

    failOnError(err, "metaRabbitMQAdapter::: Failed to publish a message")
}
