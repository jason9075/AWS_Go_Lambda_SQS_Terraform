package main

import (
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"testing"
)

func readMessage(path string)(string){
	messageBinary, _ := ioutil.ReadFile(path)
    message := string(messageBinary)
    return message
}

func TestHandleMessage_BasicMessage(t *testing.T) {
	inputMessage := readMessage("test_message/normal")
	expect := readMessage("test_message/normal_processed")

	actual := HandleMessage(inputMessage)
	assert.JSONEq(t, expect, actual)

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
