package main

import ("./metaRabbitMQAdapter"

        "os"
        "log"
        "fmt"
        "net/http"
        "io/ioutil"
        "encoding/json"

        "github.com/xeipuuv/gojsonschema")


var RabbitConf metaRabbitMQAdapter.Config

// function for publishing to rabbitMQ
func rabbitMQPulish(conf metaRabbitMQAdapter.Config,
									  msg string) {

	log.Println("publish:: conf setup")
	// setup connection and channel
	conn := metaRabbitMQAdapter.CreateConnection(conf)
	defer conn.Close()
	ch := metaRabbitMQAdapter.CreateChannel(conn)
	defer ch.Close()

	log.Println("publish:: channel setup")

	// publish some message
	metaRabbitMQAdapter.Publish(ch, conf, msg)

	log.Println("publish:: message published")
}

// wrapper for rabbitMQPulish (convinience)
func publishJSONToMessageQueue(json string) {
  rabbitMQPulish(RabbitConf, json)
}

// validates json and proves scheme for requests
func validateJSON(json string) (bool, error) {
  schema        := "file://./util/request_schema.json"
  schemaLoader  := gojsonschema.NewReferenceLoader(schema)
  contentLoader := gojsonschema.NewStringLoader(json)

  result, err := gojsonschema.Validate(schemaLoader, contentLoader)

  if result.Valid() && err == nil {
    return true, err
  } else {
    return false, err
  }

}

// Handler Method for uploaded files
func fileuploadHandler(w http.ResponseWriter, r *http.Request) {
	log.Println(r.Method)
	switch r.Method {

	case http.MethodPost:
		log.Println("POST Called")
		contents, err := ioutil.ReadAll(r.Body)

		if err != nil {
			fmt.Fprintln(w, "404 -> " + err.Error())
			recover()
		}

    // validating json data + error handling
    valid, err := validateJSON(string(contents))
    if !valid || err != nil {
      fmt.Fprintln(w, "JSON send was not valid -> " + err.Error())
      recover()
    }

		// sending json to message-queue
		go publishJSONToMessageQueue(string(contents))
		break
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
		w.Write([]byte("405 - Method not allowed!"))
	}
}


func loadRabbitMQConf() metaRabbitMQAdapter.Config {
	// reading config file
	file, err := os.Open("rabbitMQ_conf.json")
	if err != nil {
		log.Println("metaIRFileuploadServer:: could not load rabbitMQ_conf.json: " + err.Error())
		recover()
	}

	// preparing JSON Decoder
	dec := json.NewDecoder(file)
	configuration := metaRabbitMQAdapter.Config{}

	// decode JSON
	err = dec.Decode(&configuration)
	if err != nil {
		log.Println("metaIRFileuploadServer:: could not decode rabbitMQ_conf.json: " + err.Error())
		recover()
	}

	// return configuration struct
	return configuration
}


func main() {
	RabbitConf = loadRabbitMQConf()

  // TODO: read tempfile if needed
	// path := metaFilehandler.PrepareTempFolder()
	// fmt.Println(path)
	// defer os.RemoveAll(path)

	http.HandleFunc("/taskdata", fileuploadHandler)
	err := http.ListenAndServe(":4242", nil)
	if err != nil {
		log.Fatal("Listen and server: ", err.Error())
	}

}