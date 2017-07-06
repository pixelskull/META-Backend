package metaRabbitMQAdapter

import ("github.com/streadway/amqp"

        "log"
        "fmt")


type Config struct {
    host string
    port string

    exchange string
    queue string
    routing_key string

    user string
    password string
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
    host := "amqp://" + conf.user + ":" + conf.password + "@" + conf.host + ":" + conf.port + "/"

    conn, err := amqp.Dial(host) //TODO hier muss noch der richtige Host eingetragen werden
    failOnError(err, "metaRabbitMQAdapter::: Could not connect to RabbitMQ")
    defer conn.Close()

    return conn
}

// creates an channel binded to the given connection
// handles error when occures
func CreateChannel(conn *amqp.Connection) (*amqp.Channel) {
    ch, err := conn.Channel()
    failOnError(err, "metaRabbitMQAdapter::: Failed to open a channel")
    defer ch.Close()

    return ch
}

// creates a new Config with default vaules
// please use for convinience and safty
func NewConfig() Config {
    conf := Config{host: "localhost",
                   port:"5672",
                   user: "guest",
                   password: "guest"}
    return conf
}


//  convinience method for setting up an channel
func Setup(conf Config) (*amqp.Channel) {
    RabbitConf = conf

    conn := CreateConnection(RabbitConf)
    ch := CreateChannel(conn)

    return ch
}
