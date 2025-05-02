package models

import (
	"context"
	"fmt"
	"log"
	"trinity/backend/db"
	"trinity/backend/items/entities"

	echo "github.com/labstack/echo/v4"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func CreateInvoiceSelf(c echo.Context, i entities.InvoiceStruct) (entities.InvoiceStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	// Generate a unique ID for the invoice
	i.Id = primitive.NewObjectID().Hex()

	userId := c.Get("user").(entities.UserBasicStruct).Id

	// Convert string ID to ObjectID
	userObjID, err := primitive.ObjectIDFromHex(userId)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("invalid user ID format: %v", err)
	}

	// Add the invoice to the user's invoices array
	filter := bson.M{"_id": userObjID}
	update := bson.M{"$push": bson.M{"invoices": i}}

	user, err := collection.UpdateOne(ctx, filter, update)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("failed to add invoice to user: %v", err)
	}

	if user.ModifiedCount == 0 {
		return entities.InvoiceStruct{}, fmt.Errorf("user not found or invoice not added")
	}

	invoiceCreated, err := getLastCreatedInvoiceForUserId(userId)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("failed to retrieve inserted invoice: %v", err)
	}

	return invoiceCreated, nil
}

func getLastCreatedInvoiceForUserId(userId string) (entities.InvoiceStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	objUserId, err := primitive.ObjectIDFromHex(userId)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("invalid user ID format: %v", err)
	}

	// Aggregate pipeline to get the most recent invoice by date
	pipeline := []bson.M{
		{"$match": bson.M{"_id": objUserId}},
		{"$unwind": "$invoices"},
		{"$sort": bson.M{"invoices.date": -1}}, // Sort by date in descending order
		{"$limit": 1},                          // Get only the first (most recent) invoice
		{"$replaceRoot": bson.M{"newRoot": "$invoices"}},
	}

	cursor, err := collection.Aggregate(ctx, pipeline)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("failed to query database: %v", err)
	}
	defer cursor.Close(ctx)

	var invoice entities.InvoiceStruct
	if cursor.Next(ctx) {
		if err := cursor.Decode(&invoice); err != nil {
			return entities.InvoiceStruct{}, fmt.Errorf("failed to decode invoice: %v", err)
		}
		return invoice, nil
	}

	return entities.InvoiceStruct{}, fmt.Errorf("no invoices found for user")
}

func CancelLastInvoice(c echo.Context) (entities.InvoiceStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	userId := c.Get("user").(entities.UserBasicStruct).Id

	objUserId, err := primitive.ObjectIDFromHex(userId)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("invalid user ID format: %v", err)
	}

	// Aggregate pipeline to get the most recent invoice by date
	pipeline := []bson.M{
		{"$match": bson.M{"_id": objUserId}},
		{"$unwind": "$invoices"},
		{"$sort": bson.M{"invoices.date": -1}}, // Sort by date in descending order
		{"$limit": 1},                          // Get only the first (most recent) invoice
		{"$replaceRoot": bson.M{"newRoot": "$invoices"}},
	}

	cursor, err := collection.Aggregate(ctx, pipeline)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("failed to query database: %v", err)
	}
	defer cursor.Close(ctx)

	var invoice entities.InvoiceStruct
	if cursor.Next(ctx) {
		if err := cursor.Decode(&invoice); err != nil {
			return entities.InvoiceStruct{}, fmt.Errorf("failed to decode invoice: %v", err)
		}
	} else {
		return entities.InvoiceStruct{}, fmt.Errorf("no invoices found for user")
	}

	// Update the invoice using the string ID
	invoiceModified := invoice
	invoiceModified.Order.Status = "cancelled"
	invoiceModified.Archived = true
	updatedInvoice, err := UpdateInvoiceSelf(c, invoiceModified)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("failed to cancel invoice: %v", err)
	}

	return updatedInvoice, nil
}

func GetInvoices(start int, quantity int) ([]entities.InvoiceStruct, error) {
	// db.users.aggregate([ { $unwind: "$invoices" }, { $replaceRoot: { newRoot: "$invoices" } }] )
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")
	var invoices []entities.InvoiceStruct
	cursor, err := collection.Aggregate(ctx, []bson.M{{"$unwind": "$invoices"}, {"$replaceRoot": bson.M{"newRoot": "$invoices"}}})
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	for cursor.Next(ctx) {
		var invoice entities.InvoiceStruct
		if err := cursor.Decode(&invoice); err != nil {
			return nil, err
		}
		invoices = append(invoices, invoice)
	}
	return invoices, nil
}

