package metaRabbitMQAdapter

import ("github.com/streadway/amqp"

        "log"
        "fmt"
        "strconv")


type Config struct {
    Host string
    Port int

    Exchange string
    Queue string
    Routing_key string

    User string
    Password string
}

var RabbitConf Config

// callback for panicing and error and log reason if error occures
func failOnError(err error, msg string) {
  if err != nil {
    log.Fatalf("%s: %s", msg, err)
    panic(fmt.Sprintf("%s: %s", msg, err))
  }
}

// creates an connection to RabbitMQ server with given name
// handles error when occures
func CreateConnection(conf Config) (*amqp.Connection) {
    port_as_string := strconv.Itoa(conf.Port)
    host := "amqp://" + conf.User + ":" + conf.Password + "@" + conf.Host + ":" + port_as_string + "/"

    conn, err := amqp.Dial(host)
    failOnError(err, "metaRabbitMQAdapter::: Could not connect to RabbitMQ")

    return conn
}

// creates an channel binded to the given connection
// handles error when occures
func CreateChannel(conn *amqp.Connection) (*amqp.Channel) {
    ch, err := conn.Channel()
    failOnError(err, "metaRabbitMQAdapter::: Failed to open a channel")

    return ch
}

// creates a new Config with default vaules
// please use for convinience and safty
func NewConfig() Config {
    conf := Config{Host: "localhost",
                   Port: 5672,
                   User: "guest",
                   Password: "guest"}
    return conf
}


//  convinience method for setting up an channel
func Setup(conf Config) (*amqp.Channel) {
    RabbitConf = conf

    conn := CreateConnection(RabbitConf)
    ch := CreateChannel(conn)

    return ch
}
