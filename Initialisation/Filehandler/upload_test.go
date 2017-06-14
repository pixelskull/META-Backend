package main

import (
        "fmt"
        "log"
        "testing"
        "net/http"
        "io/ioutil"
        "strings"
        "os"
        "bufio"
        )

func TestBasicRequest(t *testing.T) {
  // setup testing env
  url := "http://127.0.0.1:8080/upload"
  contentString := "dummy IR"

  // executing test case
  client := &http.Client{}
  request, err := http.NewRequest("PUT", url, strings.NewReader(contentString)) // TODO: check if curl -fileupload uses PUT
  if err != nil {
    t.Errorf("Creating Testing Basic Request Fails: " + err.Error())
  }
  request.ContentLength = int64( len(contentString) )
  response, err := client.Do(request)
  if err != nil {
    t.Errorf("Executing Testing Basic Request Fails: " + err.Error())
  } else {
    defer response.Body.Close()
    contents, err := ioutil.ReadAll(response.Body)
    if err != nil {
      t.Errorf("Reading Basic Request Response Fails: " + err.Error())
    }
    log.Println("Request Content is: " + string(contents))
  }
}

func TestBasicFileIsExisting(t *testing.T) {
  // setup testing env
  log.Println("creating test file...")
  os.Create("test.file")

  // executing test case
  exist, err := exists("test.file")
  if err != nil {
    t.Errorf("Checking File existance failed: " + err.Error())
  }
  if !exist {
    t.Fail()
  }

  // cleanup
  log.Println("removing test file...")
  os.Remove("test.file")
}

func TestBasicFileNotExisting(t *testing.T) {
  // executing test case
  exist, err := exists("test.file")
  if err != nil {
    t.Errorf("Checking File existance failed: " + err.Error())
  }
  if exist {
    t.Fail()
  }
}

func TestBasicMD5Creation(t *testing.T) {
  // setup testing env
  definedHash := "598d4c200461b81522a3328565c25f7c"
  testString := "hallo"
  testBytes := []byte(testString)

  computedHash := createMD5(testBytes)

  if definedHash != computedHash {
    t.Errorf("hashes not identical: " + computedHash + " vs. " + definedHash)
  }
}

func TestBasicIRFileSaving(t *testing.T) {
  content := "this is file content for testing purpose"
  content_as_bytes := []byte(content)
  hash := createMD5(content_as_bytes)

  defer func() {
        if r := recover(); r != nil {
            t.Errorf("Panic while saving IR file")
        }
    }()

  saveIRFile(hash, content_as_bytes)
}

func TestTempFolderPreparation(t *testing.T) {
  path := prepareTempFolder()
  testFile := path + "/testfile"
  file, err := os.OpenFile(testFile, os.O_APPEND|os.O_CREATE|os.O_RDWR, 0666)
  if err != nil {
    t.Errorf("Testfile couldn't be created: " + err.Error())
  }
  defer file.Close()

  writer := bufio.NewWriter(file)
  _, err = fmt.Fprintf(writer, "test case was here...")
  if err != nil {
    t.Errorf("Testfile is not writeable: " + err.Error())
  }
}

func TestFileAction(t *testing.T) {
  path, err := os.Getwd()
  if err != nil {
    t.Errorf("couln't find current working directory")
  }

  test_ir := path + "/testfiles/test.ll"

  bytes, err := ioutil.ReadFile(test_ir)
  if err != nil {
    t.Errorf("not able to read Testfile from" + test_ir + ": " + err.Error())
  }

  hash := createMD5(bytes)

  err = performFileAction(hash, bytes)

  if err != nil {
    t.Error("failed to perform file action: " + err.Error())
  }
}
