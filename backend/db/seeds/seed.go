package seed

import (
	"context"
	"fmt"
	"log"
	"time"
	"trinity/backend/items/entities"
	"trinity/backend/items/models"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func SeedAll(db *mongo.Database) error {

	// Initialize collections
	if err := InitializeCities(db); err != nil {
		return err
	}
	if err := InitializeProducts(db); err != nil {
		return err
	}
	if err := InitialiseSuppliers(db); err != nil {
		return err
	}
	if err := InitializeRoles(db); err != nil {
		return err
	}
	if err := InitializeUsers(db); err != nil {
		return err
	}
	if err := InitializePromotions(db); err != nil {
		return err
	}

	log.Println("MongoDB initialization completed successfully.")

	return nil
}

// ... existing code ...
func createUserEmailIndex(db *mongo.Database) error {
	collection := db.Collection("users")
	_, err := collection.Indexes().CreateOne(
		context.Background(),
		mongo.IndexModel{
			Keys:    bson.D{primitive.E{Key: "email", Value: 1}},
			Options: options.Index().SetUnique(true),
		},
	)
	if err != nil {
		return fmt.Errorf("error creating unique index on users email: %v", err)
	}
	return nil
}

func createSupplierEmailIndex(db *mongo.Database) error {
	collection := db.Collection("suppliers")
	_, err := collection.Indexes().CreateOne(
		context.Background(),
		mongo.IndexModel{
			Keys:    bson.D{primitive.E{Key: "email", Value: 1}},
			Options: options.Index().SetUnique(true),
		},
	)
	if err != nil {
		return fmt.Errorf("error creating unique index on suppliers email: %v", err)
	}

	return nil
}

func createProductReferenceIndex(db *mongo.Database) error {
	collection := db.Collection("products")
	_, err := collection.Indexes().CreateOne(
		context.Background(),
		mongo.IndexModel{
			Keys:    bson.D{primitive.E{Key: "reference", Value: 1}},
			Options: options.Index().SetUnique(true),
		},
	)
	if err != nil {
		return fmt.Errorf("error creating unique index on product reference: %v", err)
	}
	return nil
}

func createPromotionCodeIndex(db *mongo.Database) error {
	collection := db.Collection("promotions")
	_, err := collection.Indexes().CreateOne(
		context.Background(),
		mongo.IndexModel{
			Keys:    bson.D{primitive.E{Key: "code", Value: 1}},
			Options: options.Index().SetUnique(true),
		},
	)
	if err != nil {
		return fmt.Errorf("error creating unique index on promotion code: %v", err)
	}
	return nil
}

func InitializeUsers(db *mongo.Database) error {
	collection := db.Collection("users")

	// Create unique email index for users
	if err := createUserEmailIndex(db); err != nil {
		log.Printf("Error creating unique email index for users: %v", err)
	}

	// Check if collection is empty
	count, err := collection.CountDocuments(context.Background(), bson.D{})
	if err != nil {
		log.Fatalf("Error checking users collection: %v", err)
		return err
	}

	firstCity, err := models.GetCityByName("Paris")
	if err != nil {
		log.Fatalf("Error retrieving city: %v", err)
	}

	firstProduct, err := models.GetProductByName("Test Product")

	if err != nil {
		log.Fatalf("Error retrieving product 'Test Product': %v", err)
	}

	product1, err := models.GetProductByReference("8410261718217")
	if err != nil {
		log.Fatalf("Error retrieving product '8410261718217': %v", err)
	}

	product2, err := models.GetProductByReference("7622210100917")
	if err != nil {
		log.Fatalf("Error retrieving product '7622210100917': %v", err)
	}

	employeeRole, err := models.GetRoleByName("employee")
	if err != nil {
		log.Fatalf("Error retrieving 'employee' role: %v", err)
	}

	roleAdmin, err := models.GetRoleByName("admin")
	if err != nil {
		log.Fatalf("Error retrieving 'admin' role: %v", err)
	}

	if count == 0 {
		_, errUser1 := models.SuperCreateUser(entities.UserStruct{
			FirstName:   "John",
			LastName:    "Doe",
			Email:       "john.doe@mail.com",
			Password:    "b2867617492e26c338ab49f72afabc984d798b59755a27e312b953716ae964d7",
			PhoneNumber: "1234567890",
			City:        firstCity,
			Address:     "123 Main St",
			Roles:       []entities.RoleStruct{employeeRole},
			DeviceToken: "ExponentPushToken[john-doe-device-token-1]",
			Invoices: []entities.InvoiceStruct{
				{
					Id:             primitive.NewObjectID().Hex(),
					Date:           time.Now().Format(time.RFC3339),
					Subtotal:       firstProduct.PriceVat,
					DiscountAmount: 1.5,
					TotalPrice:     firstProduct.PriceVat - 1.5,
					Order: entities.OrderStruct{
						Id:            primitive.NewObjectID().Hex(),
						Date:          time.Now(),
						Status:        "paid",
						PaymentMethod: "PAYPAL",
						PaymentInfo: entities.PaymentInfo{
							ServiceOrderID: primitive.NewObjectID().Hex(),
							PaypalOrderID:  primitive.NewObjectID().Hex(),
							Status:         "COMPLETED",
						},
						Products: []entities.OrderProductStruct{
							{
								ProductId: firstProduct.Id,
								Quantity:  1,
								Price:     firstProduct.PriceVat,
							},
						},
					},
				},
				{
					Id:             primitive.NewObjectID().Hex(),
					Date:           time.Now().Format(time.RFC3339),
					Subtotal:       product1.PriceVat * 3,
					DiscountAmount: 3.0,
					TotalPrice:     (product1.PriceVat * 3) - 3.0,
					Order: entities.OrderStruct{
						Id:            primitive.NewObjectID().Hex(),
						Date:          time.Now(),
						Status:        "paid",
						PaymentMethod: "PAYPAL",
						PaymentInfo: entities.PaymentInfo{

							ServiceOrderID: primitive.NewObjectID().Hex(),
							PaypalOrderID:  primitive.NewObjectID().Hex(),
							Status:         "COMPLETED",
						},
						Products: []entities.OrderProductStruct{
							{
								ProductId: product1.Id,
								Quantity:  3,
								Price:     product1.PriceVat * 3,
							},
						},
					},
				},

				{
					Id:             primitive.NewObjectID().Hex(),
					Date:           time.Now().Format(time.RFC3339),
					Subtotal:       product2.PriceVat * 8,
					DiscountAmount: 5.0,
					TotalPrice:     (product2.PriceVat * 8) - 5.0,
					Order: entities.OrderStruct{
						Id:            primitive.NewObjectID().Hex(),
						Date:          time.Now(),
						Status:        "paid",
						PaymentMethod: "PAYPAL",
						PaymentInfo: entities.PaymentInfo{
							ServiceOrderID: primitive.NewObjectID().Hex(),
							PaypalOrderID:  primitive.NewObjectID().Hex(),
							Status:         "COMPLETED",
						},
						Products: []entities.OrderProductStruct{
							{
								ProductId: product2.Id,
								Quantity:  8,
								Price:     product2.PriceVat * 8,
							},
						},
					},
				},
			},
			Reports: []entities.ReportStruct{
				{
					ReportType: "type de rapport",
					Date:       time.Now().Format(time.RFC3339),
					ReportData: "Données du rapport",
				},
			},
			Logs: []entities.LogStruct{
				{
					TableName:  "report",
					ActionType: "alert",
					ModifiedAt: time.Now().Format(time.RFC3339),
				},
			},
		})
		if errUser1 != nil {
			log.Fatalf("Error creating user 1: %v", err)
		}

		_, errUser2 := models.SuperCreateUser(entities.UserStruct{
			FirstName:   "Machine",
			LastName:    "Dupond",
			Email:       "asdf.est@mail.com",
			Password:    "b2867617492e26c338ab49f72afabc984d798b59755a27e312b953716ae964d7",
			PhoneNumber: "1234567890",
			City:        firstCity,
			Address:     "123 Main St",
			Roles:       []entities.RoleStruct{employeeRole},
			DeviceToken: "ExponentPushToken[machine-dupond-device-token-2]",
			Invoices: []entities.InvoiceStruct{
				{
					Id:             primitive.NewObjectID().Hex(),
					Date:           time.Now().Format(time.RFC3339),
					Subtotal:       firstProduct.PriceVat,
					DiscountAmount: 2.0,
					TotalPrice:     firstProduct.PriceVat - 2.0,
					Order: entities.OrderStruct{
						Id:            primitive.NewObjectID().Hex(),
						Date:          time.Now(),
						Status:        "paid",
						PaymentMethod: "PAYPAL",
						PaymentInfo: entities.PaymentInfo{
							ServiceOrderID: primitive.NewObjectID().Hex(),
							PaypalOrderID:  primitive.NewObjectID().Hex(),
							Status:         "COMPLETED",
						},
						Products: []entities.OrderProductStruct{
							{
								ProductId: firstProduct.Id,
								Quantity:  1,
								Price:     firstProduct.PriceVat,
							},
						},
					},
				},
			},
			Reports: []entities.ReportStruct{
				{
					ReportType: "type de rapport",
					Date:       time.Now().Format(time.RFC3339),
					ReportData: "Données du rapport",
				},
			},
			Logs: []entities.LogStruct{
				{
					TableName:  "report",
					ActionType: "alert",
					ModifiedAt: time.Now().Format(time.RFC3339),
				},
			},
		})
		if errUser2 != nil {
			log.Fatalf("Error creating user 2: %v", err)
		}

		_, errUser3 := models.SuperCreateUser(entities.UserStruct{
			FirstName:   "Linus",
			LastName:    "Torvalds",
			Email:       "linus.torvalds@mail.com",
			Password:    "b2867617492e26c338ab49f72afabc984d798b59755a27e312b953716ae964d7",
			PhoneNumber: "1234567890",
			City:        firstCity,
			Address:     "435 troll lane",
			Roles:       []entities.RoleStruct{roleAdmin},
			DeviceToken: "ExponentPushToken[linus-torvalds-device-token-3]",
			Logs: []entities.LogStruct{
				{
					TableName:  "users",
					ActionType: "update",
					ModifiedAt: time.Now().Format(time.RFC3339),
				},
			},
			Invoices: []entities.InvoiceStruct{},
			Reports:  []entities.ReportStruct{},
		})
		if errUser3 != nil {
			log.Fatalf("Error creating user 3: %v", err)
		}
		log.Println("Collection 'users' initialized.")
	} else {
		log.Println("Collection 'users' already initialized.")
	}
	return nil
}

func InitializeProducts(db *mongo.Database) error {
	collection := db.Collection("products")

	// Create unique reference index for products
	if err := createProductReferenceIndex(db); err != nil {
		log.Printf("Error creating unique reference index for products: %v", err)
	}

	// Vérifie si la collection est vide
	count, err := collection.CountDocuments(context.Background(), bson.D{})
	if err != nil {
		log.Fatalf("Error checking products collection: %v", err)
		return err
	}

	if count == 0 {
		// _, err := models.CreateProduct(entities.ProductStruct{
		// 	Images: entities.ImagesStruct{
		// 		S:  "http://example.com/image.jpg",
		// 		XL: "http://example.com/image.jpg",
		// 	},
		// 	Reference:              "1234567890",
		// 	PriceVat:               10,
		// 	PriceNot:               8,
		// 	StockQuantity:          100,
		// 	Name:                   "Produit A",
		// 	Brand:                  "Marque A",
		// 	Category:               "Catégorie A",
		// 	PictureUrl:             "http://example.com/image.jpg",
		// 	NutritionalInformation: "Information nutritionnelle",
		// })
		_, err := models.CreateProduct(entities.ProductBasic{
			Reference:     "1234567890",
			PriceVat:      9.6,
			PriceNot:      8,
			StockQuantity: 1400,
		})
		if err != nil {
			log.Fatalf("Error creating product '1234567890': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "8410261718217",
			PriceVat:      6,
			PriceNot:      5,
			StockQuantity: 130,
		})
		if err != nil {
			log.Fatalf("Error creating product '8410261718217': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "7622210100917",
			PriceVat:      9.6,
			PriceNot:      8,
			StockQuantity: 400,
		})

		if err != nil {
			log.Fatalf("Error creating product '7622210100917': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "9002490246594",
			PriceVat:      48,
			PriceNot:      40,
			StockQuantity: 823,
		})
		if err != nil {
			log.Fatalf("Error creating product '9002490246594': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "5449000195340",
			PriceVat:      6,
			PriceNot:      5,
			StockQuantity: 1233,
		})
		if err != nil {
			log.Fatalf("Error creating product '5449000195340': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "3174780000363",
			PriceVat:      3,
			PriceNot:      2.50,
			StockQuantity: 12,
		})
		if err != nil {
			log.Fatalf("Error creating product '3174780000363': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "8000500426494",
			PriceVat:      4.2,
			PriceNot:      3.50,
			StockQuantity: 12,
		})

		if err != nil {
			log.Fatalf("Error creating product '8000500426494': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "3350033972766",
			PriceVat:      2.5,
			PriceNot:      2.63,
			StockQuantity: 20,
		})

		if err != nil {
			log.Fatalf("Error creating product '3350033972766': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "3513851561318",
			PriceVat:      2.20,
			PriceNot:      2.32,
			StockQuantity: 20,
		})

		if err != nil {
			log.Fatalf("Error creating product '3513851561318': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "9002490255916",
			PriceVat:      2.49,
			PriceNot:      2.62,
			StockQuantity: 20,
		})

		if err != nil {
			log.Fatalf("Error creating product '9002490255916': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "8718868006080",
			PriceVat:      2.80,
			PriceNot:      2.95,
			StockQuantity: 20,
		})

		if err != nil {
			log.Fatalf("Error creating product '8718868006080': %v", err)
			return err
		}

		_, err = models.CreateProduct(entities.ProductBasic{
			Reference:     "3350030216412",
			PriceVat:      1.99,
			PriceNot:      2.09,
			StockQuantity: 20,
		})

		if err != nil {
			log.Fatalf("Error creating product '3350030216412': %v", err)
			return err
		}

		log.Println("Collection 'products' initialized.")
	} else {
		log.Println("Collection 'products' already initialized.")
	}
	return nil
}

func InitializeCities(db *mongo.Database) error {
	collection := db.Collection("cities")

	// Vérifie si la collection est vide
	count, err := collection.CountDocuments(context.Background(), bson.D{})
	if err != nil {
		log.Fatalf("Error checking cities collection: %v", err)
		return err
	}

	if count == 0 {
		_, err = models.CreateCity(entities.CityStruct{
			Name:       "Paris",
			PostalCode: "75000",
			Country:    "France",
		})

		if err != nil {
			log.Fatalf("Error initializing cities collection: %v", err)
			return err
		}
		log.Println("Collection 'cities' initialized.")
	} else {
		log.Println("Collection 'cities' already initialized.")
	}
	return nil
}

func InitialiseSuppliers(db *mongo.Database) error {
	collection := db.Collection("suppliers")

	// Create unique email index for suppliers
	if err := createSupplierEmailIndex(db); err != nil {
		log.Printf("Error creating unique email index for suppliers: %v", err)
	}
	// Vérifie si la collection est vide
	count, err := collection.CountDocuments(context.Background(), bson.D{})
	if err != nil {
		log.Fatalf("Error checking suppliers collection: %v", err)
		return err
	}
	firstCity, err := models.GetCityByName("Paris")

	if err != nil {
		log.Fatalf("Error retrieving city: %v", err)
	}

	firstProduct, err := models.GetProductByName("Test Product")
	if err != nil {
		log.Fatalf("Error retrieving product: %v", err)
	}
	if count == 0 {

		_, err = models.CreateSupplier(entities.SupplierStruct{
			Name:        "Fournisseur A",
			City:        firstCity,
			Address:     "123 Main St",
			LegalStatus: "SARL",

			Invoices: []entities.InvoiceStruct{
				{
					Id:             primitive.NewObjectID().Hex(),
					Date:           time.Now().Format(time.RFC3339),
					Subtotal:       100,
					DiscountAmount: 10,
					TotalPrice:     90,
					Order: entities.OrderStruct{
						Id:     primitive.NewObjectID().Hex(),
						Date:   time.Now(),
						Status: "Completed",
						Products: []entities.OrderProductStruct{
							{
								ProductId: firstProduct.Id,
								Quantity:  1,
								Price:     firstProduct.PriceVat,
							},
						},
					},
				},
			},
		})
		if err != nil {
			log.Fatalf("Error initializing suppliers collection: %v", err)
			return err
		}
		log.Println("Collection 'suppliers' initialized.")
	} else {
		log.Println("Collection 'suppliers' already initialized.")
	}
	return nil
}

func InitializeRoles(db *mongo.Database) error {
	collection := db.Collection("roles")
	count, err := collection.CountDocuments(context.Background(), bson.D{})
	if err != nil {
		log.Fatalf("Error checking roles collection: %v", err)
		return err
	}
	if count == 0 {
		_, err := models.CreateRole(entities.RoleStruct{
			Name: "admin",
			Permissions: []entities.PermissionStruct{
				{Resource: "/*", Actions: []string{"GET:OTHER", "POST:OTHER", "PUT:OTHER", "DELETE:OTHER"}},
			},
		})
		if err != nil {
			log.Fatalf("Error initializing admin role collection: %v", err)
			return err
		}
		_, err = models.CreateRole(entities.RoleStruct{
			Name: "employee",
			Permissions: []entities.PermissionStruct{
				{Resource: "/product", Actions: []string{"GET:OTHER"}},
				{Resource: "/invoice", Actions: []string{"GET:OTHER"}},
				{Resource: "/user/self", Actions: []string{"GET", "POST", "PUT", "DELETE"}},
				{Resource: "/user/details/self", Actions: []string{"GET"}},
				{Resource: "/user/self/password", Actions: []string{"GET", "PUT"}},
				{Resource: "/invoice/self", Actions: []string{"GET"}},
				{Resource: "/invoice/self/:id", Actions: []string{"GET"}},
				{Resource: "/invoice/history/self", Actions: []string{"GET"}},
				{Resource: "/product/promo/self", Actions: []string{"GET"}},
				{Resource: "/payment/create", Actions: []string{"POST"}},
				{Resource: "/payment/capture", Actions: []string{"POST"}},
				{Resource: "/push-notification/register-token", Actions: []string{"POST"}},
			},
		})
		if err != nil {
			log.Fatalf("Error initializing employee role collection: %v", err)
			return err
		}

		_, err = models.CreateRole(entities.RoleStruct{
			Name: "user",
			Permissions: []entities.PermissionStruct{
				{Resource: "/user/self", Actions: []string{"GET", "POST", "PUT", "DELETE"}},
				{Resource: "/user/details/self", Actions: []string{"GET", "POST", "PUT"}},
				{Resource: "/user/self/password", Actions: []string{"GET", "PUT"}},
				{Resource: "/invoice/self", Actions: []string{"GET"}},
				{Resource: "/invoice/history/self", Actions: []string{"GET"}},
				{Resource: "/product/promo/self", Actions: []string{"GET"}},
				{Resource: "/payment/create", Actions: []string{"POST"}},
				{Resource: "/payment/capture", Actions: []string{"POST"}},
				{Resource: "/push-notification/register-token", Actions: []string{"POST"}},
			},
		})
		if err != nil {
			log.Fatalf("Error initializing user role collection: %v", err)
			return err
		}
		log.Println("Collection 'roles' initialized.")
	} else {
		log.Println("Collection 'roles' already initialized.")
	}
	return nil
}
func InitializePromotions(db *mongo.Database) error {
	collection := db.Collection("promotions")

	// Create unique code index for promotions
	if err := createPromotionCodeIndex(db); err != nil {
		log.Printf("Error creating unique code index for promotions: %v", err)
	}

	// Check if collection is empty
	count, err := collection.CountDocuments(context.Background(), bson.D{})
	if err != nil {
		log.Fatalf("Error checking promotions collection: %v", err)
		return err
	}

	// Get products for the promotions
	product9002490255916, err := models.GetProductByReference("9002490255916")
	if err != nil {
		log.Fatalf("Error retrieving product '9002490255916': %v", err)
		return err
	}

	product3513851561318, err := models.GetProductByReference("3513851561318")
	if err != nil {
		log.Fatalf("Error retrieving product '3513851561318': %v", err)
		return err
	}

	product3350030216412, err := models.GetProductByReference("3350030216412")
	if err != nil {
		log.Fatalf("Error retrieving product '3350030216412': %v", err)
		return err
	}

	// Get existing products
	firstProduct, err := models.GetProductByReference("1234567890")
	if err != nil {
		log.Fatalf("Error retrieving product '1234567890': %v", err)
		return err
	}

	product1, err := models.GetProductByReference("8410261718217")
	if err != nil {
		log.Fatalf("Error retrieving product '8410261718217': %v", err)
		return err
	}

	product2, err := models.GetProductByReference("7622210100917")
	if err != nil {
		log.Fatalf("Error retrieving product '7622210100917': %v", err)
		return err
	}

	if count == 0 {
		// Convert products to ProductOrder
		product9002490255916Order := entities.ProductOrder{
			Id:                     product9002490255916.Id,
			Reference:              product9002490255916.Reference,
			Images:                 product9002490255916.Images,
			PriceVat:               product9002490255916.PriceVat,
			Name:                   product9002490255916.Name,
			Brand:                  product9002490255916.Brand,
			Category:               product9002490255916.Category,
			NutritionalInformation: product9002490255916.NutritionalInformation,
		}

		product3513851561318Order := entities.ProductOrder{
			Id:                     product3513851561318.Id,
			Reference:              product3513851561318.Reference,
			Images:                 product3513851561318.Images,
			PriceVat:               product3513851561318.PriceVat,
			Name:                   product3513851561318.Name,
			Brand:                  product3513851561318.Brand,
			Category:               product3513851561318.Category,
			NutritionalInformation: product3513851561318.NutritionalInformation,
		}

		product3350030216412Order := entities.ProductOrder{
			Id:                     product3350030216412.Id,
			Reference:              product3350030216412.Reference,
			Images:                 product3350030216412.Images,
			PriceVat:               product3350030216412.PriceVat,
			Name:                   product3350030216412.Name,
			Brand:                  product3350030216412.Brand,
			Category:               product3350030216412.Category,
			NutritionalInformation: product3350030216412.NutritionalInformation,
		}

		firstProductOrder := entities.ProductOrder{
			Id:                     firstProduct.Id,
			Reference:              firstProduct.Reference,
			Images:                 firstProduct.Images,
			PriceVat:               firstProduct.PriceVat,
			Name:                   firstProduct.Name,
			Brand:                  firstProduct.Brand,
			Category:               firstProduct.Category,
			NutritionalInformation: firstProduct.NutritionalInformation,
		}

		product1Order := entities.ProductOrder{
			Id:                     product1.Id,
			Reference:              product1.Reference,
			Images:                 product1.Images,
			PriceVat:               product1.PriceVat,
			Name:                   product1.Name,
			Brand:                  product1.Brand,
			Category:               product1.Category,
			NutritionalInformation: product1.NutritionalInformation,
		}

		product2Order := entities.ProductOrder{
			Id:                     product2.Id,
			Reference:              product2.Reference,
			Images:                 product2.Images,
			PriceVat:               product2.PriceVat,
			Name:                   product2.Name,
			Brand:                  product2.Brand,
			Category:               product2.Category,
			NutritionalInformation: product2.NutritionalInformation,
		}

		// Insert sample promotions including the new ones
		promotions := []any{
			entities.PromotStruct{
				Id:            primitive.NewObjectID().Hex(),
				Name:          "Summer Sale",
				Description:   "Get 20% off on selected products",
				DiscountType:  "percentage",
				DiscountValue: 20,
				Code:          "SUMMER20",
				StartDate:     time.Now().Format(time.RFC3339),
				EndDate:       time.Now().Add(30 * 24 * time.Hour).Format(time.RFC3339),
				Products:      []entities.ProductOrder{firstProductOrder},
				MinPurchase:   0,
				Status:        "active",
				CreatedAt:     time.Now().Format(time.RFC3339),
				UpdatedAt:     time.Now().Format(time.RFC3339),
			},
			entities.PromotStruct{
				Id:            primitive.NewObjectID().Hex(),
				Name:          "Buy One Get One Free",
				Description:   "Buy one product and get another one free",
				DiscountType:  "bogo",
				DiscountValue: 100,
				Code:          "BOGOF",
				StartDate:     time.Now().Format(time.RFC3339),
				EndDate:       time.Now().Add(30 * 24 * time.Hour).Format(time.RFC3339),
				Products:      []entities.ProductOrder{product1Order},
				MinPurchase:   2,
				Status:        "active",
				CreatedAt:     time.Now().Format(time.RFC3339),
				UpdatedAt:     time.Now().Format(time.RFC3339),
			},
			entities.PromotStruct{
				Id:            primitive.NewObjectID().Hex(),
				Name:          "Flash Sale",
				Description:   "Get €5 off on order",
				DiscountType:  "fixed",
				DiscountValue: 5,
				Code:          "FLASH5",
				StartDate:     time.Now().Format(time.RFC3339),
				EndDate:       time.Now().Add(30 * 24 * time.Hour).Format(time.RFC3339),
				Products:      []entities.ProductOrder{product2Order, firstProductOrder},
				MinPurchase:   50,
				Status:        "active",
				CreatedAt:     time.Now().Format(time.RFC3339),
				UpdatedAt:     time.Now().Format(time.RFC3339),
			},
			// New promotions
			entities.PromotStruct{
				Id:            primitive.NewObjectID().Hex(),
				Name:          "BOGO Special",
				Description:   "Buy one, get one free",
				DiscountType:  "bogo",
				DiscountValue: 100,
				Code:          "BOGO9002490255916",
				StartDate:     time.Now().Format(time.RFC3339),
				EndDate:       time.Now().Add(30 * 24 * time.Hour).Format(time.RFC3339),
				Products:      []entities.ProductOrder{product9002490255916Order},
				MinPurchase:   2,
				Status:        "active",
				CreatedAt:     time.Now().Format(time.RFC3339),
				UpdatedAt:     time.Now().Format(time.RFC3339),
			},
			entities.PromotStruct{
				Id:            primitive.NewObjectID().Hex(),
				Name:          "Flat Discount",
				Description:   "Get 0.50€ off",
				DiscountType:  "fixed",
				DiscountValue: 0.50,
				Code:          "FLAT3513851561318",
				StartDate:     time.Now().Format(time.RFC3339),
				EndDate:       time.Now().Add(30 * 24 * time.Hour).Format(time.RFC3339),
				Products:      []entities.ProductOrder{product3513851561318Order},
				MinPurchase:   0,
				Status:        "active",
				CreatedAt:     time.Now().Format(time.RFC3339),
				UpdatedAt:     time.Now().Format(time.RFC3339),
			},
			entities.PromotStruct{
				Id:            primitive.NewObjectID().Hex(),
				Name:          "10% Discount",
				Description:   "Get 10% off",
				DiscountType:  "percentage",
				DiscountValue: 10,
				Code:          "RABAT3350030216412",
				StartDate:     time.Now().Format(time.RFC3339),
				EndDate:       time.Now().Add(30 * 24 * time.Hour).Format(time.RFC3339),
				Products:      []entities.ProductOrder{product3350030216412Order},
				MinPurchase:   0,
				Status:        "active",
				CreatedAt:     time.Now().Format(time.RFC3339),
				UpdatedAt:     time.Now().Format(time.RFC3339),
			},
		}

		_, err := collection.InsertMany(context.Background(), promotions)
		if err != nil {
			log.Fatalf("Error initializing promotions collection: %v", err)
			return err
		}

		log.Println("Collection 'promotions' initialized.")
	} else {
		log.Println("Collection 'promotions' already initialized.")
	}

	return nil
}
