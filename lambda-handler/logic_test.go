package main

import (
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"testing"
    "strings"
)

func readMessage(path string)(string){
	messageBinary, _ := ioutil.ReadFile(path)
    message := string(messageBinary)
    message = strings.TrimSuffix(message, "\n")
    return message
}

func TestHandleMessage_BasicMessage(t *testing.T) {
	inputMessage := readMessage("test_message/normal")
	expect := readMessage("test_message/normal_processed")

	actual := HandleMessage(inputMessage)
	assert.Equal(t, actual, expect)

}

func TestHandleMessage_InvalidMessage(t *testing.T){
	inputMessage := readMessage("test_message/invalid_json")
    defer func(){
        if r:= recover(); r==nil{
            t.Errorf("it shoud be panic")
        }
    }()

    HandleMessage(inputMessage)

}
