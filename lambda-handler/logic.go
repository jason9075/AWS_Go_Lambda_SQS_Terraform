package main

import (
    "encoding/json"
)

func HandleMessage(input_message string)(string){

    var data map[string]string
    err := json.Unmarshal([]byte(input_message), &data)
    if err !=nil {
        panic("not a valid json: " + err.Error())
    }
    for key, value :=range data{
        data[key] = value+"-processed"
    }
    outputMessage, _ := json.Marshal(data)

    return string(outputMessage)
}
