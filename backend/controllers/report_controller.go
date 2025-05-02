package controllers

import (
	"net/http"
	"trinity/backend/items/models"

	echo "github.com/labstack/echo/v4"
)

// TODO: fix get
func GetReports(c echo.Context) error {
	reports, err := models.GetReports(0, 10)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error getting reports"})
	}

	return c.JSON(http.StatusOK, reports)
}