func GetEarnings() (float64, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")
	cursor, err := collection.Aggregate(ctx, []bson.M{
		// Unwind the invoices array from each user document
		{"$unwind": "$invoices"},
		// Group all invoices (using a null _id) and sum the TotalPrice field
		{"$group": bson.M{
			"_id":           nil,
			"totalEarnings": bson.M{"$sum": "$invoices.totalPrice"},
		}},
	})
	if err != nil {
		log.Fatalf("Aggregate error: %v", err)
	}

	var results []bson.M
	if err := cursor.All(ctx, &results); err != nil {
		log.Fatalf("Cursor error: %v", err)
	}

	if len(results) > 0 {
		fmt.Println("Total Earnings:", results[0]["totalEarnings"])
	} else {
		fmt.Println("No invoices found")
	}

	return results[0]["totalEarnings"].(float64), nil
}

// GetUserInvoiceDateAndVAT retrieves the date and total VAT price of all invoices for a specific user
func GetUserInvoiceDateAndVAT(userId string) ([]entities.UserInvoiceSummary, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	objID, err := primitive.ObjectIDFromHex(userId)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID format")
	}

	pipeline := []bson.M{
		{"$match": bson.M{"_id": objID}},
		{"$unwind": "$invoices"},
		{"$project": bson.M{
			"_id":        "$invoices._id",
			"date":       "$invoices.date",
			"totalPrice": "$invoices.totalPrice",
		}},
	}

	cursor, err := collection.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var summaries []entities.UserInvoiceSummary
	if err = cursor.All(ctx, &summaries); err != nil {
		return nil, err
	}

	return summaries, nil
}

func GetAverageSpending() (float64, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")
	pipeline := []bson.M{
		// Unwind the invoices array from each user document
		{"$unwind": "$invoices"},
		// Group all invoices together (using _id: nil) and calculate the average TotalPrice
		{"$group": bson.M{
			"_id":            nil,
			"averageInvoice": bson.M{"$avg": "$invoices.totalPrice"},
		}},
	}

	cursor, err := collection.Aggregate(ctx, pipeline)
	if err != nil {
		log.Fatalf("Aggregate error: %v", err)
	}

	var results []bson.M
	if err := cursor.All(ctx, &results); err != nil {
		log.Fatalf("Cursor error: %v", err)
	}

	if len(results) > 0 {
		fmt.Println("Average per invoice:", results[0]["averageInvoice"])
	} else {
		fmt.Println("No invoices found")
	}
	return results[0]["averageInvoice"].(float64), nil
}

func GetTotalProductSold() (int32, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")
	pipeline := []bson.M{
		// Unwind the invoices array
		{"$unwind": "$invoices"},
		// Unwind the products array in the order
		{"$unwind": "$invoices.order.products"},
		// Group all products together and sum the quantity field
		{"$group": bson.M{
			"_id":              nil,
			"totalProductSold": bson.M{"$sum": "$invoices.order.products.quantity"},
		}},
	}

	cursor, err := collection.Aggregate(ctx, pipeline)
	if err != nil {
		log.Fatalf("Aggregate error: %v", err)
	}

	var results []bson.M
	if err := cursor.All(ctx, &results); err != nil {
		log.Fatalf("Cursor error: %v", err)
	}

	if len(results) > 0 {
		fmt.Println("Total Products Sold:", results[0]["totalProductSold"])
	} else {
		fmt.Println("No invoices found")
	}
	return results[0]["totalProductSold"].(int32), nil
}

