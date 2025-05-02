package models

import (
	"context"
	"fmt"
	"trinity/backend/db"
	"trinity/backend/items/entities"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func CreateReport(reportType string, date string, reportData string) (entities.ReportStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()

	product := entities.ReportStruct{
		ReportType: reportType,
		Date:       date,
		ReportData: reportData,
	}

	collection := conn.Collection("reports")
	productInserted, err := collection.InsertOne(ctx, product)
	if err != nil {
		return entities.ReportStruct{}, err
	}

	insertedID, ok := productInserted.InsertedID.(primitive.ObjectID)
	if !ok {
		return entities.ReportStruct{}, fmt.Errorf("failed to convert inserted ID to ObjectID")
	}

	return entities.ReportStruct{
		Id:         insertedID.Hex(),
		ReportType: reportType,
		Date:       date,
		ReportData: reportData,
	}, nil
}

func GetReportById(id string) (entities.ReportStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("reports")

	// Convert string ID to ObjectID
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return entities.ReportStruct{}, fmt.Errorf("invalid ID format")
	}

	var report entities.ReportStruct
	err = collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&report)
	if err != nil {
		return entities.ReportStruct{}, err
	}
	return report, nil
}

func GetReports(start int, quantity int) ([]entities.ReportStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("reports")
	var reports []entities.ReportStruct
	cursor, err := collection.Find(ctx, bson.M{})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	for cursor.Next(ctx) {
		var report entities.ReportStruct
		if err := cursor.Decode(&report); err != nil {
			return nil, err
		}
		reports = append(reports, report)
	}
	return reports, nil
}

func ArchiveReportById(id string) error {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("reports")

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

func UpdateReport(reportId string, r entities.ReportStruct) (entities.ReportStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("reports")

	objID, err := primitive.ObjectIDFromHex(reportId)
	if err != nil {
		return entities.ReportStruct{}, fmt.Errorf("invalid ID format")
	}

	r.Id = ""

	_, err = collection.UpdateOne(ctx, bson.M{"_id": objID}, bson.M{"$set": r})
	if err != nil {
		return entities.ReportStruct{}, err
	}
	return r, nil
}
