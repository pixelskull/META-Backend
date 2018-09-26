package main

import (
	"./metaFilehandler"
	"./metaRabbitMQAdapter"

	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

// RabbitConf configuration for RabbitMQ
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

func publishIRToMessageQueue(hash string, irFile string) {
	// create map (key = hash | value = irFile)
	m := make(map[string]string)
	m["Id"] = hash
	m["Content"] = irFile
	// convert to json
	jsonData, err := json.Marshal(m)
	if err != nil {
		log.Println("metaIRFileuploadServer:: could not create json " + err.Error())
		recover()
	}
	log.Println("metaIRFileuploadServer:: publishing IR file with ID: " + hash)
	// send over message queue
	rabbitMQPulish(RabbitConf,
		string(jsonData))
}

// gets []byte and performs MD5 Hash (returns hash as string)
func createMD5(contents []byte) string {
	hash := md5.New()
	hash.Write(contents)
	sum := hash.Sum(nil)
	fmt.Println(hex.EncodeToString(sum))
	return hex.EncodeToString(sum)
}

func loadRabbitMQConf() metarabbitmqadapter.Config {
	// reading config file
	file, err := os.Open("./rabbitMQ_conf.json")
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

// Handler Method for uploaded files
func fileuploadHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println(r.Method)
	switch r.Method {

	case http.MethodPut:
		fmt.Println("PUT Called")
		contents, err := ioutil.ReadAll(r.Body)

		if err != nil {
			fmt.Fprintln(w, "404 -> "+err.Error())
			recover()
		}
		// create hash
		hash := createMD5(contents)

		// perform file saving and triggers action to perform
		// go metafilehandler.PerformFileAction(hash, contents)

		go publishIRToMessageQueue(hash, string(contents))

		break

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
		w.Write([]byte("405 - Method not allowed!"))
	}
}

func main() {
	// os.Setenv("PATH", os.Getenv("PATH") + ":/Users/pascal/Sync/Master Thesis/LLVM_Compiler_Tests/Sources")
	// log.Println(os.Getenv("PATH"))

	// TODO: fix issue with permissions (possible cause umask?)
	// os.MkdirAll("tmp", 0666)
	// if res, err := filehandler.filehandler.Exists("tmp") ; res == false || err != nil {
	// 	syscall.Umask(0666)
	// 	dirErr := os.Mkdir("tmp", os.ModeDir)
	// 	if dirErr != nil { log.Println(dirErr) }
	// }

	RabbitConf = loadRabbitMQConf()
	// log.Println("metaIRFileuploadServer:: loading config: " + RabbitConf)

	path := metafilehandler.PrepareTempFolder()
	fmt.Println(path)
	// defer os.RemoveAll(path)

	http.HandleFunc("/upload", fileuploadHandler)
	err := http.ListenAndServe(":4200", nil)
	if err != nil {
		log.Fatal("Listen and server: ", err.Error())
	}

}
