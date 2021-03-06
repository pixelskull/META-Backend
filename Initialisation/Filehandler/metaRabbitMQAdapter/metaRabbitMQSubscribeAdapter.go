package metarabbitmqadapter

import (
	"github.com/streadway/amqp"

	"log"
)

// RabbitDelivery is a redeclaration for amqp.Delivery
type RabbitDelivery <-chan amqp.Delivery
type callbackFunc func(RabbitDelivery)

// Subscribe takes channel information, server config and callback function to subscribe you to the
// RabbitMQ channel
func Subscribe(ch *amqp.Channel,
	conf Config,
	callback callbackFunc) {

	msg, err := ch.Consume(conf.Queue, // queue name
		"",    // consumer
		true,  // auto acknolage
		false, // exclusice
		false, // no local
		false, // no wait
		nil)   // arguments

	failOnError(err, "metaRabbitMQAdapter::: Failed to register a consumer")

	forever := make(chan bool)

	go callback(msg)

	log.Printf("metaRabbitMQAdapter::: [*] Waiting for messages. To exit press CTRL+C")

	<-forever // wait forever or until goroutine finished (never happen)
}
