package main

import ("./metaFilehandler"
				"./metaRabbitMQAdapter"

				"encoding/json"
				"fmt"
				"net/http"
				"log"
				"io/ioutil"
				"crypto/md5"
				"encoding/hex")



// function for publishing to rabbitMQ
func rabbitMQPulish(exchange string,
										queue string,
										routing_key string,
										msg string) {
	// setting up config stuff
	conf := metaRabbitMQAdapter.NewConfig()
	conf.Exchange		 	= exchange
	conf.Queue 				= queue
	conf.Routing_key	= routing_key

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


func publishIRToMessageQueue(hash string, irFile string) {
	// create map (key = hash | value = irFile)
	m := make(map[string]string)
	m[hash] = irFile
	// convert to json
	jsonData, err := json.Marshal(m)
	if err != nil {
		log.Println("metaIRFileuploadServer:: could not create json " + err.Error())
		recover()
	}
	log.Println("metaIRFileuploadServer:: publishing IR file with ID: " + hash)
	// send over message queue
	rabbitMQPulish("meta.deployment",
								 "meta.deployment.irhandling",
								 "irhandling",
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


// Handler Method for uploaded files
func fileuploadHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Println(r.Method)
	switch r.Method {

	case http.MethodPut:
		fmt.Println("PUT Called")
		contents, err := ioutil.ReadAll(r.Body)

		if err != nil {
			fmt.Fprintln(w, "404 -> " + err.Error())
			recover()
		}
		// create hash
		hash := createMD5(contents)

		// perform file saving and triggers action to perform
		// go metaFilehandler.PerformFileAction(hash, contents)

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

	path := metaFilehandler.PrepareTempFolder()
	fmt.Println(path)
	// defer os.RemoveAll(path)

	http.HandleFunc("/upload", fileuploadHandler)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("Listen and server: ", err)
	}

}
