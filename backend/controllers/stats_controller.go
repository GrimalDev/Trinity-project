package controllers

import (
	"net/http"
	"trinity/backend/items/entities"
	"trinity/backend/items/models"

	echo "github.com/labstack/echo/v4"
)

func GetEarnings(c echo.Context) error {
	earnings, err := models.GetEarnings()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting earnings"})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{
		"earnings": earnings,
	})
}

func GetTotalCommande(c echo.Context) error {
	invoices, err := models.GetInvoices(0, 100)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting total commande"})
	}

	return c.JSON(http.StatusOK, map[string]interface{}{"total_commande": len(invoices)})
}

func GetAverageSpending(c echo.Context) error {
	result, err := models.GetAverageSpending()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting average spending"})
	}

	return c.JSON(http.StatusOK, map[string]float64{
		"average_spending": result,
	})
}

func GetTotalProductSold(c echo.Context) error {
	result, err := models.GetTotalProductSold()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting total product sold"})
	}

	return c.JSON(http.StatusOK, map[string]int32{
		"total_product_sold": result,
	})
}

func GetTotalCategories(c echo.Context) error {
	result, err := models.GetTotalCategories()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting total categories"})
	}

	return c.JSON(http.StatusOK, map[string]int32{
		"total_categories": result,
	})
}

func GetTotalProductStock(c echo.Context) error {
	result, err := models.GetTotalProductStock()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting total product stock"})
	}

	return c.JSON(http.StatusOK, map[string]float64{
		"total_product_stock": result,
	})
}

func GetAverageProductCost(c echo.Context) error {
	result, err := models.GetAverageProductCost()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting average product cost"})
	}

	return c.JSON(http.StatusOK, map[string]float64{
		"average_product_cost": result,
	})
}

func GetProductsPerCategory(c echo.Context) error {
	result, err := models.GetProductsPerCategory()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting products per category"})
	}

	return c.JSON(http.StatusOK, map[string][]entities.StatsProduct{
		"products_per_category": result,
	})
}
