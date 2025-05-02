package models

import (
	"context"
	"fmt"
	"trinity/backend/db"
	"trinity/backend/items/entities"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func CreateCity(c entities.CityStruct) (entities.CityStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("cities")

	c.Id = ""

	cityInserted, errInsert := collection.InsertOne(ctx, c)
	if errInsert != nil {
		return entities.CityStruct{}, errInsert
	}

	insertedID, ok := cityInserted.InsertedID.(primitive.ObjectID)
	if !ok {
		return entities.CityStruct{}, fmt.Errorf("failed to convert inserted ID to ObjectID")
	}

	c.Id = insertedID.Hex()

	return c, nil
}

func GetCityByName(name string) (entities.CityStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("cities")
	var city entities.CityStruct
	err := collection.FindOne(ctx, bson.M{"name": name}).Decode(&city)
	if err != nil {
		return entities.CityStruct{}, err
	}
	return city, nil
}
