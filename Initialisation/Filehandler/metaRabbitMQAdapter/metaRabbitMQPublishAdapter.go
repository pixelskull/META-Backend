package metaRabbitMQAdapter

import ("github.com/streadway/amqp")


// message for publishing to RabbitMQ
// takes channel, exchange name, queue name and body
// handles error when occures
func Publish(ch *amqp.Channel,
             exchange string,
             queue string,
             routing_key string,
             body string) {

    q, err := ch.QueueDeclare(queue,     // queue name
                              false,     // durable
                              false,     // delete when used
                              false,     // exclusive
                              false,     // no wait
                              nil)       // arguments

    failOnError(err, "metaRabbitMQAdapter::: Failed to declare Queue")

    err = ch.Publish(exchange,       // exchange name
                     q.Name,         // routing key
                     false,          // mandatory
                     false,          // imediate
                     amqp.Publishing {
                       ContentType: "text/plain",
                       Body:        []byte(body),
                     })

    failOnError(err, "metaRabbitMQAdapter::: Failed to publish a message")
}
