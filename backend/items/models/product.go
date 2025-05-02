package models

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
	"trinity/backend/db"
	"trinity/backend/items/entities"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

func getOpenFoodFactsData(reference string) (entities.ProductStruct, error) {
	url := fmt.Sprintf("https://world.openfoodfacts.org/api/v0/product/%s.json", reference)

	resp, err := http.Get(url)
	if err != nil {
		return entities.ProductStruct{}, fmt.Errorf("error fetching product data: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return entities.ProductStruct{}, fmt.Errorf("Openfood API returned non-200 status code: %d", resp.StatusCode)
	}

	var openFoodFactsResp struct {
		Status  int `json:"status"`
		Product struct {
			ProductName   string `json:"product_name"`
			Brands        string `json:"brands"`
			Categories    string `json:"categories"`
			ImageURL      string `json:"image_url"`
			ImageThumbURL string `json:"image_thumb_url"`
			Nutriments    struct {
				Energy100g   float64 `json:"energy-kcal_100g"`
				Proteins100g float64 `json:"proteins_100g"`
				Fat100g      float64 `json:"fat_100g"`
				Carbs100g    float64 `json:"carbohydrates_100g"`
			} `json:"nutriments"`
		} `json:"product"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&openFoodFactsResp); err != nil {
		return entities.ProductStruct{}, fmt.Errorf("error decoding response: %v", err)
	}

	if openFoodFactsResp.Status != 1 {
		return entities.ProductStruct{}, fmt.Errorf("product not found")
	}

	nutritionalInfo := fmt.Sprintf(
		"Energy: %.1f kcal/100g, Proteins: %.1fg/100g, Fat: %.1fg/100g, Carbohydrates: %.1fg/100g",
		openFoodFactsResp.Product.Nutriments.Energy100g,
		openFoodFactsResp.Product.Nutriments.Proteins100g,
		openFoodFactsResp.Product.Nutriments.Fat100g,
		openFoodFactsResp.Product.Nutriments.Carbs100g,
	)

	product := entities.ProductStruct{
		Reference: reference,
		Name:      openFoodFactsResp.Product.ProductName,
		Brand:     openFoodFactsResp.Product.Brands,
		Category:  openFoodFactsResp.Product.Categories,
		Images: entities.ImagesStruct{
			S:  openFoodFactsResp.Product.ImageThumbURL,
			XL: openFoodFactsResp.Product.ImageURL,
		},
		NutritionalInformation: nutritionalInfo,
		Archived:               false,
	}

	return product, nil
}

func GetTotalCategories() (int32, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")
	pipeline := []bson.M{
		// 1. Project a new field "categories" by splitting the category string into an array.
		{"$project": bson.M{
			"categories": bson.M{
				"$split": []any{"$category", ", "},
			},
		}},
		// 2. Unwind the "categories" array so each element becomes its own document.
		{"$unwind": "$categories"},
		// 3. Group by the category (each distinct category becomes a group).
		{"$group": bson.M{
			"_id": "$categories",
		}},
		// 4. Count the number of distinct categories.
		{"$count": "distinctCategoryCount"},
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
		fmt.Printf("Distinct category count: %v\n", results[0]["distinctCategoryCount"])
	} else {
		fmt.Println("No categories found.")
	}
	return results[0]["distinctCategoryCount"].(int32), nil
}

func GetTotalProductStock() (float64, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")
	pipeline := []bson.M{
		{
			"$group": bson.M{
				"_id":        nil,
				"totalStock": bson.M{"$sum": "$stockQuantity"},
			},
		},
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
		fmt.Printf("Total Stock: %v\n", results[0]["totalStock"])
	} else {
		fmt.Println("No products found.")
	}
	return results[0]["totalStock"].(float64), nil
}

func GetAverageProductCost() (float64, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")
	pipeline := []bson.M{
		{
			"$group": bson.M{
				"_id":     nil,
				"avgCost": bson.M{"$avg": "$priceVat"},
			},
		},
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
		fmt.Printf("Average Product Cost: %v\n", results[0]["avgCost"])
	} else {
		fmt.Println("No products found.")
	}
	return results[0]["avgCost"].(float64), nil
}

func GetProductsPerCategory() ([]entities.StatsProduct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")
	pipeline := []bson.M{
		// 1. Split the "category" string into an array of categories
		{"$project": bson.M{
			"categories": bson.M{
				"$split": []any{"$category", ", "},
			},
		}},
		// 2. Unwind the "categories" array so each category becomes a separate document
		{"$unwind": "$categories"},
		// 3. Group by the individual category and count the number of products
		{"$group": bson.M{
			"_id":   "$categories",
			"name":  bson.M{"$first": "$categories"},
			"total": bson.M{"$sum": 1},
		}},
	}

	cursor, err := collection.Aggregate(ctx, pipeline)
	if err != nil {
		log.Fatalf("Aggregate error: %v", err)
	}

	var stats []entities.StatsProduct
	if err := cursor.All(ctx, &stats); err != nil {
		log.Fatalf("Error decoding results: %v", err)
	}

	for _, stat := range stats {
		fmt.Printf("Category: %s, Total: %d\n", stat.Name, stat.Total)
	}
	return stats, nil
}

func CreateProduct(p entities.ProductBasic) (entities.ProductStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()

	product, err := getOpenFoodFactsData(p.Reference)

	if err != nil {
		return entities.ProductStruct{}, err
	}

	product.PriceVat = p.PriceVat
	product.PriceNot = p.PriceNot

	product.StockQuantity = p.StockQuantity

	collection := conn.Collection("products")
	allReadyArchived := false
	dupProduct := entities.ProductStruct{}
	productInserted, err := collection.InsertOne(ctx, product)
	if err != nil {
		// Check if the error is a duplicate key error
		if mongo.IsDuplicateKeyError(err) {
			dupProduct, err = GetProductByReference(p.Reference)
			if err != nil {
				return entities.ProductStruct{}, fmt.Errorf("product with reference %s already exists, failed to get product by reference", err)
			}

			if !dupProduct.Archived {
				return entities.ProductStruct{}, fmt.Errorf("product with reference %s already exists", p.Reference)
			}
			allReadyArchived = true
		}
	}

	if allReadyArchived {
		_, err = UpdateProduct(dupProduct.Id, product)
		if err != nil {
			return entities.ProductStruct{}, fmt.Errorf("archived product with reference %s already exists, failed to update archived product: %v", p.Reference, err)
		}
		return dupProduct, nil
	}

	insertedID, ok := productInserted.InsertedID.(primitive.ObjectID)
	if !ok {
		return entities.ProductStruct{}, fmt.Errorf("failed to convert inserted ID to ObjectID")
	}

	product.Id = insertedID.Hex()

	return product, nil
}

// Function to get a product by ID
func GetProductById(id string) (entities.ProductStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")

	// Convert string ID to ObjectID
	objID, err := primitive.ObjectIDFromHex(id)
	if err != nil {
		return entities.ProductStruct{}, fmt.Errorf("invalid ID format")
	}

	var product entities.ProductStruct
	err = collection.FindOne(ctx, bson.M{"_id": objID}).Decode(&product)
	if err != nil {
		return entities.ProductStruct{}, err
	}
	return product, nil
}

func GetProductByName(name string) (entities.ProductStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")
	var product entities.ProductStruct
	err := collection.FindOne(ctx, bson.M{"name": name}).Decode(&product)
	if err != nil {
		return entities.ProductStruct{}, err
	}
	return product, nil
}

func GetProductByReference(reference string) (entities.ProductStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")
	var product entities.ProductStruct
	err := collection.FindOne(ctx, bson.M{"reference": reference}).Decode(&product)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			return entities.ProductStruct{}, fmt.Errorf("no product found with reference: %s", reference)
		}
		return entities.ProductStruct{}, err
	}
	return product, nil
}

func GetProducts(start int, quantity int) ([]entities.ProductStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")
	var products []entities.ProductStruct

	// Add filter for non-archived products
	filter := bson.M{"archived": false}

	cursor, err := collection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)
	for cursor.Next(ctx) {
		var product entities.ProductStruct
		if err := cursor.Decode(&product); err != nil {
			return nil, err
		}
		products = append(products, product)
	}
	return products, nil
}

// Function to archive a product by ID
func ArchiveProductById(id string) error {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")

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

func UpdateProduct(productId string, p entities.ProductStruct) (entities.ProductStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")

	// Convert string ID to ObjectID
	objID, err := primitive.ObjectIDFromHex(productId)
	if err != nil {
		return entities.ProductStruct{}, fmt.Errorf("invalid ID format")
	}

	p.Id = ""

	_, err = collection.UpdateOne(ctx, bson.M{"_id": objID}, bson.M{"$set": p})
	if err != nil {
		return entities.ProductStruct{}, err
	}

	return p, nil
}

func GetProductBySearchProducts(productName string) ([]entities.ProductStruct, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	collection := conn.Collection("products")

	var products []entities.ProductStruct

	filter := bson.M{"name": bson.M{"$regex": productName, "$options": "i"}}

	cursor, err := collection.Find(ctx, filter)
	if err != nil {
		return nil, err
	}
	defer cursor.Close(ctx)

	if err = cursor.All(ctx, &products); err != nil {
		return nil, err
	}

	if len(products) == 0 {
		return nil, fmt.Errorf("no products found matching: %s", productName)
	}

	return products, nil
}

// getUserTopCategories retrieves a user's most frequently ordered product categories
func getUserTopCategories(ctx context.Context, userObjID primitive.ObjectID) ([]bson.M, error) {
	conn := db.GetDatabase()
	userCollection := conn.Collection("users")

	// Pipeline to find the user's most ordered categories
	userPipeline := []bson.M{
		// Match the specific user
		{"$match": bson.M{"_id": userObjID}},
		// Unwind to get each invoice separately
		{"$unwind": "$invoices"},
		// Unwind to get each product in order
		{"$unwind": "$invoices.order.products"},
		// Lookup to get product details including category
		{
			"$lookup": bson.M{
				"from": "products",
				"let":  bson.M{"productId": "$invoices.order.products.productId"},
				"pipeline": []bson.M{
					{"$match": bson.M{"$expr": bson.M{"$eq": []any{"$_id", bson.M{"$toObjectId": "$$productId"}}}}},
				},
				"as": "productDetails",
			},
		},
		// Unwind product details
		{"$unwind": "$productDetails"},
		// Extract categories
		{"$project": bson.M{
			"category": bson.M{
				"$map": bson.M{
					"input": bson.M{"$split": []any{"$productDetails.category", ", "}},
					"as":    "item",
					"in":    bson.M{"$trim": bson.M{"input": "$$item"}},
				},
			},
			"quantity": "$invoices.order.products.quantity",
		}},
		// Unwind categories to count them individually
		{"$unwind": "$category"},
		// Group by category and sum the quantities
		{"$group": bson.M{
			"_id":      "$category",
			"category": bson.M{"$first": "$category"},
			"count":    bson.M{"$sum": 1},
			"totalQty": bson.M{"$sum": "$quantity"},
		}},
		// Sort by count (primary) and total quantity (secondary) in descending order
		{"$sort": bson.M{
			"count":    -1,
			"totalQty": -1,
		}},
		// Limit to top 3 categories
		{"$limit": 3},
	}

	cursor, err := userCollection.Aggregate(ctx, userPipeline)
	if err != nil {
		return nil, fmt.Errorf("error analyzing user orders: %v", err)
	}
	defer cursor.Close(ctx)

	var results []bson.M
	if err = cursor.All(ctx, &results); err != nil {
		return nil, fmt.Errorf("error retrieving user category data: %v", err)
	}

	return results, nil
}

// getAllActivePromotions retrieves all currently active promotions
func getAllActivePromotions(ctx context.Context) ([]entities.PromoResponse, error) {
	conn := db.GetDatabase()
	promoCollection := conn.Collection("promotions")

	// Query for active promotions
	allPromosPipeline := []bson.M{
		{"$match": bson.M{
			"status":   "active",
			"end_date": bson.M{"$gte": time.Now().Format(time.RFC3339)},
		}},
	}

	promoCursor, err := promoCollection.Aggregate(ctx, allPromosPipeline)
	if err != nil {
		return nil, fmt.Errorf("error finding active promotions: %v", err)
	}
	defer promoCursor.Close(ctx)

	var allPromotions []entities.PromoResponse
	if err = promoCursor.All(ctx, &allPromotions); err != nil {
		return nil, fmt.Errorf("error retrieving all promotion data: %v", err)
	}

	return allPromotions, nil
}

// getPromotionsForCategories retrieves promotions that match specific product categories
func getPromotionsForCategories(ctx context.Context, categories []bson.M) ([]entities.PromoResponse, error) {
	fmt.Printf("categories: %v\n", categories)
	conn := db.GetDatabase()
	promoCollection := conn.Collection("promotions")

	// Create the $or conditions for category matching
	categoryConditions := make([]bson.M, 0, len(categories))
	for _, category := range categories {
		categoryConditions = append(categoryConditions,
			bson.M{"products.category": bson.M{"$regex": category["category"].(string), "$options": "i"}})
	}

	// Pipeline to find promotions with products in the top categories
	promoPipeline := []bson.M{

		{"$unwind": "$products"},
		{"$match": bson.M{
			"$or":      categoryConditions,
			"status":   "active",
			"end_date": bson.M{"$gte": time.Now().Format(time.RFC3339)},
		}},
		{"$group": bson.M{
			"_id":            "$_id",
			"name":           bson.M{"$first": "$name"},
			"description":    bson.M{"$first": "$description"},
			"discount_type":  bson.M{"$first": "$discount_type"},
			"discount_value": bson.M{"$first": "$discount_value"},
			"code":           bson.M{"$first": "$code"},
			"start_date":     bson.M{"$first": "$start_date"},
			"end_date":       bson.M{"$first": "$end_date"},
			"min_purchase":   bson.M{"$first": "$min_purchase"},
			"products":       bson.M{"$push": "$products"},
		}},
	}

	promoCursor, err := promoCollection.Aggregate(ctx, promoPipeline)
	if err != nil {
		return nil, fmt.Errorf("error finding matching promotions: %v", err)
	}
	defer promoCursor.Close(ctx)

	var promotions []entities.PromoResponse
	if err = promoCursor.All(ctx, &promotions); err != nil {
		return nil, fmt.Errorf("error retrieving promotion data: %v", err)
	}

	return promotions, nil
}

// GetUserRecommendedPromotions retrieves promotions that match a user's most frequently ordered product category
func GetUserRecommendedPromotions(userId string) ([]entities.PromoResponse, error) {
	ctx := context.TODO()

	// Convert string ID to ObjectID
	userObjID, err := primitive.ObjectIDFromHex(userId)
	if err != nil {
		return nil, fmt.Errorf("invalid user ID format")
	}

	// Get the user's top categories
	categories, err := getUserTopCategories(ctx, userObjID)
	if err != nil {
		return nil, err
	}

	// If user has no order history, return all active promotions
	if len(categories) == 0 {
		return getAllActivePromotions(ctx)
	}

	// Get promotions matching the user's top categories
	return getPromotionsForCategories(ctx, categories)
}

func GetAllDeals() ([]entities.PromoResponse, error) {
	conn := db.GetDatabase()
	ctx := context.TODO()
	promoCollection := conn.Collection("promotions")

	// Query for active promotions
	allPromosPipeline := []bson.M{
		{"$match": bson.M{
			"discount_type": "bogo",
			"end_date":      bson.M{"$gte": time.Now().Format(time.RFC3339)},
		}},
	}

	promoCursor, err := promoCollection.Aggregate(ctx, allPromosPipeline)
	if err != nil {
		return nil, fmt.Errorf("error finding active deals: %v", err)
	}
	defer promoCursor.Close(ctx)

	var allDeals []entities.PromoResponse
	if err = promoCursor.All(ctx, &allDeals); err != nil {
		return nil, fmt.Errorf("error retrieving all deals data: %v", err)
	}

	return allDeals, nil
}
