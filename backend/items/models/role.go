package models

import (
	"context"
	"fmt"
	"trinity/backend/db"
	"trinity/backend/items/entities"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func CreateRole(r entities.RoleStruct) (entities.RoleStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("roles")

	r.Id = ""

	roleInserted, errInsert := collection.InsertOne(ctx, r)
	if errInsert != nil {
		return entities.RoleStruct{}, errInsert
	}

	insertedID, ok := roleInserted.InsertedID.(primitive.ObjectID)
	if !ok {
		return entities.RoleStruct{}, fmt.Errorf("failed to convert inserted ID to ObjectID")
	}

	r.Id = insertedID.Hex()

	return r, nil
}

func GetRoleByName(name string) (entities.RoleStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("roles")
	var role entities.RoleStruct
	err := collection.FindOne(ctx, bson.M{"name": name}).Decode(&role)
	if err != nil {
		return entities.RoleStruct{}, err
	}
	return role, nil
}

func GetRoleById(id string) (entities.RoleStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("roles")
	var role entities.RoleStruct
	oid, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return entities.RoleStruct{}, err
	}
	err = collection.FindOne(ctx, bson.M{"_id": oid}).Decode(&role)
	if err != nil {
		return entities.RoleStruct{}, err
	}
	return role, nil
}
