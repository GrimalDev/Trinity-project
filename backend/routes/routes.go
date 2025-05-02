package routes

import (
	"trinity/backend/controllers"

	echo "github.com/labstack/echo/v4"
)

func PublicRoutes(e *echo.Echo) {

	// Add routes to the public group
	e.POST("/user", controllers.CreateUser) // Create a new user
	e.POST("/user/login", controllers.LoginUser)

	e.GET("/product/barcode/:barcode", controllers.GetProductsByBarcode)
	e.GET("/product/search/:name", controllers.GetProductsBySearch)

	e.GET("/promo/deals", controllers.GetDeals)

	e.GET("/payment/return", controllers.ReturnPayment)
}

func UserRoutes(e *echo.Group) {
	// Create a group for user-related routes
	userGroup := e.Group("/user")

	// Add routes to the user group
	userGroup.GET("", controllers.GetUsers) // Get all users
	userGroup.GET("/self", controllers.GetSelfUserBasic)
	userGroup.GET("/:id", controllers.GetUserBasic)
	userGroup.GET("/details/self", controllers.GetSelfDetails)
	userGroup.GET("/details/:id", controllers.GetUserDetails)
	// userGroup.POST("", controllers.CreateUser) // Create a new user
	userGroup.PUT("/self", controllers.UpdateSelfUser)
	userGroup.PUT("/self/password", controllers.UpdateSelfPassword)
	userGroup.PUT("/:id", controllers.UpdateOtherUser)
	userGroup.DELETE("/self", controllers.ArchiveSelfUser)
	userGroup.DELETE("/:id", controllers.ArchiveUser)

	// userGroup.POST("/login", controllers.LoginUser)
}

func InvoiceRoutes(e *echo.Group) {

	invoiceGroup := e.Group("/invoice")

	invoiceGroup.GET("", controllers.GetInvoices)
	invoiceGroup.GET("/self", controllers.GetSelfInvoices)
	invoiceGroup.GET("/self/:id", controllers.GetSelfInvoicesById)
	invoiceGroup.GET("/history/self", controllers.GetHistorySelfInvoices)
	invoiceGroup.POST("", controllers.CreateInvoice)
	// invoiceGroup.PUT("/:id", controllers.UpdateInvoice)
	invoiceGroup.DELETE("/:id", controllers.ArchiveInvoice)
}

func ProductRoutes(e *echo.Group) {

	productGroup := e.Group("/product")

	productGroup.GET("", controllers.GetProducts)
	// productGroup.GET("/barcode/:barcode", controllers.GetProductsByBarcode)
	productGroup.POST("", controllers.AddProduct)
	productGroup.PUT("/:id", controllers.UpdateProduct)
	productGroup.DELETE("/:id", controllers.ArchiveProduct)

	productGroup.GET("/promo/self", controllers.GetSelfPromo)
}

func StatsRoutes(e *echo.Group) {

	productGroup := e.Group("/stats")

	productGroup.GET("/earnings", controllers.GetEarnings)
	productGroup.GET("/user_total", controllers.GetTotalUser)
	productGroup.GET("/commande_total", controllers.GetTotalCommande)
	productGroup.GET("/average_spending", controllers.GetAverageSpending)
	productGroup.GET("/total_product_sold", controllers.GetTotalProductSold)
	productGroup.GET("/total_categories", controllers.GetTotalCategories)
	productGroup.GET("/total_product_stock", controllers.GetTotalProductStock)
	productGroup.GET("/average_product_cost", controllers.GetAverageProductCost)
	productGroup.GET("/products_per_category", controllers.GetProductsPerCategory)
}

func ReportGroup(e *echo.Group) {

	reportGroup := e.Group("/report")

	reportGroup.GET("", controllers.GetReports)

}

func PaymentRoutes(e *echo.Group) {
	paymentGroup := e.Group("/payment")

	paymentGroup.POST("/create", controllers.CreatePayment)
	paymentGroup.POST("/capture", controllers.CapturePayment)
}

func PushNotificationRoutes(e *echo.Group) {
	pushNotificationGroup := e.Group("/push-notification")

	pushNotificationGroup.POST("/register-token", controllers.RegisterToken)
	pushNotificationGroup.POST("/notify", controllers.NotifyHandler)
}
