package controllers

import (
	"context"
	"fmt"
	"math"
	"net/http"
	"os"
	"sort"
	"strconv"
	"time"

	"trinity/backend/items/entities"
	"trinity/backend/items/models"

	echo "github.com/labstack/echo/v4"
	paypal "github.com/plutov/paypal/v4"
)

func CreatePayment(c echo.Context) error {
	type CartItem struct {
		ProductID string `json:"productId" validate:"required"`
		Quantity  int    `json:"quantity" validate:"required,gt=0"`
	}
	var req struct {
		Cart []CartItem `json:"cart" validate:"required,dive"`
	}
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request payload"})
	}
	if err := c.Validate(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "request malformed"})
	}

	// Get user information for promotion processing
	user, ok := c.Get("user").(entities.UserBasicStruct)
	if !ok {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "user not authenticated"})
	}

	//cancel the last invoice before creating a new one
	_, err := models.CancelLastInvoice(c)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "failed to cancel last invoice: " + err.Error(),
		})
	}

	// Fetch applicable promotions for this user
	promotions, err := models.GetUserRecommendedPromotions(user.Id)
	if err != nil {
		// Log the error but continue - we'll just process without promotions
		fmt.Printf("Error fetching promotions: %v\n", err)
	}

	var subtotalPrice float64
	var orderProducts []entities.OrderProductStruct
	productMap := make(map[string]entities.ProductStruct)
	quantityMap := make(map[string]int)

	// First, fetch all products in the cart
	fmt.Printf("req: %v\n", req)
	for _, item := range req.Cart {
		// Fetch product details from database
		product, err := models.GetProductById(item.ProductID)
		if err != nil {
			return c.JSON(http.StatusBadRequest, map[string]string{
				"error": fmt.Sprintf("Failed to find product with ID %s: %v", item.ProductID, err),
			})
		}

		// Store product in map for later use
		productMap[item.ProductID] = product
		quantityMap[item.ProductID] = item.Quantity

		// Add to subtotal
		itemPrice := product.PriceVat * float64(item.Quantity)
		subtotalPrice += itemPrice
	}

	// Calculate discounts based on promotions
	totalDiscount := 0.0

	// Apply promotion logic similar to the frontend
	for _, promo := range promotions {
		// Get eligible product IDs for this promotion
		eligibleProductIds := make([]string, 0)
		for _, product := range promo.Products {
			productID := product.Id
			if _, exists := productMap[productID]; exists {
				eligibleProductIds = append(eligibleProductIds, productID)
			}
		}

		// Skip this promotion if no eligible products are in the cart
		if len(eligibleProductIds) == 0 {
			continue
		}

		// Log eligible products for debugging
		fmt.Printf("Applying promotion %s to products: %v\n", promo.Id, eligibleProductIds)

		switch promo.DiscountType {
		case "percentage":
			// Calculate subtotal of only eligible products
			eligibleSubtotal := 0.0
			for _, prodID := range eligibleProductIds {
				if product, ok := productMap[prodID]; ok {
					quantity := quantityMap[prodID]
					eligibleSubtotal += product.PriceVat * float64(quantity)
				}
			}

			// Apply percentage discount only to eligible products
			totalDiscount += (eligibleSubtotal * promo.DiscountValue / 100)

		case "fixed":
			// Apply fixed discount if eligible products are in cart
			totalDiscount += promo.DiscountValue

		case "bogo":
			// Apply BOGO to each eligible product individually
			for _, prodID := range eligibleProductIds {
				if product, ok := productMap[prodID]; ok {
					quantity := quantityMap[prodID]
					// Calculate how many free items they get (one free for every one purchased)
					freePairs := quantity / 2 // Integer division to get pairs
					if freePairs > 0 {
						// Add discount for each free item
						totalDiscount += product.PriceVat * float64(freePairs)
					}
				}
			}

		}
	}

	// Calculate final price after discounts
	// This includes ALL products in the subtotal, but discounts only apply to eligible products
	totalPrice := max(subtotalPrice-totalDiscount, 0)
	fmt.Printf("Calculation breakdown: Subtotal=%.2f, Discount=%.2f, Final=%.2f\n",
		subtotalPrice, totalDiscount, totalPrice)

	for _, item := range req.Cart {
		if product, exists := productMap[item.ProductID]; exists {
			price := product.PriceVat * float64(item.Quantity)
			orderProducts = append(orderProducts, entities.OrderProductStruct{
				ProductId: product.Id,
				Quantity:  item.Quantity,
				Price:     price,
			})
		}
	}

	order := entities.OrderStruct{
		Date:          time.Now(),
		Status:        "pending",
		PaymentMethod: "PAYPAL",
		Products:      orderProducts,
	}

	invoice := entities.InvoiceStruct{
		Date:           time.Now().Format(time.RFC3339),
		TotalPrice:     totalPrice,
		Subtotal:       subtotalPrice,
		DiscountAmount: totalDiscount,
		Order:          order,
		Archived:       false,
	}

	invoiceInserted, err := models.CreateInvoiceSelf(c, invoice)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "failed to save order: " + err.Error(),
		})
	}

	return c.JSON(http.StatusOK, map[string]string{
		"message":   "Order created successfully",
		"invoiceId": invoiceInserted.Id,
	})
}

