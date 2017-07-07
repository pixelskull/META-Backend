package main

import ("./metaFilehandler"
				"./metaRabbitMQAdapter"

				"time"

				"fmt"
				"net/http"
				"log"
				"io/ioutil"
				"crypto/md5"
				"encoding/hex")

// dummy function for checking integration TODO delete later on
func dummyRabbitPulish() {
	// setting up config stuff
	conf := metaRabbitMQAdapter.NewConfig()
	conf.Exchange		 	= "amq.direct"
	conf.Queue 				= "testing-queue"
	conf.Routing_key	= "testing"

	fmt.Println("publish:: conf setup")
	// setup connection and channel
	conn := metaRabbitMQAdapter.CreateConnection(conf)
	defer conn.Close()
	ch := metaRabbitMQAdapter.CreateChannel(conn)
	defer ch.Close()

	fmt.Println("publish:: channel setup")

	// publish some message
	metaRabbitMQAdapter.Publish(ch, conf, "testing")

	fmt.Println("publish:: message published")
}

func dummyRabbitSubscribe() {
	// setting up config stuff
	conf := metaRabbitMQAdapter.NewConfig()
	conf.Exchange		 	= "amq.direct"
	conf.Queue 				= "testing-queue"
	conf.Routing_key	= "testing"
	fmt.Println("subscribe:: conf setup")
	// setup connection and channel
	conn := metaRabbitMQAdapter.CreateConnection(conf)
	defer conn.Close()
	ch := metaRabbitMQAdapter.CreateChannel(conn)
	defer ch.Close()

	fmt.Println("subscribe:: channel setup")
	callback := func (msg metaRabbitMQAdapter.RabbitDelivery) {
		for d := range msg {
			log.Printf("Received a message: %s", d.Body)
		}
	}

	metaRabbitMQAdapter.Subscribe(ch, conf, callback)
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
		go metaFilehandler.PerformFileAction(hash, contents)

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
	go dummyRabbitSubscribe()
	time.Sleep(time.Second * 2)
	for i := 0;i < 6;i++ {
		dummyRabbitPulish()
	}


	path := metaFilehandler.PrepareTempFolder()
	fmt.Println(path)
	// defer os.RemoveAll(path)

	http.HandleFunc("/upload", fileuploadHandler)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("Listen and server: ", err)
	}

}
