package metaRabbitMQAdapter

import ("github.com/streadway/amqp"

        "log")

type callbackFunc func (<-chan amqp.Delivery)

func Subscribe(ch *amqp.Channel,
               exchange string,
               queue string,
               body string,
               callback callbackFunc) {

      msg, err := ch.Consume(queue,       // queue name
                             "",          // consumer
                             true,        // auto acknolage
                             false,       // exclusice
                             false,       // no local
                             false,       // no wait
                             nil)         // arguments


      failOnError(err, "metaRabbitMQAdapter::: Failed to register a consumer")

      forever := make(chan bool)

      go callback(msg)

      log.Printf("metaRabbitMQAdapter::: [*] Waiting for messages. To exit press CTRL+C")

      <- forever // wait forever or until goroutine finished (never happen)
}
