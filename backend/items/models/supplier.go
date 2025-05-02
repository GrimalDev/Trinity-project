package models

import (
	"context"
	"fmt"
	"trinity/backend/db"
	"trinity/backend/items/entities"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func CreateSupplier(s entities.SupplierStruct) (entities.SupplierStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("suppliers")

	s.Id = ""

	supplierInserted, errInsert := collection.InsertOne(ctx, s)
	if errInsert != nil {
		return entities.SupplierStruct{}, errInsert
	}

	insertedID, ok := supplierInserted.InsertedID.(primitive.ObjectID)
	if !ok {
		return entities.SupplierStruct{}, fmt.Errorf("failed to convert inserted ID to ObjectID")
	}

	s.Id = insertedID.Hex()

	return s, nil
}

func GetSupplierByName(name string) (entities.SupplierStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("suppliers")
	var supplier entities.SupplierStruct
	err := collection.FindOne(ctx, bson.M{"name": name}).Decode(&supplier)
	if err != nil {
		return entities.SupplierStruct{}, err
	}
	return supplier, nil
}
