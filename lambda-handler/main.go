package main

import (
	"fmt"
    "context"
    "encoding/json"
    "os"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
    "github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
)

// Response of API
type Response struct {
	Message string `json:"message"`
	At      string `json:"at"`
}

func handler(ctx context.Context, sqsEvent events.SQSEvent) (error) {
    sess, _:= session.NewSession()
    svc := sqs.New(sess)
    receiveURL := "https://sqs."+os.Getenv("REGION")+".amazonaws.com/"+os.Getenv("ACCOUNT_ID")+"/"+os.Getenv("SQS_1_NAME")
    sendURL := "https://sqs."+os.Getenv("REGION")+".amazonaws.com/"+os.Getenv("ACCOUNT_ID")+"/"+os.Getenv("SQS_2_NAME")
     
	for _, message := range sqsEvent.Records {
		fmt.Printf("The message %s for event source %s = %s \n", message.MessageId, message.EventSource, message.Body)

        body, err := json.Marshal(message.Body)
        if err != nil {
            panic("Error message format, not json: " + err.Error())
        }
        res, err := svc.SendMessage(&sqs.SendMessageInput{
          MessageBody:    aws.String(string(body)),
          QueueUrl:       &sendURL,
        })
        if err != nil {
            panic("Error send message fail: " + err.Error())
        }
        fmt.Println(res.String())

        receiptHandle := message.ReceiptHandle

        _, err = svc.DeleteMessage(&sqs.DeleteMessageInput{
            QueueUrl:      &receiveURL,
            ReceiptHandle: &receiptHandle,
        })
        if err != nil {
            panic("Error delete message fail: " + err.Error())
        }
	}
	return nil
}

func main() {
	lambda.Start(handler)
}
