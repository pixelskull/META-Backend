package main

import (
        "log"
        "testing"
        "net/http"
        "io/ioutil"
        "strings"
        "os"
        )

func TestBasicRequest(t *testing.T) {
  // setup testing env
  url := "http://127.0.0.1:8080/upload"
  contentString := "dummy IR"

  // executing test case
  client := &http.Client{}
  request, err := http.NewRequest("PUT", url, strings.NewReader(contentString))
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

func TestBasicFileHandling(t *testing.T) {
  t.Error("not implemented yet...")
}

func TestBasicIRFileSaving(t *testing.T) {
  t.Error("not implemented yet...")
}
