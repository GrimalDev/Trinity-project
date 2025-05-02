package controllers

import (
	"net/http"
	"trinity/backend/items/entities"
	"trinity/backend/items/models"

	echo "github.com/labstack/echo/v4"
)

// GetInvoices handles GET requests to retrieve users
// TODO: fix get
func GetInvoices(c echo.Context) error {
	invoices, err := models.GetInvoices(0, 10)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting invoices"})
	}

	return c.JSON(http.StatusOK, invoices)
}

func GetSelfInvoices(c echo.Context) error {
	invoices, err := models.GetInvoices(0, 10)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting invoices"})
	}

	return c.JSON(http.StatusOK, invoices)
}

func GetSelfInvoicesById(c echo.Context) error {
	user := c.Get("user").(entities.UserBasicStruct)
	invoice_id := c.Param("id")

	println("invoice_id", invoice_id)

	invoice, err := models.GetUserInvoiceById(user.Id, invoice_id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, invoice)
}

func GetHistorySelfInvoices(c echo.Context) error {
	user := c.Get("user").(entities.UserBasicStruct)

	invoices, err := models.GetUserInvoiceDateAndVAT(user.Id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting invoices"})
	}

	return c.JSON(http.StatusOK, invoices)
}

// CreateInvoice handles POST requests to create a new user
func CreateInvoice(c echo.Context) error {

	// models.CreateInvoice()

	var invoiceRequ entities.InvoiceStruct

	if err := c.Bind(invoiceRequ); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid input"})
	}

	return c.JSON(http.StatusCreated, invoiceRequ)
}

// func UpdateInvoice(c echo.Context) error {
//
// 	return c.JSON(http.StatusAccepted, "Les invoices de Baptiste sont mis a jour")
// }

func ArchiveInvoice(c echo.Context) error {
	invoice_id := c.Param("id")

	err := models.ArchiveInvoiceById(invoice_id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error archiving invoice"})
	}

	return c.JSON(http.StatusNoContent, nil)
}
