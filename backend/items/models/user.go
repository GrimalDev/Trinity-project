package models

import (
	"context"
	"fmt"
	"strings"
	"trinity/backend/db"
	"trinity/backend/items/entities"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"
)

var ErrDuplicateKey = fmt.Errorf("duplicate key error")

func GetUserDetails(userID string) (entities.UserStruct, error) {
	return getUserById(userID)
}

func hashPassword(password string) (string, error) {
	passwordHash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}

	return string(passwordHash), nil
}

func CreateUser(u entities.UserStruct) (entities.UserBasicStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	passwordHash, errHash := hashPassword(u.Password)
	if errHash != nil {
		return entities.UserBasicStruct{}, errHash
	}
	u.Password = passwordHash
	role, err := GetRoleByName("user")
	if err != nil {
		return entities.UserBasicStruct{}, err
	}
	u.Roles = []entities.RoleStruct{{
		Id:          role.Id,
		Name:        role.Name,
		Permissions: role.Permissions,
	}}
	u.Invoices = []entities.InvoiceStruct{}
	u.Archived = false
	u.Id = ""

	userInserted, errInsert := collection.InsertOne(ctx, u)
	if errInsert == nil {
		insertedID, ok := userInserted.InsertedID.(primitive.ObjectID)
		if !ok {
			return entities.UserBasicStruct{}, fmt.Errorf("failed to convert inserted ID to ObjectID")
		}
		return entities.UserBasicStruct{
			Id:        insertedID.Hex(),
			FirstName: u.FirstName,
			LastName:  u.LastName,
			Email:     u.Email,
			Roles:     []entities.RoleStruct{role},
			Archived:  false,
		}, nil
	}

	if mongo.IsDuplicateKeyError(errInsert) && strings.Contains(errInsert.Error(), "email") {
		return entities.UserBasicStruct{}, fmt.Errorf("%w: Email already exists", ErrDuplicateKey)
	}

	if mongo.IsDuplicateKeyError(errInsert) {
		return entities.UserBasicStruct{}, ErrDuplicateKey
	}

	return entities.UserBasicStruct{}, errInsert
}

func SuperCreateUser(u entities.UserStruct) (entities.UserStruct, error) {

	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	passwordHash, errHash := hashPassword(u.Password)
	if errHash != nil {
		return entities.UserStruct{}, errHash
	}

	u.Password = passwordHash
	u.Id = ""

	userInserted, errInsert := collection.InsertOne(ctx, u)
	if errInsert == nil {
		insertedID, ok := userInserted.InsertedID.(primitive.ObjectID)
		if !ok {
			return entities.UserStruct{}, fmt.Errorf("failed to convert inserted ID to ObjectID")
		}
		u.Id = insertedID.Hex()
		return u, nil
	}

	if mongo.IsDuplicateKeyError(errInsert) && strings.Contains(errInsert.Error(), "email") {
		return entities.UserStruct{}, fmt.Errorf("%w: email already exists", ErrDuplicateKey)
	}

	if mongo.IsDuplicateKeyError(errInsert) {
		return entities.UserStruct{}, ErrDuplicateKey
	}

	return entities.UserStruct{}, errInsert
}

func GetBasicUserFromId(id string) (entities.UserBasicStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return entities.UserBasicStruct{}, fmt.Errorf("invalid ID format")
	}

	var user entities.UserBasicStruct
	err = collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&user)
	if err != nil {
		return entities.UserBasicStruct{}, err
	}
	return user, nil
}

func GetUserForJWT(id string) (entities.UserBasicStruct, error) {
	return GetBasicUserFromId(id)
}

func Login(username string, password string) (entities.UserBasicStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")
	var user entities.UserStruct
	err := collection.FindOne(ctx, bson.M{"email": username}).Decode(&user)
	if err != nil {
		return entities.UserBasicStruct{}, fmt.Errorf("Authentication error")
	}
	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password))
	if err != nil {
		return entities.UserBasicStruct{}, fmt.Errorf("Authentication error")
	}

	return entities.UserBasicStruct{
		Id:        user.Id,
		FirstName: user.FirstName,
		LastName:  user.LastName,
		Email:     user.Email,
		Roles:     user.Roles,
		Archived:  user.Archived,
	}, nil
}

func getUserById(id string) (entities.UserStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	// Convert string ID to ObjectID for query
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return entities.UserStruct{}, fmt.Errorf("invalid ID format")
	}

	var user entities.UserStruct
	err = collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&user)
	if err != nil {
		return entities.UserStruct{}, err
	}

	// Convert ObjectID back to string
	user.Id = objID.Hex()

	//pretty print debug
	return user, nil
}

func GetUsers(start int, quantity int) ([]entities.UserBasicStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	var users []entities.UserBasicStruct
	cursor, err := collection.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	for cursor.Next(ctx) {
		var user entities.UserBasicStruct
		if err := cursor.Decode(&user); err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	return users, nil
}

func ArchiveUserById(id string) error {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return fmt.Errorf("invalid ID format")
	}

	_, err = collection.UpdateOne(ctx, bson.M{"_id": objID}, bson.M{"$set": bson.M{"archived": true}})
	if err != nil {
		return err
	}
	return nil
}

func UpdateUser(user_id string, userUpdated entities.ModificationUserStruct) (entities.UserStruct, error) {

	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	// Convert string ID to ObjectID
	objID, err := primitive.ObjectIDFromHex(user_id)
	if err != nil {
		return entities.UserStruct{}, fmt.Errorf("invalid ID format")
	}

	_, err = collection.UpdateOne(ctx, bson.M{"_id": objID}, bson.M{"$set": userUpdated})
	if err != nil {
		return entities.UserStruct{}, err
	}
	user, err := getUserById(userUpdated.Id)
	if err != nil {
		return entities.UserStruct{}, err
	}
	return user, nil
}

func UpdatePassword(userId string, password string) error {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")
	// Convert string ID to ObjectID
	objID, err := primitive.ObjectIDFromHex(userId)
	if err != nil {
		return fmt.Errorf("invalid ID format")
	}
	passwordHash, errHash := hashPassword(password)
	if errHash != nil {
		return errHash
	}
	_, err = collection.UpdateOne(ctx, bson.M{"_id": objID}, bson.M{"$set": bson.M{"password": passwordHash}})
	if err != nil {
		return err
	}
	return nil
}

func UpdateDeviceToken(userId string, token string) error {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")
	// Convert string ID to ObjectID
	objID, err := primitive.ObjectIDFromHex(userId)
	if err != nil {
		return fmt.Errorf("invalid ID format")
	}
	_, err = collection.UpdateOne(ctx, bson.M{"_id": objID}, bson.M{"$set": bson.M{"deviceToken": token}})
	if err != nil {
		return err
	}
	return nil
}

func GetDeviceTokens() ([]string, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	cursor, err := collection.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var tokens []string
	for cursor.Next(ctx) {
		var user entities.UserStruct
		if err := cursor.Decode(&user); err != nil {
			return nil, err
		}
		tokens = append(tokens, user.DeviceToken)
	}

	return tokens, nil
}
