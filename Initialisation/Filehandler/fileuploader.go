package main

import (
				"fmt"
				"net/http"
				"log"
				"io/ioutil"
				"crypto/md5"
				"encoding/hex"
				"os"
				"os/exec"

				"github.com/optiopay/kafka"
				)

				// "github.com/optiopay/kafka/proto"

const (
			 topic 			= "test"
			 partition  = 0
		   )

var kafkaAddrs = []string{"172.17.0.3:9092", "172.17.0.3:9093"}

func kafkaBrokerSetup() *kafka.Broker {
	conf := kafka.NewBrokerConf("test-producer")
	// conf.AllowTopicCreation = true

	broker, err := kafka.Dial(kafkaAddrs, conf)

	if err != nil {
		log.Fatalf("cannot connect to kafka cluster: %s", err)
	}

	return broker
}

// creates folder META in tempDir if not existing and returns the path
func prepareTempFolder() string{
	tmpDir := os.TempDir()
	path 	 := tmpDir + "META"

	folder_exists, _ := exists(path)
	if folder_exists == false {
		// create Folder and error handling
		err := os.Mkdir(path, os.ModePerm) // TODO: check if umask problem still exists in tmp folder
		if err != nil {
			log.Fatalf("MkdirAll failed %q: %s", path, err)
		}
	}
	// return Path
	return path
}

// performs compilation on file
func performFileAction(hash string, contents []byte) error {
	log.Println("started goroutine for sending file to kafka")

	ir_file := saveIRFile(hash, contents)

	app := "/usr/local/bin/compilation.py"

	cmd := exec.Command(app, ir_file)
	stdout, err := cmd.Output()

	if err != nil {
		log.Fatalf("failed to execute command " + app + ": " + err.Error())
		return err
	}

	log.Printf(string(stdout))
	return nil

	// broker := kafkaBrokerSetup()
	// producer := broker.Producer(kafka.NewProducerConf())
	//
	// msg := &proto.Message{Value: contents}
	//
	// _, err := producer.Produce(topic, partition, msg)
	// if err != nil {
	// 	log.Fatalf("cannot produce message to %s:%d caused by: %s", topic, partition, err)
	// }
	// log.Println("finished goroutine for sending file to kafka")
}

// exists returns whether the given file or directory exists or not
func exists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil { return true, nil }
	if os.IsNotExist(err) { return false, nil }
	return true, err
}

// saves content array to LLVM-IR file with given name (<name>.ll)
func saveIRFile(name string, contents []byte) string {
	// create file to contain contents with name (eg. hash)
	filePath := prepareTempFolder() + name + ".ll" // "tmp/"  TODO: Change path to use folder if creation is done right
	f, err := os.Create(filePath)
	if err != nil {
		panic(err)
	}
	// close fo on exit and check for its returned error
	defer func() {
		if err := f.Close(); err != nil {
			panic(err)
		}
	}()
	// write contents
	if _, err := f.Write(contents); err != nil {
		panic(err)
	}
	log.Println("created file at Path: " + filePath)
	return filePath
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
func fileupload(w http.ResponseWriter, r *http.Request) {
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
		go performFileAction(hash, contents)

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
	// if res, err := exists("tmp") ; res == false || err != nil {
	// 	syscall.Umask(0666)
	// 	dirErr := os.Mkdir("tmp", os.ModeDir)
	// 	if dirErr != nil { log.Println(dirErr) }
	// }
	path := prepareTempFolder()
	fmt.Println(path)
	// defer os.RemoveAll(path)

	http.HandleFunc("/upload", fileupload)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("Listen and server: ", err)
	}

}
