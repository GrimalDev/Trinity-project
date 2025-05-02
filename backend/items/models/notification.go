package models

import (
	"context"
	fcm "google.golang.org/api/fcm/v1"
	"google.golang.org/api/option"
	"log"
)

var fcmService *fcm.Service

func SendNotification(title, body string) error {

	// Fetch all device tokens from MongoDB
	tokens, err := GetDeviceTokens()
	if err != nil {
		return err
	}

	// Create the FCM message
	msg := &fcm.Message{
		Notification: &fcm.Notification{
			Title: title,
			Body:  body,
		},
	}

	// Send the message to each token individually (FCM v1 supports multicast but requires a different approach)
	ctx := context.Background()
	for _, token := range tokens {
		msg.Token = token
		sendReq := &fcm.SendMessageRequest{
			Message: msg,
		}

		// Send the message using the FCM service
		_, err := fcmService.Projects.Messages.Send("projects/com-baptistegrimaldi-trinity", sendReq).Context(ctx).Do()
		if err != nil {
			log.Printf("Error sending notification to token %s: %v", token, err)
		}
		log.Printf("Notification sent to token %s", token)
	}

	return nil
}

func InitFCMService(configPath string) (*fcm.Service, error) {
	ctx := context.Background()
	service, err := fcm.NewService(ctx, option.WithCredentialsFile(configPath), option.WithScopes(fcm.FirebaseMessagingScope))
	if err != nil {
		return nil, err
	}
	return service, nil
}

func SetFCMService(s *fcm.Service) {
	fcmService = s
}
