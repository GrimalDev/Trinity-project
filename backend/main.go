package main

import (
	"log"
	"os"
	"trinity/backend/auth/middlewares"
	"trinity/backend/db"
	seed "trinity/backend/db/seeds"
	"trinity/backend/items/models"
	"trinity/backend/routes"
	"trinity/backend/validators"

	validator "github.com/go-playground/validator/v10"
	echojwt "github.com/labstack/echo-jwt/v4"
	echo "github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	// Get port from environment variable or use default
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Println("Starting the server")

	log.Println("Testing the database connection")
	conn := db.GetDatabase()
	if conn == nil {
		log.Fatal("Connection to the database failed")
	}
	log.Println("Connection to the database successful")

	err_seed := seed.SeedAll(conn)
	if err_seed != nil {
		log.Fatal("Error seeding the database", err_seed)
	}

	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	// Register validator
	e.Validator = &validators.CustomValidator{Validator: validator.New()}

	// Public Routes
	routes.PublicRoutes(e)

	// Create a group for protected routes
	protectedGroup := e.Group("")

	// Apply JWT middleware only to the protected group
	protectedGroup.Use(echojwt.WithConfig(middlewares.ConfigJwt))
	protectedGroup.Use(middlewares.Permission())

	// Register protected routes
	routes.UserRoutes(protectedGroup)
	routes.InvoiceRoutes(protectedGroup)
	routes.ProductRoutes(protectedGroup)
	routes.ReportGroup(protectedGroup)
	routes.StatsRoutes(protectedGroup)
	routes.PaymentRoutes(protectedGroup)
	routes.PushNotificationRoutes(protectedGroup)

	_, err := os.Stat("com-baptistegrimaldi-trinity-firebase.json")
	if err == nil {
		log.Println("Firebase authentication file found")
		fcmService, err := models.InitFCMService("com-baptistegrimaldi-trinity-firebase.json")
		if err != nil {
			log.Fatal("Failed to initialize FCM service ", err)
		} else {
			log.Println("FCM service initialized")
		}
		models.SetFCMService(fcmService)
	} else {
		log.Println("Firebase authentication file not found")
	}

	e.Logger.Fatal(e.Start(":" + port))
	log.Println("Server started ! Listening on port", port)
}