func CapturePayment(c echo.Context) error {
	user, ok := c.Get("user").(entities.UserBasicStruct)
	if !ok {
		return c.JSON(http.StatusUnauthorized, map[string]string{"error": "user not authenticated"})
	}

	var req struct {
		PaypalOrderID string `json:"paypalOrderId" validate:"required"`
	}
	if err := c.Bind(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "invalid request payload"})
	}
	if err := c.Validate(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "request malformed"})
	}

	// Initialize PayPal client
	paypalClient, err := paypal.NewClient(
		os.Getenv("PAYPAL_CLIENT_ID"),
		os.Getenv("PAYPAL_SECRET"),
		os.Getenv("PAYPAL_API_BASE"),
	)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{
			"error": "failed to initialize PayPal client: " + err.Error(),
		})
	}

	// Fetch PayPal order details
	order, err := paypalClient.GetOrder(context.Background(), req.PaypalOrderID)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error": "failed to retrieve PayPal order details: " + err.Error(),
		})
	}

	// Extract total amount from PayPal order
	var totalAmount float64
	for _, purchaseUnit := range order.PurchaseUnits {
		if len(order.PurchaseUnits) > 0 && purchaseUnit.Amount != nil {
			paypalAmount, err := strconv.ParseFloat(purchaseUnit.Amount.Value, 64)
			if err != nil {
				return c.JSON(http.StatusInternalServerError, map[string]string{
					"error": "failed to parse PayPal order amount: " + err.Error(),
				})
			}
			totalAmount += paypalAmount
		} else {
			return c.JSON(http.StatusBadRequest, map[string]string{
				"error": "no purchase units found in PayPal order",
			})
		}
	}

	userDetailed, err := models.GetUserDetails(user.Id)
	if err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "user not found"})
	}

	invoices := userDetailed.Invoices

	if len(invoices) == 0 {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "pending invoice not found"})
	}

	sort.Slice(invoices, func(i, j int) bool {
		return invoices[i].Date > invoices[j].Date
	})

	pendingInvoice := invoices[0]

	// Verify that the amount matches
	// Allow for a small difference (0.01) to account for floating point precision issues
	if math.Abs(pendingInvoice.TotalPrice-totalAmount) > 0.01 {
		// Don't update invoice if amounts don't match
		return c.JSON(http.StatusBadRequest, map[string]string{
			"error":    "payment amount does not match order total",
			"expected": fmt.Sprintf("%.2f", pendingInvoice.TotalPrice),
			"received": fmt.Sprintf("%.2f", totalAmount),
		})
	}

	pendingInvoice.Order.Status = "paid"

	invoiceValid, err := models.UpdateInvoiceSelf(c, pendingInvoice)

	if err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "order not found or already updated"})
	}

	return c.JSON(http.StatusOK, map[string]string{
		"message":   "Order updated successfully",
		"invoiceId": invoiceValid.Id,
	})
}

func ReturnPayment(c echo.Context) error {
	return c.Redirect(http.StatusFound, "com.baptistegrimaldi.trinity://paypalpay")
}
