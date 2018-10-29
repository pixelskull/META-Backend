package main

import (
	"./metaRabbitMQAdapter"

	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/xeipuuv/gojsonschema"
)

// JSONResponse is used for communication between clients and server
type JSONResponse struct {
	ID   string      `json:"id"`
	Data interface{} `json:"data"` 
}

// RabbitConf configures the RabbitMQ connection
var RabbitConf metarabbitmqadapter.Config

// function for publishing to rabbitMQ
func rabbitMQPulish(conf metarabbitmqadapter.Config,
	msg string) {

	log.Println("publish:: conf setup")
	// setup connection and channel
	conn := metarabbitmqadapter.CreateConnection(conf)
	defer conn.Close()
	ch := metarabbitmqadapter.CreateChannel(conn)
	defer ch.Close()

	log.Println("publish:: channel setup")

	// publish some message
	metarabbitmqadapter.Publish(ch, conf, msg)

	log.Println("publish:: message published")
}

// wrapper for rabbitMQPulish (convinience)
func publishJSONToMessageQueueAndSubscribe(contents []byte, w http.ResponseWriter) {
	// decode json to get data
	jres := &JSONResponse{}
	err := json.Unmarshal([]byte(string(contents)), &jres)

	if err != nil {
		log.Println("metaIRFileuploadServer:: could not create json " + err.Error())
		recover()
	}

	// set temp Configuration to adress this queue
	tempConfig := RabbitConf
	tempConfig.Queue = "meta.production." + jres.ID + "-work"

	rabbitMQPulish(tempConfig, string(contents))

	// TODO: test this...
	conn := metarabbitmqadapter.CreateConnection(RabbitConf)
	ch := metarabbitmqadapter.CreateChannel(conn)

	tempConfig.Queue = "meta.production." + jres.ID + "-result"

	callback := func(delivery metarabbitmqadapter.RabbitDelivery) {
		for d := range delivery {
			w.Write(d.Body)
		}
	}

	go metarabbitmqadapter.Subscribe(ch, tempConfig, callback)
}

// validates json and proves scheme for requests
func validateJSON(json string) (bool, error) {
	schema := "file://./util/request_schema.json"
	schemaLoader := gojsonschema.NewReferenceLoader(schema)
	contentLoader := gojsonschema.NewStringLoader(json)

	result, err := gojsonschema.Validate(schemaLoader, contentLoader)

	if result.Valid() && err == nil {
		return true, err
	}
	return false, err
}

func handleRequest(w http.ResponseWriter, r *http.Request) {
	switch r.Method {

	case http.MethodPost:
		log.Println("POST Called")
		contents, err := ioutil.ReadAll(r.Body)

		if err != nil {
			fmt.Fprintln(w, "404 -> "+err.Error())
			recover()
		}

		// validating json data + error handling
		valid, err := validateJSON(string(contents))
		if !valid || err != nil {
			fmt.Fprintln(w, "JSON send was not valid -> "+err.Error())
			recover()
		}

		// sending json to message-queue
		go publishJSONToMessageQueueAndSubscribe(contents, w)

		break
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
		w.Write([]byte("405 - Method not allowed!"))
	}
}

// Handler Method for uploaded files
func dataUploadHandler(w http.ResponseWriter, r *http.Request) {
	log.Println(r.Method)
	// handle Request in go Routine
	go handleRequest(w, r)
}

func loadRabbitMQConf() metarabbitmqadapter.Config {
	// reading config file
	file, err := os.Open("rabbitMQ_conf.json")
	if err != nil {
		log.Println("metaIRFileuploadServer:: could not load rabbitMQ_conf.json: " + err.Error())
		recover()
	}

	// preparing JSON Decoder
	dec := json.NewDecoder(file)
	configuration := metarabbitmqadapter.Config{}

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
	// path := metafilehandler.PrepareTempFolder()
	// fmt.Println(path)
	// defer os.RemoveAll(path)

	http.HandleFunc("/", dataUploadHandler)
	err := http.ListenAndServe(":80", nil)
	if err != nil {
		log.Fatal("Listen and server: ", err.Error())
	}

}
