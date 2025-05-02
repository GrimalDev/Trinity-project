package models

import (
	"context"
	"fmt"
	"trinity/backend/db"
	"trinity/backend/items/entities"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func CreateOrder(invoiceId string, o entities.OrderStruct) (entities.OrderStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("invoices")

	// Convert invoiceId string to ObjectID
	invoiceObjID, err := primitive.ObjectIDFromHex(invoiceId)
	if err != nil {
		return entities.OrderStruct{}, fmt.Errorf("invalid invoice ID format: %v", err)
	}

	// Generate new ObjectID for the order and convert to string
	o.Id = primitive.NewObjectID().Hex()

	// Add order to the invoice's orders array
	update := bson.M{
		"$push": bson.M{
			"orders": o,
		},
	}

	result, err := collection.UpdateOne(
		ctx,
		bson.M{"_id": invoiceObjID},
		update,
	)

	if err != nil {
		return entities.OrderStruct{}, err
	}

	if result.ModifiedCount == 0 {
		return entities.OrderStruct{}, fmt.Errorf("invoice not found")
	}

	return o, nil
}

func GetOrderWithProducts(invoiceId string) (*entities.OrderWithProductDetails, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()

	// Convert invoiceId string to ObjectID
	invoiceObjID, err := primitive.ObjectIDFromHex(invoiceId)
	if err != nil {
		return nil, fmt.Errorf("invalid invoice ID format: %v", err)
	}

	pipeline := mongo.Pipeline{
		primitive.D{
			primitive.E{Key: "$match", Value: bson.M{
				"_id": invoiceObjID,
			}},
		},
		primitive.D{
			primitive.E{Key: "$lookup", Value: bson.M{
				"from":         "products",
				"localField":   "orders.products.productId",
				"foreignField": "id",
				"as":           "productDetails",
			}},
		},
		primitive.D{
			primitive.E{Key: "$addFields", Value: bson.M{
				"orders.products": bson.M{
					"$map": bson.M{
						"input": "$orders.products",
						"as":    "orderProduct",
						"in": bson.M{
							"product": bson.M{
								"$arrayElemAt": []any{
									"$productDetails",
									bson.M{
										"$indexOfArray": []any{
											"$productDetails.id",
											"$$orderProduct.productId",
										},
									},
								},
							},
							"quantity": "$$orderProduct.quantity",
							"price":    "$$orderProduct.price",
						},
					},
				},
			}},
		},
		primitive.D{
			primitive.E{Key: "$replaceRoot", Value: bson.M{
				"newRoot": "$orders",
			}},
		},
	}

	cursor, err := conn.Collection("invoices").Aggregate(ctx, pipeline)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	var result entities.OrderWithProductDetails
	if cursor.Next(ctx) {
		if err := cursor.Decode(&result); err != nil {
			return nil, err
		}
		return &result, nil
	}

	return nil, fmt.Errorf("order not found")
}