func ArchiveInvoiceById(id string) error {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("invoices")

	// Convert string ID to ObjectID
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

func UpdateInvoiceSelf(c echo.Context, i entities.InvoiceStruct) (entities.InvoiceStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	// Get user ID from context
	userId := c.Get("user").(entities.UserBasicStruct).Id

	// Convert user ID string to ObjectID
	userObjID, err := primitive.ObjectIDFromHex(userId)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("invalid user ID format: %v", err)
	}

	// Filter to find the user document
	filter := bson.M{
		"_id": userObjID,
	}

	// Prepare update operation with the entire invoice struct
	update := bson.M{
		"$set": bson.M{
			"invoices.$[elem]": i,
		},
	}

	// Use ArrayFilters to match the specific invoice by its ID
	opts := options.UpdateOptions{
		ArrayFilters: &options.ArrayFilters{
			Filters: []interface{}{
				bson.M{"elem._id": i.Id},
			},
		},
	}

	// Perform the update
	result, err := collection.UpdateOne(ctx, filter, update, &opts)
	if err != nil {
		return entities.InvoiceStruct{}, fmt.Errorf("failed to update invoice: %v", err)
	}

	// Check if any document was modified
	if result.ModifiedCount == -1 {
		// Add debug information to help diagnose the issue
		fmt.Printf("Update failed: User ID: %s, Invoice ID: %s\n", userId, i.Id)

		// Check if the invoice exists for this user
		var user struct {
			Invoices []entities.InvoiceStruct `bson:"invoices"`
		}

		err := collection.FindOne(ctx, bson.M{"_id": userObjID}).Decode(&user)
		if err != nil {
			return entities.InvoiceStruct{}, fmt.Errorf("failed to find user: %v", err)
		}

		found := false
		for _, inv := range user.Invoices {
			if inv.Id == i.Id {
				found = true
				break
			}
		}

		if found {
			return entities.InvoiceStruct{}, fmt.Errorf("invoice found but update failed for ID %s", i.Id)
		} else {
			return entities.InvoiceStruct{}, fmt.Errorf("no invoice found with ID %s for user %s", i.Id, userId)
		}
	}

	return i, nil
}

// GetUserInvoiceById retrieves a specific invoice by its ID from a specific user
func GetUserInvoiceById(userId string, invoiceId string) (entities.InvoiceOrderStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("users")

	// Convert user ID string to ObjectID
	userObjID, err := primitive.ObjectIDFromHex(userId)
	if err != nil {
		return entities.InvoiceOrderStruct{}, fmt.Errorf("invalid user ID format")
	}

	// Define the aggregation pipeline
	pipeline := []bson.M{
		// Match the user by ID
		{"$match": bson.M{"_id": userObjID}},
		// Unwind the invoices array
		{"$unwind": "$invoices"},
		// Match the specific invoice
		{"$match": bson.M{"invoices._id": invoiceId}},
		// Replace root with the invoice
		{"$replaceRoot": bson.M{"newRoot": "$invoices"}},
		// Lookup product details from the "products" collection
		{
			"$lookup": bson.M{
				"from": "products",
				"let":  bson.M{"productIds": "$order.products.productId"},
				"pipeline": []bson.M{
					// Convert product _id to string to match productId
					{"$addFields": bson.M{"idStr": bson.M{"$toString": "$_id"}}},
					// Match products where idStr is in productIds
					{"$match": bson.M{"$expr": bson.M{"$in": []any{"$idStr", "$$productIds"}}}},
				},
				"as": "productDetails",
			},
		},
		// Merge product details into order.products
		{
			"$addFields": bson.M{
				"order.products": bson.M{
					"$map": bson.M{
						"input": "$order.products",
						"as":    "prod",
						"in": bson.M{
							"product": bson.M{
								"$arrayElemAt": []any{
									"$productDetails",
									bson.M{
										"$indexOfArray": []any{
											"$productDetails.idStr",
											"$$prod.productId",
										},
									},
								},
							},
							"quantity": "$$prod.quantity",
							"price":    bson.M{"$divide": []any{"$$prod.price", "$$prod.quantity"}}, // Calculate unit price
						},
					},
				},
			},
		},
	}

	// Execute the aggregation
	cursor, err := collection.Aggregate(ctx, pipeline)
	if err != nil {
		return entities.InvoiceOrderStruct{}, err
	}
	defer cursor.Close(ctx)

	// Decode the result
	var results []entities.InvoiceOrderStruct
	if err = cursor.All(ctx, &results); err != nil {
		return entities.InvoiceOrderStruct{}, err
	}

	// Check if invoice was found
	if len(results) == 0 {
		return entities.InvoiceOrderStruct{}, fmt.Errorf("invoice not found")
	}

	return results[0], nil
}
