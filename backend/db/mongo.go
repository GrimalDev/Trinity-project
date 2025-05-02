package db

import (
	"context"
	"fmt"
	"log"
	"os"
	"sync"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var (
	client     *mongo.Client
	connection *mongo.Database
)

const (
	maxRetries        = 5
	initialBackoff    = 1 * time.Second
	maxBackoff        = 30 * time.Second
	backoffMultiplier = 2
)

func connectWithRetry(uri string) (*mongo.Client, error) {
	var err error
	backoff := initialBackoff

	for attempt := 1; attempt <= maxRetries; attempt++ {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		client, err = mongo.Connect(ctx, options.Client().ApplyURI(uri))
		if err == nil {
			// Verify connection
			if err = client.Ping(ctx, nil); err == nil {
				return client, nil
			}
		}

		if attempt == maxRetries {
			break
		}

		log.Printf("Failed to connect to MongoDB (attempt %d/%d): %v. Retrying in %v...",
			attempt, maxRetries, err, backoff)

		time.Sleep(backoff)

		// Exponential backoff with cap
		backoff *= backoffMultiplier
		if backoff > maxBackoff {
			backoff = maxBackoff
		}
	}

	return nil, fmt.Errorf("failed to connect after %d attempts: %v", maxRetries, err)
}

func GetDatabase() *mongo.Database {
	once := sync.Once{}
	once.Do(func() {
		dbHost := os.Getenv("DB_HOST")
		database := os.Getenv("DB_NAME")
		password := os.Getenv("DB_PASSWORD")
		username := os.Getenv("DB_USERNAME")
		if dbHost == "" || database == "" || password == "" || username == "" {
			log.Fatalf("Missing environment variables")
		}

		uri := fmt.Sprintf("mongodb://%s:%s@%s/%s?retryWrites=true&w=majority&authSource=admin",
			username, password, dbHost, database)

		var err error
		client, err = connectWithRetry(uri)
		if err != nil {
			log.Fatalf("Failed to connect to MongoDB: %v", err)
		}

		connection = client.Database(database)
	})

	return connection
}

func CloseConnection() {
	if client != nil {
		err := client.Disconnect(context.Background())
		if err != nil {
			log.Fatalf("Failed to disconnect MongoDB client: %v", err)
		}
		log.Println("Disconnected from MongoDB")
	}
}
