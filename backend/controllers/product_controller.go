package controllers

import (
	"fmt"
	"net/http"
	"trinity/backend/items/entities"
	"trinity/backend/items/models"

	echo "github.com/labstack/echo/v4"
)

// GetProduct handles GET requests to retrieve users
func GetProducts(c echo.Context) error {
	products, err := models.GetProducts(0, 10)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting products"})
	}

	return c.JSON(http.StatusOK, products)
}

func GetProductsByBarcode(c echo.Context) error {
	barcode := c.Param("barcode")
	product, err := models.GetProductByReference(barcode)
	if err != nil {
		if err.Error() == fmt.Sprintf("no product found with reference: %s", barcode) {
			return c.JSON(http.StatusNotFound, map[string]string{"error": fmt.Sprintf("Product with barcode %s not found", barcode)})
		}
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting product"})
	}
	return c.JSON(http.StatusOK, product)
}

func UpdateProduct(c echo.Context) error {
	return c.JSON(http.StatusOK, nil)
}

func AddProduct(c echo.Context) error {

	var productBasic entities.ProductBasic
	if err := c.Bind(&productBasic); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid product on bind"})
	}

	if err := c.Validate(productBasic); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": fmt.Sprintf("Invalid product data: %v", err)})
	}

	product, err := models.CreateProduct(productBasic)

	if err != nil {
		// return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error creating product"})
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	return c.JSON(http.StatusCreated, product)

}

// UpdateProduct handles PUT requests to update a product
func ArchiveProduct(c echo.Context) error {
	product_id := c.Param("id")
	err := models.ArchiveProductById(product_id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error archiving product"})
	}

	return c.JSON(http.StatusNoContent, nil)
}

func GetProductsBySearch(c echo.Context) error {
	name := c.Param("name")
	product, err := models.GetProductBySearchProducts(name)
	if err != nil {
		if err.Error() == fmt.Sprintf("no product found: %s", name) {
			return c.JSON(http.StatusNotFound, map[string]string{"error": fmt.Sprintf("Product %s not found", name)})
		}
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting product"})
	}
	return c.JSON(http.StatusOK, product)
}
